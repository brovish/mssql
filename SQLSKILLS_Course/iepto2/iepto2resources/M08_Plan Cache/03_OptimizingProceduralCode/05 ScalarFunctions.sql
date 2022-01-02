/*============================================================================
  Summary: A simple scalar function leads to disastrous performance
	due to a RBAR operation (row by agonizing row)...
  
  SQL Server Version: SQL Server 2000+
	except for the hints:
		2005+: OPTION (RECOMPILE) and OPTION (OPTIMIZE FOR...) 
		2008+: OPTION (OPTIMIZE FOR UNKNOWN)
		(note: 2008 R2 RTM and SP1 had problems with OPTION (RECOMPILE)
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

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 back and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE Credit;
GO

-- DO NOT turn on Graphical Showplan
SET STATISTICS IO ON;
SET STATISTICS time ON;
go

CREATE FUNCTION [dbo].[MemberName]
	(@MemberNo	int)
RETURNS VARCHAR (31)
AS
BEGIN
RETURN
	(SELECT [m].[firstname] + ' ' + [m].[lastname]
	FROM [dbo].[member] AS [m]
	WHERE [m].[member_no] = @MemberNo);
END
GO

-----------------------------------------------------
-- First scenario:
--	Small table... not a huge cost
--	make sure you run this once WITHOUT showplan
--	then, run it again - WITH showplan!
-----------------------------------------------------

DBCC FREEPROCCACHE;
GO

DECLARE @starttime  DATETIME2;
SELECT @starttime = SYSDATETIME ();

SELECT [m].[member_no]
 , [m].[firstname] + ' ' + [m].[lastname]
FROM [dbo].[member] AS [m];
SELECT [DurationQuery] = DATEDIFF (
	ms, @starttime, SYSDATETIME ());

DBCC FREEPROCCACHE;

SELECT @starttime = SYSDATETIME ();
SELECT [m].[member_no]
	, [dbo].[MemberName] ([m].[member_no])
FROM [dbo].[member] AS [m]
SELECT [DurationFunction] = DATEDIFF (
	ms, @starttime, SYSDATETIME ());
GO

-----------------------------------------------------
-- Second scenario:
--	BIGGER table... a noticeably LARGE PERF IMPACT!
--	make sure you run this once WITHOUT showplan
--	then, run it again - WITH showplan!
-----------------------------------------------------

-- But - it gets A LOT worse when you put this into more
-- complicated statements.

DECLARE @starttime  DATETIME2;
SELECT @starttime = SYSDATETIME ();

SELECT [c].[member_no]
	, [m].[firstname] + ' ' + [m].[lastname]
	, SUM ([c].[charge_amt])
FROM [dbo].[charge] AS [c]
	JOIN [dbo].[member] AS [m]
		ON [c].[member_no] = [m].[member_no]
GROUP BY [c].[member_no], [m].[firstname] + ' ' + [m].[lastname];
SELECT [DurationQuery] = DATEDIFF (
	ms, @starttime, SYSDATETIME ());
GO
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'charge'. Scan count 9, logical reads 9453, physical reads 43, read-ahead reads 6039, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'member'. Scan count 9, logical reads 427, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

--SQL Server Execution Times:
--   CPU time = 1684 ms,  elapsed time = 583 ms.

DECLARE @starttime  DATETIME2;
SELECT @starttime = SYSDATETIME ();
SELECT [c].[member_no]
	, [dbo].[MemberName] ([c].[member_no])
	, SUM ([c].[charge_amt])
FROM [dbo].[charge] AS [c]
GROUP BY [c].[member_no], [dbo].[MemberName] ([c].[member_no]);
SELECT [DurationFunction] = DATEDIFF (
	ms, @starttime, SYSDATETIME ());
GO

--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'charge'. Scan count 1, logical reads 9335, physical reads 3057, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 989249 ms,  elapsed time = 1140247 ms. (roughly 19 mins)

-----------------------------------------------------
-- what can tip you off that this is happening?
--	Look for CREATE FUNCTION in dm_exec_query_stats
-----------------------------------------------------

-- To see executions you need to look for the function
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
WHERE [st].[text] LIKE '%CREATE FUNCTION%'
		-- use this to find ONLY a specific function
	AND [st].[text] NOT LIKE '%syscacheobjects%'
ORDER BY 2, [qs].[execution_count] DESC;
GO
