/*============================================================================
  Summary: A few ways to query the procedure stats...
  
  SQL Server Version: SQL Server 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- This is really similar to dm_exec_query_stats but at
-- the procedure level find procedures that are executed
-- frequently and/or ones that have high cumulative costs

-- Cool thing to add - database/object_name

SELECT DB_NAME ([database_id]) AS N'Database Name'
    , OBJECT_NAME ([object_id], [database_id]) AS N'Object Name'
    , * 
FROM sys.dm_exec_procedure_stats
ORDER BY 1, 2;
GO

SELECT DB_NAME ([database_id]) AS N'Database Name'
    , OBJECT_NAME ([object_id], [database_id]) AS N'Object Name'
    , [execution_count]
    , [total_elapsed_time]
    , * 
FROM sys.dm_exec_procedure_stats
ORDER BY 4 DESC;
GO

-- Query dm_exec_cached_plans for query plans

SELECT DB_NAME ([ps].[database_id]) AS N'Database Name'
    , OBJECT_NAME ([ps].[object_id], [ps].[database_id])
		AS N'Object Name'
    , [ps].[execution_count]
    , [ps].[total_elapsed_time]
    , [ps].* 
    , [cp].*
    , [st].*
    , [qp].*
FROM sys.dm_exec_procedure_stats AS [ps]
    JOIN sys.dm_exec_cached_plans AS [cp]
        ON [ps].[plan_handle] = [cp].[plan_handle]
    CROSS APPLY sys.dm_exec_sql_text ([ps].[sql_handle]) AS [st]
    CROSS APPLY sys.dm_exec_query_plan ([ps].[plan_handle]) AS [qp]
WHERE [ps].[database_id] < 32767
ORDER BY 4 DESC;
GO

CREATE PROC [MultiStatement]
AS
SELECT * FROM sys.objects;
SELECT * FROM sys.all_columns;
SELECT * FROM sys.system_columns;
GO

EXEC [MultiStatement];
GO

SELECT [cp].[objtype]
	, [cp].[cacheobjtype]
	, [cp].[size_in_bytes]
	, [cp].[refcounts]
	, [cp].[usecounts]
	, [st].[text]
FROM sys.dm_exec_cached_plans AS [cp]
CROSS APPLY sys.dm_exec_sql_text ([cp].[plan_handle]) AS [st]
WHERE [st].[text] like '%MultiStatement%'
ORDER BY [cp].[objtype], [cp].[size_in_bytes];
--COMPUTE SUM ([cp].[size_in_bytes]) -- Not supported in 2012
GO 

SELECT [st].[text]
	, [qs].[query_hash]
	, [qs].[query_plan_hash]
	, [qs].[execution_count]
	, [qs].[plan_handle]
	, [qs].[statement_start_offset]
	, [qs].*
	, [qp].* 
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) AS [qp]
WHERE [st].[text] like '%MultiStatement%' AND 
	([st].[text] NOT LIKE '%syscacheobjects%'
		OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY 1, [qs].[execution_count] DESC;
GO

SELECT * FROM sys.dm_exec_procedure_stats 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handl]e) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handl]e) AS [qp]
WHERE [st].[text] like '%MultiStatement%';
GO
