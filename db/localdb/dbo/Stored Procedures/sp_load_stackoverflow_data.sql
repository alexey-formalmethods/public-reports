
CREATE PROCEDURE [dbo].[sp_load_stackoverflow_data]
AS
BEGIN 
	DECLARE @page_num INT = 1;
	DECLARE @result NVARCHAR(MAX);
	DECLARE @t_tmp_tag_count TABLE (tag_name NVARCHAR(50), tag_count INT);
	DECLARE @quota_remaining INT = 10000;
	DECLARE @has_more BIT = 1;
	DECLARE @host NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.host', 1);
	DECLARE @api_version NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.version', 1);
	DECLARE @access_token NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.access_token', 1);
	DECLARE @key NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.key', 1);
	DECLARE @url NVARCHAR(MAX) = '{host}/{api_version}/tags?page={page_num}&pagesize=100&order=desc&sort=popular&site=stackoverflow&access_token={access_token}&key={key}'
	WHILE @page_num <= @quota_remaining AND @has_more = 1
	BEGIN 
		BEGIN TRY 
			BEGIN TRANSACTION
				SET @result = [dbo].[fn_clr_process_web_request](
					 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@url, '{page_num}', cast (@page_num AS VARCHAR(5))), '{access_token}', @access_token), '{key}', @key), '{host}', @host), '{api_version}', @api_version)
					,'GET'
					,'application/json; charset=utf-8'
					,NULL
					,65001
					,NULL
				)
				DELETE FROM @t_tmp_tag_count;
				INSERT INTO @t_tmp_tag_count
				SELECT 
					 LTRIM(RTRIM(JSON_VALUE(dat.value, '$.name'))) AS tag_name
					,CAST(JSON_VALUE(dat.value, '$.count') AS INT) AS tag_count
				FROM OPENJSON((SELECT JSON_QUERY(@result, '$.items'))) dat


				MERGE d_pr_tag AS t
				USING (
					SELECT DISTINCT
						 tag_name AS name
					FROM @t_tmp_tag_count
				) AS s
				ON s.name = T.name
				WHEN NOT MATCHED THEN INSERT (name) VALUES (s.name);
			COMMIT TRANSACTION
			BEGIN TRANSACTION
				MERGE t_stackoverflow_tag_log AS t
				USING (
					SELECT
						 CAST(GETDATE() AS DATE) AS event_date
						,dt.id AS stackoverflow_tag_id
						,dat.tag_name
						,dat.tag_count
					FROM @t_tmp_tag_count dat
					LEFT JOIN d_pr_tag dt ON dat.tag_name = dt.name
				) AS s
				ON s.event_date = t.event_date
				AND s.stackoverflow_tag_id = t.stackoverflow_tag_id
				WHEN MATCHED THEN UPDATE SET tag_count = s.tag_count
				WHEN NOT MATCHED THEN INSERT (event_date, stackoverflow_tag_id, tag_count) 
				VALUES (s.event_date, s.stackoverflow_tag_id, s.tag_count);
			COMMIT TRANSACTION

				SET @has_more = ISNULL(try_cast (JSON_VALUE(@result, '$.has_more') AS BIT), 0);

				SET @page_num = @page_num + 1;
		END TRY 
		BEGIN CATCH 
			IF @@trancount > 0 ROLLBACK TRANSACTION;
			DECLARE @error_message NVARCHAR(MAX) = ERROR_MESSAGE();
			INSERT INTO s_log (init_sql, message_text) VALUES ('sp_load_stackoverflow_data', @error_message);
			raiserror(@error_message, 20, -1) with log
		END CATCH
	END 
END 

