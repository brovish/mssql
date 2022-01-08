SELECT  p.[query_plan]
FROM    sys.[dm_exec_query_stats] AS q
CROSS APPLY sys.[dm_exec_query_plan](q.[plan_handle]) AS p
WHERE   q.[query_hash] = 0xEB3F21FCCE406BBE
GO
