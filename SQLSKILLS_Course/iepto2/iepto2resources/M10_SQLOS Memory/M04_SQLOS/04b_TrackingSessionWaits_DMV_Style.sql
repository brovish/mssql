IF OBJECT_ID('tempdb..#waiting_tasks') IS NOT NULL
BEGIN
	DROP TABLE #waiting_tasks
END

DECLARE @StartTime DATETIME = CURRENT_TIMESTAMP

SELECT 
	wt.session_id,
	wt.exec_context_id,
	wt.wait_duration_ms,
	wt.wait_type,
	t.scheduler_id,
	t.worker_address,
	CURRENT_TIMESTAMP AS collection_time
INTO #waiting_tasks
FROM sys.dm_os_waiting_tasks AS wt
JOIN sys.dm_exec_sessions AS s	
	ON wt.session_id = s.session_id
JOIN sys.dm_os_tasks AS t
	ON wt.waiting_task_address = t.task_address
WHERE s.is_user_process = 1

WHILE DATEADD(ss, 15, @StartTime) > CURRENT_TIMESTAMP
BEGIN

INSERT INTO #waiting_tasks
        ( session_id ,
          exec_context_id ,
          wait_duration_ms ,
          wait_type ,
          scheduler_id ,
          worker_address,
          collection_time
        )
SELECT 
	wt.session_id,
	wt.exec_context_id,
	wt.wait_duration_ms,
	wt.wait_type,
	t.scheduler_id,
	t.worker_address,
	CURRENT_TIMESTAMP
FROM sys.dm_os_waiting_tasks AS wt
JOIN sys.dm_exec_sessions AS s	
	ON wt.session_id = s.session_id
JOIN sys.dm_os_tasks AS t
	ON wt.waiting_task_address = t.task_address
WHERE s.is_user_process = 1

WAITFOR DELAY '00:00:00.002'

END

SELECT * FROM #waiting_tasks
ORDER BY collection_time

