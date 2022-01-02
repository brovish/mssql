-- Script to look at the waiting tasks
SELECT
	owt.session_id,
	owt.wait_duration_ms,
	owt.wait_type,
	owt.blocking_session_id,
	owt.resource_description,
	es.program_name,
	est.text,
	est.dbid,
	eqp.query_plan,
	es.cpu_time,
	es.memory_usage
FROM sys.dm_os_waiting_tasks owt
INNER JOIN sys.dm_exec_sessions es ON
	owt.session_id = es.session_id
INNER JOIN sys.dm_exec_requests er ON
	es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
WHERE es.is_user_process = 1;
GO

-- Look at resource semaphore information
SELECT * 
FROM sys.dm_exec_query_resource_semaphores
WHERE resource_semaphore_id = 0
AND pool_id = 2
GO

-- Look at memory grant information
SELECT * 
FROM sys.dm_exec_query_memory_grants
ORDER BY grant_time, wait_order

select * from sys.dm_exec_requests

select * from sys.dm_os_wait_stats
where wait_type = 'Resource_semaphore'

dbcc memorystatus