


CREATE VIEW [dbo].[v_rpt_stackoverflow_tags]
AS
WITH log_dates AS (
	SELECT
		 MIN(tstl.event_date) AS min_date
		,MAX(tstl.event_date) AS max_date
	FROM t_stackoverflow_tag_log tstl
)
, row_types AS (
			  SELECT 1 AS is_total_for_all_time, 'За все время' AS description
	UNION ALL SELECT 0, 'По дням'
)
SELECT
	 dat.event_date
	,dat.stackoverflow_tag_id
	,dat.stackoverflow_tag_name
	,dat.is_total_for_all_time
	,dat.is_total_for_all_time_text
	,iif (
		 dat.is_total_for_all_time = 1
		,dat.tag_count_cumulative
		,dat.tag_count
	 ) AS tag_count
FROM (
	SELECT 
		 tstl.event_date
		,ld.min_date
		,ld.max_date
		,rt.is_total_for_all_time
		,rt.description							AS is_total_for_all_time_text
		,ISNULL(tstl.stackoverflow_tag_id, -1)	AS stackoverflow_tag_id
		,ISNULL(dst.name, 'None')				AS stackoverflow_tag_name
		,tstl.tag_count							AS tag_count_cumulative
		,tstl.tag_count - ISNULL(LAG(tstl.tag_count) OVER (PARTITION BY tstl.stackoverflow_tag_id ORDER BY tstl.event_date), 0) AS tag_count
	FROM t_stackoverflow_tag_log	tstl 
	LEFT JOIN d_pr_tag				dst ON tstl.stackoverflow_tag_id = dst.id
	CROSS JOIN log_dates			ld
	INNER JOIN row_types			rt  ON rt.is_total_for_all_time = 0 OR (rt.is_total_for_all_time = 1 AND ld.max_date = tstl.event_date)
) dat
WHERE dat.event_date > dat.min_date



