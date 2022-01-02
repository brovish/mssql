/*============================================================================
  Summary: This query helps you to determine how much of your cache
	is used by plans that have the same query hash but have
	not been parameterized. 

	This shows query_hash and query_plan_hash. If you have a
	lot of queries that have BOTH the same query_hash and
	the same query_plan_hash then you might consider using
	FORCED parameterization at the database level. 
  
  SQL Server Version: SQL Server 2008+ 
	sys.dm_exec_query_stats did not have query_hash or query_plan_hash
	in SQL Server 2005.
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

-- This should be run AFTER executing Script 01 
-- (DSE vs. sp_executesql)

USE [Credit];
GO

SET STATISTICS IO ON;
GO

-- And, if you want to dive into the sizes and amount of data in the cache:
CREATE PROCEDURE [QuickCheckOnCacheWSize]
    @StringToFind   NVARCHAR (4000)
AS
SELECT [cp].[objtype]
	, [cp].[cacheobjtype]
	, [cp].[size_in_bytes]
	, [cp].[refcounts]
	, [cp].[usecounts]
	, [st].[text]
FROM sys.dm_exec_cached_plans AS [cp]
CROSS APPLY sys.dm_exec_sql_text ([cp].[plan_handle]) AS [st]
WHERE [cp].[objtype] IN (N'Adhoc', N'Prepared')
        AND [st].[text] LIKE @StringToFind 
        AND ([st].[text] NOT LIKE '%syscacheobjects%'
			OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY [cp].[objtype], [cp].[size_in_bytes];
--COMPUTE SUM ([cp].[size_in_bytes]) -- Not supported in 2012
GO 

-- This is the new way (2005+) and can include the plan 
-- SELECT [st].[text], * --
-- 2008 adds query_hash and query_plan_hash
CREATE PROCEDURE [QuickCheckOnCacheWSizeAndPlan]
    @StringToFind   nvarchar(4000)
AS
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
WHERE [st].[text] LIKE @StringToFind 
	AND ([st].[text] NOT LIKE '%syscacheobjects%'
		OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY 1, [qs].[execution_count] DESC;
GO

--This is the old query (2000+)
--SELECT [sc].[sql], [sc].* 
--FROM [master].[dbo].[syscacheobjects] AS [sc]
--WHERE [sc].[sql] LIKE '%from%dbo%member%' 
--	AND ([sc].[sql] NOT LIKE '%syscacheobjects%' 
--  OR [sc].[sql] NOT LIKE '%SELECT%cp.objecttype%');
--GO

-- Let's run a few more statements but with different 
-- values (on an "unsafe" query)

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Tripps';
GO -- 0 rows

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Tripped';
GO -- 0 rows

EXEC [QuickCheckOnCacheWSize] '%lastname%';
EXEC [QuickCheckOnCacheWSizeAndPlan]  '%lastname%';
GO

-- Let's execute with other values (and therefore 
-- [potentially] different plans)
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Anderson';
GO -- 385 rows

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Barr';
GO -- 385 rows

EXEC [QuickCheckOnCacheWSize] '%lastname%';
EXEC [QuickCheckOnCacheWSizeAndPlan]  '%lastname%';
GO

-- Notice that these two new queries have the same query_hash 
-- but NOT the same query_plan_hash

-- Also, add in the database ID for the entity location
-- and/or to restrict this to only one database
-- Use: sys.dm_exec_plan_attributes

SELECT DB_NAME (CONVERT (INT, [pa].[value])) AS N'DB Name'
	, [st].[text]
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
	CROSS APPLY sys.dm_exec_plan_attributes ([plan_handle]) AS [pa]
WHERE [st].[text] LIKE '%member%lastname%' 
	AND [st].[text] NOT LIKE '%syscacheobjects%'
	AND [pa].[attribute] = 'dbid' 
	-- AND [pa].[value] = DB_ID() 
	-- This last expression should be uncommented if you 
	-- only want to see the current database's queries
ORDER BY  [qs].[execution_count] DESC;
GO

-- Let's get an overall picture of how many 
-- plans EACH query_hash has?
SELECT [qs].[query_hash]
    , COUNT (DISTINCT [qs].[query_plan_hash])
		AS [Distinct Plan Count]
    , SUM([qs].[execution_count]) AS [Execution Total]
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) AS [qp]
WHERE [st].[text] LIKE '%member%' 
GROUP BY [qs].[query_hash]
ORDER BY [Distinct Plan Count] DESC;
GO

-- When the "Distinct Plan Count" is mostly 1 for your queries
-- then you MIGHT consider using forced parameterization.

-- However, before you turn this on - you might want to get
-- more details about the queries that have MULTIPLE plans

-- Review a sampling of the queries (grouping by the query_hash)
-- and see which have the highest *Avg* CPU Time:
SELECT [qs2].[query_hash] AS [Query Hash]
	, [qs2].[query_plan_hash] AS [Query Plan Hash]
	, SUM ([qs2].[total_worker_time]) /
		SUM ([qs2].[execution_count]) AS [Avg CPU Time]
	, MIN ([qs2].[statement_text]) AS [Example Statement Text]
 FROM (SELECT [qs].*,  
        SUBSTRING ([st].[text], 
			([qs].[statement_start_offset] / 2) + 1, 
	    ((CASE [statement_end_offset] WHEN -1 THEN
			DATALENGTH ([st].[text]) 
		    ELSE [qs].[statement_end_offset] END - 
				[qs].[statement_start_offset]) / 2) + 1) 
		        AS [statement_text]
		FROM sys.dm_exec_query_stats AS [qs] 
			CROSS APPLY sys.dm_exec_sql_text (
				[qs].[sql_handle]) AS [st]) AS [qs2]
GROUP BY [qs2].[query_hash], [qs2].[query_plan_hash] 
ORDER BY [Avg CPU Time] DESC;
--ORDER BY [qs2].[query_hash]
GO

SELECT [qs2].[query_hash] AS [Query Hash]
	, SUM ([qs2].[total_worker_time])
		AS [Total CPU Time - Cumulative Effect]
	, COUNT (DISTINCT [qs2].[query_plan_hash]) AS [Number of plans] 
	, SUM ([qs2].[execution_count]) AS [Number of executions] 
	, MIN ([qs2].[statement_text]) AS [Example Statement Text]
 FROM (SELECT [qs].*,  
        SUBSTRING ([st].[text], (
			[qs].[statement_start_offset] / 2) + 1, 
	    ((CASE [statement_end_offset] WHEN -1 THEN
			DATALENGTH ([st].[text]) 
		    ELSE [qs].[statement_end_offset] END -
				[qs].[statement_start_offset]) / 2) + 1) 
		        AS [statement_text]
		FROM sys.dm_exec_query_stats AS [qs]
		    CROSS APPLY sys.dm_exec_sql_text (
				[qs].[sql_handle]) AS [st]) AS [qs2]
GROUP BY [qs2].[query_hash] 
ORDER BY [Total CPU Time - Cumulative Effect] DESC;
GO

-- What database is taking up the MOST single-use plan cache
-- Might want to use DBCC FLUSHPROCINDB instead (but, remember,
-- that clears stored procedures as well). So, even then, I still
-- prefer FREESYSTEMCACHE. 

-- But, here's how it breaks down by database:

SELECT DB_NAME (CONVERT (INT, [pa].[value])) AS [DBName]
	, [qs2].[query_hash] AS [Query Hash]
	, SUM ([qs2].[total_worker_time])
		AS [Total CPU Time - Cumulative Effect]
	, COUNT (DISTINCT [qs2].[query_plan_hash]) AS [Number of plans] 
	, SUM ([qs2].[execution_count]) AS [Number of executions] 
	, MIN ([qs2].[statement_text]) AS [Example Statement Text]
FROM (SELECT [qs].*,  
        SUBSTRING ([st].[text], (
			[qs].[statement_start_offset] / 2) + 1, 
	    ((CASE [statement_end_offset] WHEN -1 THEN
			DATALENGTH ([st].[text]) 
		    ELSE [qs].[statement_end_offset] END -
				[qs].[statement_start_offset]) / 2) + 1) 
		        AS [statement_text]
		FROM sys.dm_exec_query_stats AS [qs]
		    CROSS APPLY sys.dm_exec_sql_text (
				[qs].[sql_handle]) AS [st]) AS [qs2]
	CROSS APPLY sys.dm_exec_plan_attributes ([qs2].[plan_handle]) AS [pa]
WHERE [pa].[attribute] = 'dbid' 
GROUP BY DB_NAME (CONVERT (INT, [pa].[value])), [qs2].[query_hash] 
--ORDER BY DB_NAME (CONVERT (INT, [pa].[value])), [Total CPU Time - Cumulative Effect] DESC;
ORDER BY [Total CPU Time - Cumulative Effect] DESC;
GO