/*============================================================================
  Summary:  What are the differences in the way that queries are submitted?
  
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

-- Make sure this is NOT ON (for the scripts). If it's on then be sure 
-- to turn it off for this demo. However, I generally recommend that 
-- it's set in production!

-- NOTE: this is a server-wide setting - do NOT "play" with this
-- script in production!!

SELECT * 
FROM sys.configurations
WHERE [name] = N'optimize for ad hoc workloads';
GO

-- you can't see this unless you have advanced options showing:
EXEC sp_configure 'Advanced', 1;
GO

RECONFIGURE;
GO

EXEC sp_configure 'ad hoc workloads', 0;
-- actual option: 'optimize for ad hoc workloads'
-- However, sp_configure only needs enough of the option
-- to make it unique.
GO

RECONFIGURE;
GO

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 back and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE [Credit];
GO

SET STATISTICS IO ON;
GO

-- Some quick setup
UPDATE [member]	
SET [lastname] = 'Tripp' 
WHERE [member_no] = 1234;
GO

CREATE INDEX [MemberLastName]
ON [dbo].[member] ([lastname])
GO

-- Get my version of sp_helpindex here: https://www.sqlskills.com/blogs/kimberly/sp_helpindex-v20170228/ 
EXEC [sp_SQLskills_helpindex] [member];
GO

--------------------------------------------------
-- Can we see what's in cache?
--
-- Simple proc to quickly see a subset of
-- what statements are in cache - with their
-- plan.
--------------------------------------------------
CREATE PROCEDURE [QuickCheckOnCache]
    @StringToFind   NVARCHAR (4000)
AS
SELECT [st].[text], [qs].[execution_count], [qs].*, [p].* 
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) [p]
WHERE [st].[text] LIKE @StringToFind
ORDER BY 1, [qs].[execution_count] DESC;
GO

-- Make it a bit easier (more isolated) 
-- to review what's in cache and to clear
-- any plans that might have ended up there
-- that could influence the results of this
-- scripts:
DBCC FREEPROCCACHE;
GO

-- These are great for review:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Also, turn Actual Graphical Showplan ON
GO

--------------------------------------------------
-- Execute a few statements and review how
-- they're handled in cache
 
-- Parameterized? Safe? Unsafe?
--------------------------------------------------

SELECT * 
FROM [dbo].[member] 
WHERE [member_no] = 258;
GO

SELECT * 
FROM [dbo].[member]
WHERE [member_no] = 34567;
GO

SELECT * 
FROM [dbo].[member] 
WHERE [member_no] = 34;
GO

EXEC [QuickCheckOnCache] '%member%';
GO

SELECT * 
FROM [dbo].[member] 
WHERE [member_no] = convert(int, 36);
GO

SELECT * 
FROM [dbo].[member] 
WHERE [member_no] = convert(int, 36789);
GO

SELECT * 
FROM [dbo].[member] 
WHERE [member_no] = convert(int, 2345);
GO

EXEC [QuickCheckOnCache] '%convert%';
GO

-- NOTES: The first statements are all deemed safe.

SELECT * 
FROM [dbo].[member] 
WHERE [lastname] = 'Anderson';
GO

SELECT * 
FROM [dbo].[member] 
WHERE [lastname] = 'Tripp';
GO

EXEC [QuickCheckOnCache] '%lastname%';
GO

SELECT * 
FROM  [dbo].[member] 
WHERE [lastname] = 'Anderson';
GO

EXEC [QuickCheckOnCache] '%lastname%';
GO

SELECT [m].* 
FROM  [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Anderson';
GO

EXEC [QuickCheckOnCache] '%lastname%';
GO

SELECT * 
FROM [dbo].[member] 
WHERE [lastname] LIKE 'Tripp';
GO

SELECT * 
FROM [dbo].[member] AS [m]
WHERE [lastname] LIKE 'Tripp';
GO

SELECT * 
FROM [dbo].[member] AS [t]
WHERE [lastname] LIKE '%e%';
GO

EXEC [QuickCheckOnCache] '%lastname%';
GO

-- NOTES: All of these are all deemed unsafe.

-----------------------------------------------------
-- How do things change with sp_executesql or EXEC?
-----------------------------------------------------

--------------------------------------------------
-- sp_executesql with a "stable" statement
--------------------------------------------------
DECLARE @ExecStr    NVARCHAR (4000);
SELECT @ExecStr =
	N'SELECT * FROM [dbo].[member] WHERE [member_no] = @mno';
EXEC sp_executesql @ExecStr, N'@mno int', 1234;
GO
                      
DECLARE @ExecStr    NVARCHAR (4000);
SELECT @ExecStr =
	N'SELECT * FROM [dbo].[member] WHERE [member_no] = @mno';
EXEC sp_executesql @ExecStr, N'@mno int', 12;
GO

DECLARE @ExecStr    NVARCHAR (4000);
SELECT @ExecStr =
	N'SELECT * FROM [dbo].[member] WHERE [member_no] = @mno';
EXEC sp_executesql @ExecStr, N'@mno int', 76896;
GO

EXEC [QuickCheckOnCache] '%mno%';
GO

-- NOTES: Only ONE statement is placed in cache. And, notice that
-- it's strongly typed. For a safe statement this is beneficial.

--------------------------------------------------
-- sp_executesql with a different (and unstable) statement
--------------------------------------------------

DECLARE @ExecStr    NVARCHAR (4000);
SELECT @ExecStr =
	N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE @lastname';
EXEC sp_executesql @ExecStr, N'@lastname varchar(15)', 'Tripp';
GO
                      
DECLARE @ExecStr    NVARCHAR (4000);
SELECT @ExecStr =
	N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE @lastname';
EXEC sp_executesql @ExecStr, N'@lastname varchar(15)', 'Anderson';
GO

DECLARE @ExecStr    NVARCHAR (4000);
SELECT @ExecStr = 
    N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE @lastname';
EXEC sp_executesql @ExecStr, N'@lastname varchar(15)', '%e%';
GO

--sp_recompile member;
EXEC [QuickCheckOnCache] '%member%';
GO

--------------------------------------------------
-- EXECUTE with safe statement
-- Remember: if you want to reduce SQL injection
-- check out this post:
-- http://www.sqlskills.com/blogs/kimberly/little-bobby-tables-sql-injection-and-execute-as/
--------------------------------------------------
DECLARE @ExecStr    NVARCHAR (4000),
		@MemberNo	INT;
SELECT @MemberNo = 1567;
-- This first version is what's most likely for people to 
-- write. However, you'll end up with a plan per data type.
--SELECT @ExecStr = N'SELECT [MBR].* FROM [DBO].[MEMBER] AS [MBR] WHERE [MBR].[MEMBER_NO] = ' 
--		+ CONVERT (NVARCHAR (10), @MemberNo); 
-- This second version is better as the variable is strongly 
-- typed. If the statement is "safe" SQL Server will only 
-- have ONE plan to use/re-use.
SELECT @ExecStr = N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[member_no] = CONVERT (INT, ' 
					+ CONVERT (NVARCHAR (10), @MemberNo) + N')';
SELECT @ExecStr;
EXEC (@ExecStr);
GO
                      
DECLARE @ExecStr    NVARCHAR (4000),
		@MemberNo	INT;
SELECT @MemberNo = 17;
--SELECT @ExecStr = N'SELECT [mbr].* FROM [dbo].[member] AS [mbr] WHERE [mbr].[member_no] = ' + CONVERT (NVARCHAR (10), @MemberNo) ;
SELECT @ExecStr = N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[member_no] = CONVERT (INT, ' + CONVERT (NVARCHAR (10), @MemberNo) + N')';
SELECT @ExecStr;
EXEC (@ExecStr);
GO

DECLARE @ExecStr    NVARCHAR (4000),
		@MemberNo	INT;
SELECT @MemberNo = 67890;
--SELECT @ExecStr = N'SELECT [mbr].* FROM [dbo].[member] AS [mbr] WHERE [mbr].[member_no] = ' + CONVERT (NVARCHAR (10), @MemberNo) ;
SELECT @ExecStr = N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[member_no] = CONVERT (INT, ' + CONVERT (NVARCHAR (10), @MemberNo) + N')';
SELECT @ExecStr;
EXEC (@ExecStr);
go

EXEC [QuickCheckOnCache] '%member%';
GO

--------------------------------------------------
-- EXECUTE with an unsafe statement
--------------------------------------------------
DECLARE @ExecStr    NVARCHAR (4000),
		@Lastname	VARCHAR (15);
SELECT @Lastname = 'Tripp';
--SELECT @ExecStr = N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE CONVERT (VARCHAR (15), ' 
--    + QUOTENAME (@lastname, '''') + N')';
--SELECT @ExecStr
-- Using REPLACE instead of QUOTENAME. 
-- QUOTENAME is limited to NVARCHAR (128) 
-- for longer strings - you must use REPLACE:
SELECT @ExecStr = N'SELECT * FROM [dbo].[member] WHERE [lastname] LIKE CONVERT (VARCHAR (15), ''' + REPLACE (@lastname, '''', '''''') + N''')';
SELECT @ExecStr;
EXEC (@ExecStr);
GO
                      
DECLARE @ExecStr    NVARCHAR (4000),
		@Lastname	VARCHAR (15);
SELECT @Lastname = 'Anderson';
SELECT @ExecStr = N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE CONVERT (VARCHAR (15), ' + QUOTENAME (@lastname, '''') + N')';
--SELECT @ExecStr;
EXEC (@ExecStr);
GO

DECLARE @ExecStr    NVARCHAR(4000),
		@Lastname	VARCHAR(15);
SELECT @Lastname = '%e%';
SELECT @ExecStr = N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE CONVERT (VARCHAR (15), ' + QUOTENAME (@lastname, '''') + N')';
--SELECT @ExecStr;
EXEC (@ExecStr);
GO

EXEC [QuickCheckOnCache] '%varchar (15)%';
GO