

CREATE VIEW [dbo].[v_rpt_stackoverflow_tags]
AS
SELECT
	 dat.event_date
	,dat.stackoverflow_tag_id
	,dat.stackoverflow_tag_name
	,dat.tag_count
FROM (
	SELECT 
		 tstl.event_date
		,tstl.stackoverflow_tag_id
		,dst.name AS stackoverflow_tag_name
		,tstl.tag_count - ISNULL(LAG(tstl.tag_count) OVER (PARTITION BY tstl.stackoverflow_tag_id ORDER BY tstl.event_date), 0) AS tag_count
	FROM t_stackoverflow_tag_log tstl 
	LEFT JOIN d_pr_tag dst ON tstl.stackoverflow_tag_id = dst.id
	WHERE tstl.event_date >= DATEADD(MONTH, -3, getdate())
) dat



