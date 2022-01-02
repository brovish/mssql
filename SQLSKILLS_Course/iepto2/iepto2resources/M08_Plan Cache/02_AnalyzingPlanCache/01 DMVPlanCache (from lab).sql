/*============================================================================
  DMVs LAB:   SQL Server 2008: Understanding and Using DMVs 
  
  Script:     DMVPlanCache.sql

  Summary:    This script demonstrates using DMVs to access information in the
			  query plan cache.
		
  Date:       August 2008

  SQL Server Version: 10.0.2531.0 (SQL Server 2008 SP1)
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  written/presented by SQLskills.com  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

------------------------------------------------
-- ** Step 1 Begin **
------------------------------------------------
Use AdventureWorks2008;
GO

-- Clear the plan cache completely
DBCC FREEPROCCACHE;
GO
------------------------------------------------
-- ** Step 1 End **
------------------------------------------------

------------------------------------------------
-- ** Step 2 Begin **
------------------------------------------------
-- An example query to track - auto parameterized and cached...
SELECT * 
FROM Person.Address 
WHERE AddressID < 500;
GO
------------------------------------------------
-- ** Step 2 End **
------------------------------------------------

------------------------------------------------
-- ** Step 3 Begin **
------------------------------------------------
-- Use the system table syscacheobjects to look in the plan
-- cache. This works on SQL Server 2000 and 2005.
SELECT * FROM master.dbo.syscacheobjects;
GO
------------------------------------------------
-- ** Step 3 End **
------------------------------------------------

------------------------------------------------
-- ** Step 4 Begin **
------------------------------------------------
-- Now filter out everything except compiled plans.
SELECT * FROM master.dbo.syscacheobjects
    WHERE cacheobjtype = 'Compiled Plan';
GO
------------------------------------------------
-- ** Step 4 End **
------------------------------------------------

------------------------------------------------
-- ** Step 5 Begin **
------------------------------------------------
-- To use the DMVs, you must be in 90 compatibility level.
-- Let's try it in 80 compatibility level and see what
-- happens.
sp_dbcmptlevel AdventureWorks2008, 80;
GO

SELECT cp.*, st.text 
FROM sys.dm_exec_cached_plans AS cp 
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) st 
WHERE st.text like '%AddressID%';
GO
------------------------------------------------
-- ** Step 5 End **
------------------------------------------------

------------------------------------------------
-- ** Step 6 Begin **
------------------------------------------------
-- Now let's put it in 90 compatability level and reexecute our example
-- query because changing compatibility level will flush
-- the cache
sp_dbcmptlevel AdventureWorks2008, 90;
GO

SELECT * 
FROM Person.Address 
WHERE AddressID < 500;
GO
------------------------------------------------
-- ** Step 6 End **
------------------------------------------------

------------------------------------------------
-- ** Step 7 Begin **
------------------------------------------------
-- Now we can use two of the dm_exec_* DMVs to pull out the cached
-- query plan for our example query.
SELECT cp.*, st.text 
FROM sys.dm_exec_cached_plans AS cp 
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) st 
WHERE st.text like '%AddressID%';
GO
------------------------------------------------
-- ** Step 7 End **
------------------------------------------------

------------------------------------------------
-- ** Step 8 Begin **
------------------------------------------------
-- Or even better, you can see number of executions:
SELECT st.text, qs.EXECUTION_COUNT, qs.*, p.* 
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) p
WHERE st.text like '%AddressID%'
--ORDER BY qs.EXECUTION_COUNT DESC;
GO
------------------------------------------------
-- ** Step 8 End **
------------------------------------------------

------------------------------------------------
-- ** Step 9 Begin **
------------------------------------------------
-- Thanks to Bob Beauchemin and his XML query expertise!!!
-- What if we want to look for specific physical operations...
-- We can't just do: where query_plan like '%clustered index seek%'
-- We could:
SELECT st.text, qs.EXECUTION_COUNT, qs.*, p.* 
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) p
WHERE CONVERT(NVARCHAR(MAX), query_plan) LIKE '%clustered index scan%';
GO
------------------------------------------------
-- ** Step 9 End **
------------------------------------------------

------------------------------------------------
-- ** Step 10 Begin **
------------------------------------------------
-- But - even better (thanks to Bob):
SELECT st.text, qs.EXECUTION_COUNT, qs.*, p.* 
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) p
WHERE query_plan.exist('//*[@* = "Clustered Index Seek"]') = 1;
GO
------------------------------------------------
-- ** Step 10 End **
------------------------------------------------

------------------------------------------------
-- ** Step 11 Begin **
------------------------------------------------
-- And - EVEN BETTER (thanks again to Bob):
SELECT st.text, qs.EXECUTION_COUNT, qs.*, p.* 
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) p
WHERE query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";/ShowPlanXML/BatchSequence/Batch/Statements//RelOp[@LogicalOp = "Clustered Index Seek"]') = 1;
GO
------------------------------------------------
-- ** Step 11 End **
------------------------------------------------

------------------------------------------------
-- ** Step 12 Begin **
------------------------------------------------
-- And - to bring it all together as a stored procedure:
IF OBJECTPROPERTY(object_id(N'dbo.LookForPhysicalOps'), 'IsProcedure') = 1
	DROP PROCEDURE dbo.LookForPhysicalOps;
GO

CREATE PROCEDURE dbo.LookForPhysicalOps (@op VARCHAR(30))
AS
SELECT st.text, qs.EXECUTION_COUNT, qs.*, p.* 
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(plan_handle) p
WHERE query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";/ShowPlanXML/BatchSequence/Batch/Statements//RelOp/@PhysicalOp[. = sql:variable("@op")]') = 1;
GO
------------------------------------------------
-- ** Step 12 End **
------------------------------------------------

------------------------------------------------
-- ** Step 13 Begin **
------------------------------------------------
EXEC dbo.LookForPhysicalOps 'Clustered Index Scan';
GO

EXEC dbo.LookForPhysicalOps 'Nested Loops';
GO

EXEC dbo.LookForPhysicalOps 'Table Scan';
GO
------------------------------------------------
-- ** Step 13 End **
------------------------------------------------

