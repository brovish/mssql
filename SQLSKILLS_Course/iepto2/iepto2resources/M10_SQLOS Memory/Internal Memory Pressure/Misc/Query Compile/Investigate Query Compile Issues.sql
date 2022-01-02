-- Waiting tasks with CompileMemory requirements
WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT 
	c.value('(@CompileMemory)[1]', 'int') AS CompileMemory_KB,
	wt.session_id,
	wt.wait_type,
	wt.wait_duration_ms
FROM sys.dm_os_waiting_tasks AS wt
JOIN sys.dm_exec_sessions AS es
	ON wt.session_id = es.session_id
JOIN sys.dm_exec_requests AS er
	ON es.session_id = er.session_id
CROSS APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
CROSS APPLY qp.query_plan.nodes('//QueryPlan') AS n(c)
WHERE es.is_user_process = 1
  AND wt.wait_type = 'RESOURCE_SEMAPHORE_QUERY_COMPILE';
  
-- Compilation Gateway information
DBCC MEMORYSTATUS;
