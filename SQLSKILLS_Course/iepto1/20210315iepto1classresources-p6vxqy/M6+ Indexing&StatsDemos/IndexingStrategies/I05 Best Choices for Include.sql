/*============================================================================
  File:     Best Choices for Include.sql

  Summary:  This script shows a few options for using INCLUDE as well as how
			to see the structures and their differences.
  
  SQL Server Version: 2005+
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

-- sp_helpindex rewrites - always use the most recent post!
-- https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/

USE [Credit];
GO

SET STATISTICS IO ON; 
GO

EXEC [sp_helpindex] '[dbo].[member]';
EXEC [sp_SQLskills_helpindex] '[dbo].[member]';
GO

-- Original query
SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

---------------------------------------
-- OPTION 1
-- What if we had an index on 
-- Lastname ONLY? Would SQL Server use
-- it for such a LOW SELECTIVITY query?
---------------------------------------

CREATE INDEX [NCIndexLNOnly]
ON [dbo].[member]([lastname]);
GO

-- First query forces the new index, the second has no hints
SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexLNOnly]))
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

-- Compare against the same query without hints
SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] LIKE '[S-Z]%';
GO


---------------------------------------
-- OPTION 2
-- so, what about covering all 4 cols?
---------------------------------------
CREATE INDEX [NCIndexCoversAll4Cols] 
ON [dbo].[member]
([lastname], [firstname], 
	[middleinitial], [phone_no]);
GO

-- compare this against a table scan
SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX (0)) --Index 0 forces a table scan
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

-- Without hints
SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] LIKE '[S-Z]%';
GO


--------------------------------------
-- OPTION 3
-- how about JUST putting lastname in the key
-- and "including" the other columns
--------------------------------------
CREATE INDEX [NCIndexLNinKeyInclude3OtherCols]
ON [dbo].[member]([lastname])
INCLUDE ([firstname], 
	[middleinitial], [phone_no]);
GO

-- Added during our "internals discussion"
--CREATE INDEX [Dupe1]
--ON [dbo].[member]([lastname], member_no)
--INCLUDE ([firstname], 
--	[middleinitial], [phone_no]);
--go

--CREATE INDEX [Dupe2]
--ON [dbo].[member]([lastname])
--INCLUDE ([firstname], 
--	[middleinitial], member_no, [phone_no]);
--go

--EXEC [sp_helpindex] '[dbo].[member]';
--EXEC [sp_SQLskills_helpindex] '[dbo].[member]';

--EXEC [sp_SQLskills_SQL2008_finddupes] '[dbo].[member]';
---- To set this up, get the procs from this post:
---- https://www.sqlskills.com/blogs/kimberly/removing-duplicate-indexes/

GO

-- Compare against the fully covering index
SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexCoversAll4Cols]))
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexLNinKeyInclude3OtherCols]))
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

--------------------------------------
-- what about index size?
--------------------------------------
SELECT * FROM [sys].[dm_db_index_physical_stats]
(db_id(), object_id('member'), null, null, 'detailed');
go
-- basically they're the same size!


--------------------------------------
-- OPTION 4
-- what index would we *really* create??
--------------------------------------

CREATE INDEX [NCIndexCoveringLnFnMiIncludePhone]
ON [dbo].[member]
    ([lastname], [firstname], [middleinitial])
INCLUDE ([phone_no]);
GO

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexCoversAll4Cols]))
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexLNinKeyInclude3OtherCols]))
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX (NCIndexCoveringLnFnMiIncludePhone))
WHERE [m].[lastname] LIKE '[S-Z]%';
GO

--------------------------------------
-- Ok, if they're all the same - for THIS query...
-- Imagine adding an ORDER BY?

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexCoversAll4Cols]))
WHERE [m].[lastname] LIKE '[S-Z]%'
ORDER BY [lastname], [firstname], [middleinitial];
GO

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX ([NCIndexLNinKeyInclude3OtherCols]))
WHERE [m].[lastname] LIKE '[S-Z]%'
ORDER BY [lastname], [firstname], [middleinitial];
GO

SELECT [m].[lastname], [m].[firstname], 
	[m].[middleinitial], [m].[phone_no]
FROM [dbo].[member] AS [m] WITH (INDEX (NCIndexCoveringLnFnMiIncludePhone))
WHERE [m].[lastname] LIKE '[S-Z]%'
ORDER BY [lastname], [firstname], [middleinitial];
GO
