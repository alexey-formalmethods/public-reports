CREATE VIEW v_rpt_job_history
AS
WITH states AS (
	SELECT 
		run_status, run_status_name
	FROM (
		values 
			 (0, 'Failed')
			,(1, 'Succeeded')
			,(2, 'Retry')
			,(3, 'Canceled')
			,(4, 'In Progress')
	) dat(run_status, run_status_name)
)
SELECT TOP 10000
	 h.instance_id
	,h.job_id
	,j.name AS job_name
	,h.step_name
	,'(' + j.name + ') ' + h.step_name AS job_step_name
	,h.step_id
	,CONVERT(DATETIME, cast (h.run_date AS VARCHAR(8)), 112) + CONVERT(DATETIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) +  CAST(h.run_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':'), 108) AS run_time
	,STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(h.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') 'run_duration (DD:HH:MM:SS)  '
	--,h.run_duration
	,h.run_status
	,s.run_status_name
	,h.message
	,ROW_NUMBER() OVER (PARTITION BY h.job_id, h.step_id ORDER BY h.instance_id DESC) AS RN_job_step
FROM msdb.dbo.sysjobhistory h
INNER JOIN msdb.dbo.sysjobs	j ON h.job_id = j.job_id
LEFT JOIN states			s ON h.run_status = s.run_status
WHERE 1 = 1
AND h.step_id > 0
AND h.run_date >= CAST(FORMAT(DATEADD(DAY, -2, CAST (getdate() AS DATE)), 'yyyyMMdd') AS INT)
ORDER BY h.instance_id, h.step_id