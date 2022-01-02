-- This breaks down the plans a little further so that you can tell
-- the distinct query plans / executions / rows in cache and specifically
-- how many used the SAME values (textual matching) vs. different values!

SELECT [AllPlans].* 
FROM (SELECT 
	  [qs].[query_hash] AS [Query Hash]
	, COUNT (DISTINCT [qs].[query_plan_hash]) AS [Distinct Query Plans]
	, SUM([qs].[execution_count]) AS [Total Executions]
    , COUNT (*) AS [Rows in Plan Cache]
    , SUM(CASE 
        WHEN [qs].[execution_count] > 1 THEN [qs].[execution_count] - 1
            ELSE 0 END) AS [Textual Matches]
    , SUM([qs].[execution_count]) - (SUM([qs].[execution_count]) - COUNT (*)) AS [Different Values]
    , MIN([st].[text]) AS [Sample Text]
	
FROM sys.dm_exec_query_stats AS [qs] 
    JOIN sys.dm_exec_cached_plans AS [cp] 
        ON [qs].[plan_handle] = [cp].[plan_handle]
	CROSS APPLY sys.dm_exec_sql_text ([qs].[sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
WHERE 
    [cp].[objtype] = 'Adhoc' 
    AND ([st].[text] NOT LIKE '%syscacheobjects%'
		  OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
GROUP BY [qs].[query_hash]) AS [AllPlans]
WHERE --[Textual Matches] = 0
     [Total Executions] > 1
ORDER BY [Total Executions] DESC;

-- So, now you want to investigate one of the query hashes to see what the actual
-- statement is... take the query_hash value and paste it into the where clause

SELECT [st].[text]
	, [qs].[query_hash]
	, [qs].[query_plan_hash]
	, [qs].[execution_count]
	, [qs].[plan_handle]
	, [qs].[statement_start_offset]
	, [qs].*
	, [qp].* 
    , [cp].*
FROM sys.dm_exec_query_stats AS [qs] 
    JOIN sys.dm_exec_cached_plans AS [cp] 
        ON [qs].[plan_handle] = [cp].[plan_handle]
	CROSS APPLY sys.dm_exec_sql_text ([qs].[sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
WHERE 
    [qs].[query_hash] = 0x2A748B527C8D2D8D

-- Taking something with many executions but only ONE plan -> might want to "force"
--      using sp_executesql (if you can change the execution method)
--      using a templatized plan guide (if you can't change the execution method)


