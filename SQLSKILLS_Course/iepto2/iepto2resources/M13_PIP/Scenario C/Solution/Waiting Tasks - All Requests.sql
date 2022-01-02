SELECT  [w].[session_id],
        [w].[wait_duration_ms],
        [w].[wait_type],
        [w].[resource_description],
		[r].[command],
        [t].[text],
        [p].[query_plan]
FROM    [sys].[dm_os_waiting_tasks] AS [w]
LEFT OUTER JOIN [sys].[dm_exec_requests] AS [r]
        ON [w].[session_id] = [r].[session_id]
LEFT OUTER JOIN [sys].[dm_exec_sessions] AS [s]
        ON [s].[session_id] = [r].[session_id]
OUTER APPLY [sys].[dm_exec_sql_text]([r].[sql_handle]) AS [t]
OUTER APPLY [sys].[dm_exec_query_plan]([r].[plan_handle]) AS [p]
ORDER BY [w].[wait_duration_ms] DESC;
GO

