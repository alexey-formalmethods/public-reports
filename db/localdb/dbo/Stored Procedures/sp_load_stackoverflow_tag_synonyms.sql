CREATE PROCEDURE [dbo].[sp_load_stackoverflow_tag_synonyms]
AS
BEGIN 
	DECLARE @page_num INT = 1;
	DECLARE @result NVARCHAR(MAX);
	DECLARE @t_tmp_tags_synonyms TABLE (tag_name_from NVARCHAR(50), tag_name_to NVARCHAR(50));
	DECLARE @quota_remaining INT = 10000;
	DECLARE @has_more BIT = 1;
	DECLARE @host NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.host', 1);
	DECLARE @api_version NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.version', 1);
	DECLARE @access_token NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.access_token', 1);
	DECLARE @key NVARCHAR(MAX) = dbo.fn_get_config_value('api.stackexchange.key', 1);
	DECLARE @url NVARCHAR(MAX) = '{host}/{api_version}/tags/synonyms?page={page_num}&pagesize=100&order=desc&sort=creation&site=stackoverflow&access_token={access_token}&key={key}'
	
	-- PRINT @url

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
				DELETE FROM @t_tmp_tags_synonyms;
				INSERT INTO @t_tmp_tags_synonyms (tag_name_from, tag_name_to)
				SELECT 
					 trim(JSON_VALUE(dat.value, '$.to_tag'))	AS tag_name
					,trim(JSON_VALUE(dat.value, '$.from_tag'))	AS tag_count
				FROM OPENJSON((SELECT JSON_QUERY(@result, '$.items'))) dat

				MERGE d_pr_tag AS t
				USING (
					SELECT DISTINCT tag_name_from AS name FROM @t_tmp_tags_synonyms
					UNION SELECT DISTINCT tag_name_to FROM @t_tmp_tags_synonyms
				) AS s
				ON s.name = t.name
				WHEN NOT MATCHED THEN INSERT (name) VALUES (s.name);

				;WITH row_types AS (
							  SELECT 0 AS is_reverse
					UNION ALL SELECT 1
				)
				MERGE t_pr_tag_synonym AS t
				USING (
					
					SELECT DISTINCT
						 IIF(rt.is_reverse = 0, dptf.id, dptt.id) AS pr_tag_id_from
						,IIF(rt.is_reverse = 0, dptt.id, dptf.id) AS pr_tag_id_to
					FROM @t_tmp_tags_synonyms	ts
					INNER JOIN d_pr_tag			dptf ON TS.tag_name_from = dptf.name
					INNER JOIN d_pr_tag			dptt ON TS.tag_name_to = dptt.name	
					CROSS JOIN row_types		rt
				) AS s
				ON s.pr_tag_id_from = T.pr_tag_id_from
				AND s.pr_tag_id_to = t.pr_tag_id_to
				WHEN NOT MATCHED THEN INSERT (pr_tag_id_from, pr_tag_id_to) VALUES (s.pr_tag_id_from, s.pr_tag_id_to);
			COMMIT TRANSACTION
			
				SET @has_more = ISNULL(try_cast (JSON_VALUE(@result, '$.has_more') AS BIT), 0);

				SET @page_num = @page_num + 1;
		END TRY 
		BEGIN CATCH 
			IF @@trancount > 0 ROLLBACK TRANSACTION;
			DECLARE @error_message NVARCHAR(MAX) = ERROR_MESSAGE();
			INSERT INTO s_log (init_sql, message_text) VALUES ('sp_load_stackoverflow_tag_synonyms', @error_message);
			raiserror(@error_message, 20, -1) with LOG;
		END CATCH
	END
END