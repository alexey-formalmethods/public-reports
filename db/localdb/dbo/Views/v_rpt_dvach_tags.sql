CREATE VIEW v_rpt_dvach_tags
AS

SELECT 
	 tdtt.pr_tag_id
	,dpt.name AS pr_tag_name
	,cast (tdt.create_date AS DATE) AS create_date
	,COUNT(DISTINCT tdtt.dvach_thread_id) AS thread_count
	,SUM(tdt.post_count) AS post_count
FROM t_dvach_thread_tag tdtt
INNER JOIN d_pr_tag dpt ON tdtt.pr_tag_id = dpt.id
INNER JOIN t_dvach_thread tdt ON tdtt.dvach_thread_id = tdt.id
GROUP BY 
	 tdtt.pr_tag_id
	,dpt.name
	,cast (tdt.create_date AS DATE)