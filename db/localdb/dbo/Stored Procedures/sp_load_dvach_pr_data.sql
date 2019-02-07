
CREATE PROCEDURE [dbo].[sp_load_dvach_pr_data]
AS
	BEGIN 
	DECLARE @result NVARCHAR(MAX);
	DECLARE @board_code VARCHAR(50) = 'pr';
	IF NOT EXISTS (SELECT 1 FROM d_dvach_board ddb WHERE ddb.code = @board_code)
	BEGIN
		INSERT INTO d_dvach_board (code) VALUES (@board_code);
	END 
	DECLARE @host NVARCHAR(MAX) = dbo.fn_get_config_value('api.2ch.host', 1);
	DECLARE @url NVARCHAR(MAX) = REPLACE(REPLACE('{host}/{board_code}/catalog.json', '{board_code}', @board_code), '{host}', @host);
	DECLARE @dvach_board_id INT = (SELECT id FROM d_dvach_board WHERE code = @board_code);
	SET @result = dbo.fn_clr_process_web_request(@url, 'GET', 'application/json', NULL, NULL, NULL)

	DECLARE @t_tmp_threads AS TABLE (thread_num INT NOT NULL, tags NVARCHAR(255), create_date DATETIME, post_count int);
	INSERT INTO @t_tmp_threads (thread_num, tags, create_date, post_count)
	SELECT
		 JSON_VALUE(dat.value, '$.num')										AS thread_num
		,TRIM(JSON_VALUE(dat.value, '$.tags'))								AS tags
		,dateadd(S, CAST(JSON_VALUE(dat.value, '$.timestamp') AS INT), '19700101')		AS create_date
		,IsNull (JSON_VALUE(dat.value, '$.posts_count'), 0)					AS post_count
	FROM OPENJSON((SELECT JSON_QUERY(@result, '$.threads'))) dat
	WHERE NULLIF(TRIM(JSON_VALUE(dat.value, '$.tags')), '') IS NOT NULL 

	MERGE d_pr_tag AS t
	USING (
		SELECT DISTINCT tags AS name FROM @t_tmp_threads
	) AS s
	ON s.name = t.name
	WHEN NOT MATCHED THEN INSERT (name) VALUES (s.name);

	MERGE t_dvach_thread AS t
	USING (
		SELECT 
			 thread_num AS thread_number
			,@dvach_board_id AS dvach_board_id 
			,MAX(create_date) AS create_date
			,MAX(post_count) AS post_count
		FROM @t_tmp_threads
		GROUP BY thread_num
	) AS s
	ON s.thread_number = t.thread_number
	AND s.dvach_board_id = t.dvach_board_id
	WHEN MATCHED THEN UPDATE SET post_count = s.post_count, create_date = s.create_date
	WHEN NOT MATCHED THEN INSERT 
	(thread_number, dvach_board_id, create_date, post_count)
	VALUES
	(s.thread_number, s.dvach_board_id, s.create_date, s.post_count);


	MERGE t_dvach_thread_tag AS t
	USING (
		SELECT
			 tdt.id AS dvach_thread_id
			,dpt.id AS pr_tag_id
		FROM @t_tmp_threads			tt
		INNER JOIN d_pr_tag			dpt ON tt.tags = dpt.name
		INNER JOIN t_dvach_thread	tdt ON tt.thread_num = tdt.thread_number AND tdt.dvach_board_id = @dvach_board_id
	) AS s
	ON s.dvach_thread_id = t.dvach_thread_id
	AND s.pr_tag_id = t.pr_tag_id
	WHEN NOT MATCHED THEN INSERT (pr_tag_id, dvach_thread_id) VALUES (s.pr_tag_id, s.dvach_thread_id);
END 