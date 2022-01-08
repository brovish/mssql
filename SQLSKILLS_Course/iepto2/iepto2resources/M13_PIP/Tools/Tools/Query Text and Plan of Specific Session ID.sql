SELECT  [t].[text],
        [p].[query_plan]
FROM    [sys].[dm_exec_sessions] AS s
LEFT OUTER JOIN [sys].[dm_exec_requests] AS r
        ON [s].[session_id] = [r].[session_id]
OUTER APPLY [sys].[dm_exec_sql_text]([r].[sql_handle]) AS t
OUTER APPLY [sys].[dm_exec_query_plan]([r].[plan_handle]) AS p
WHERE   [s].[session_id] = 77;
GO