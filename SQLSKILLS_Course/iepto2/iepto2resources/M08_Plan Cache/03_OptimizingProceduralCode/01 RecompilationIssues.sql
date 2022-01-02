/*============================================================================
  Summary: This script shows stored procedure issues related to 
	recompilation - specifically *needing* to recompile. 
  
  SQL Server Version: SQL Server 2005+ 
	However, 2008 added OPTION (OPTIMIZE FOR UNKNOWN)
	NOTE: OPTION (RECOMPILE) has a very dodgy past breaking in
	2008 R2 RTM and SP1 but being fixed in SP2
    Everything else works in 2012 and 2014 RTM+
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
-- There's also a 2008 backup that you can restore to 2008/R2, 2012, or 2014

USE [Credit];
GO

-- Turn Graphical Showplan on, plus:
SET STATISTICS IO ON;
SET STATISTICS time ON;
go

-- Update a row to later search on...
UPDATE [dbo].[member]
	SET [lastname] = 'Tripp'
WHERE [member_no] = 1234;
GO

-- Review the indexes to see if there's an index for lastname
EXEC sp_helpindex N'dbo.member';
EXEC sp_SQLskills_helpindex N'dbo.member';
GO

-- Create an index on lastname 
CREATE INDEX [MemberLastName] 
ON [dbo].[member] ([lastname])
go

-- Create proc with LIKE condition for parameter...
CREATE PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30)
)
AS
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] LIKE @LastName;
GO


-- Turn on showplan with Tools, Show Execution Plan (or Ctrl+K)
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'Anderson';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
EXEC [dbo].[GetMemberInfo] '%e%';
GO
-- All should have generated the same plan... All 
-- should be performing bookmark lookups eventhough the I/Os are 
-- worse than a table scan for query 2 and 3 (switch to the 
-- messages window to see the I/Os).


-- Use sp_recompile to invalidate the plans and re-arrange 
-- the order...
EXEC sp_recompile N'[dbo].[GetMemberInfo]';
-- Re-arranging the order of execution 
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] '%T%';
GO

-- Table Scan for all three. BUT what's really best?

-- Start by testing this with EXEC WITH RECOMPILE
-- forces a recompilation for the ENTIRE procedure...
EXEC [dbo].[GetMemberInfo] 'Tripp'; -- still the PRIOR plan!
EXEC [dbo].[GetMemberInfo] 'Tripp' WITH RECOMPILE;
EXEC [dbo].[GetMemberInfo] 'Tripp'; -- still the PRIOR plan!

EXEC [dbo].[GetMemberInfo] 'Anderson' WITH RECOMPILE;
EXEC [dbo].[GetMemberInfo] 'Barr' WITH RECOMPILE;
EXEC [dbo].[GetMemberInfo] 'Chen' WITH RECOMPILE;
EXEC [dbo].[GetMemberInfo] 'Dorr' WITH RECOMPILE;
EXEC [dbo].[GetMemberInfo] 'T%' WITH RECOMPILE;
EXEC [dbo].[GetMemberInfo] '%T%' WITH RECOMPILE;

EXEC [dbo].[GetMemberInfo] 'Tripp'; -- still the PRIOR plan!
GO

-- Are they different plans??? YES!

-- You could CREATE with RECOMPILE so that every single execution 
-- forces a recompilation for the ENTIRE procedure...

ALTER PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30)
) WITH RECOMPILE
AS
SELECT [m].* 
FROM [dbo].[member] AS [m] 
WHERE [m].[lastname] LIKE @LastName;
GO

-- Review the different plans and the more optimal I/Os
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
GO

-- OR you could use statement-based recompilation (if there's 
-- a lot of code).
-- NOTE: Inline recompilation might not always work BUT if the
-- SQL statement generates different plans for different 
-- executions (when executed OUTSIDE of the proc) then it 
-- is VERY likely that the plan will be considered UNSAFE. 
-- UNSAFE plans are NOT auto-parameterized and saved...meaning
-- they will get recompiled for each execution... PERFECT!

ALTER PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30)
) 
AS
DECLARE @ExecStr	VARCHAR (1000);
-- more sql1
-- etc...
SELECT @ExecStr = 'SELECT [m].* FROM [dbo].[member] AS [m] WHERE [m].[lastname] LIKE CONVERT (VARCHAR (15), ' 
	+ QUOTENAME (@LastName, '''') + N')';
	-- + REPLACE(@LastName, '''', '''''')
	-- For help on eliminating SQL Injection
	-- http://bit.ly/V1R3l5 (one then a lowercase L)
SELECT @ExecStr
--EXEC(@ExecStr);
-- more sql1
GO

-- Review the different plans and the more optimal I/Os
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
GO

-- Added in SQL Server 2005 - Use OPTION(RECOMPILE)
ALTER PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30)
)
AS
-- more sql1
-- more sql2
-- more sql3
-- etc...
SELECT [m].* FROM [dbo].[member] AS [m]
WHERE [m].[lastname] LIKE @LastName 
OPTION (RECOMPILE);
-- more sql1
-- more sql2
-- more sql3
-- etc...
GO

-- Review the different plans and the more optimal I/Os
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
EXEC [dbo].[GetMemberInfo] 'Anderson';
--EXEC [dbo].[GetMemberInfo] 'Test';
--EXEC [dbo].[GetMemberInfo] 'Foo';
EXEC [dbo].[GetMemberInfo] 'Chen';
EXEC [dbo].[GetMemberInfo] 'Dorr';
EXEC [dbo].[GetMemberInfo] 'Eflin';
EXEC [dbo].[GetMemberInfo] 'e%';
EXEC [dbo].[GetMemberInfo] '%e%';
GO

-- Added in SQL Server 2005 - Use OPTION(OPTIMIZE FOR)
ALTER PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30) 
)
AS
-- more sql1
-- more sql2
-- more sql3
-- etc...
SELECT [m].* FROM [dbo].[member] AS [m] 
WHERE [m].[lastname] LIKE @LastName 
--WHERE [m].[lastname] = @LastName 
OPTION (OPTIMIZE FOR (@Lastname = 'Anderson'));
-- more sql1
-- more sql2
-- more sql3
-- etc...
GO


-- Review the different plans and the more optimal I/Os
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
EXEC [dbo].[GetMemberInfo] 'Anderson';
EXEC [dbo].[GetMemberInfo] 'Chen';
EXEC [dbo].[GetMemberInfo] 'Dorr';
EXEC [dbo].[GetMemberInfo] 'Eflin';
EXEC [dbo].[GetMemberInfo] 'e%';
EXEC [dbo].[GetMemberInfo] '%e%';
go

DBCC SHOW_STATISTICS (N'member', N'MemberLastName');
GO

-- Added in SQL Server 2008 - Use 
--    OPTION(OPTIMIZE FOR UNKNOWN)

ALTER PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30)
)
AS
-- more sql1
-- more sql2
-- more sql3
-- etc...
SELECT [m].* FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @LastName 
--WHERE [m].[lastname] LIKE @LastName 
OPTION (OPTIMIZE FOR UNKNOWN);
-- Uses the "all density" (average) value from the statistics
-- more sql1
-- more sql2
-- more sql3
-- etc...
GO

EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
EXEC [dbo].[GetMemberInfo] 'Anderson';
EXEC [dbo].[GetMemberInfo] 'Chen';
EXEC [dbo].[GetMemberInfo] 'Dorr';
EXEC [dbo].[GetMemberInfo] 'Eflin';
EXEC [dbo].[GetMemberInfo] 'e%';
EXEC [dbo].[GetMemberInfo] '%e%';
GO


-- In earlier versions, you can simulate UNKNOWN with
-- by using variables instead of parameters
ALTER PROCEDURE [dbo].[GetMemberInfo]
(
	@LastName	VARCHAR (30) 
)
AS
DECLARE @LName  VARCHAR (30);
SELECT @LName = @LastName;
-- more sql1
-- more sql2
-- more sql3
-- etc...
SELECT [m].* 
FROM [dbo].[member] AS [m]
--WHERE [m].[lastname] = @LName
WHERE [m].[lastname] LIKE @LName;
-- more sql1
-- more sql2
-- more sql3
-- etc...
GO


-- Review the different plans and the more optimal I/Os
EXEC [dbo].[GetMemberInfo] 'Tripp';
EXEC [dbo].[GetMemberInfo] 'T%';
EXEC [dbo].[GetMemberInfo] '%T%';
EXEC [dbo].[GetMemberInfo] 'Anderson';
EXEC [dbo].[GetMemberInfo] 'Chen';
EXEC [dbo].[GetMemberInfo] 'Dorr';
EXEC [dbo].[GetMemberInfo] 'Eflin';
EXEC [dbo].[GetMemberInfo] 'e%';
EXEC [dbo].[GetMemberInfo] '%e%';
GO

-- For block recompilation, consider modularization

--Key points
--(1) Always make sure you test the 0, 1 and many case!
--(2) Use EXEC WITH RECOMPILE to see what the plans look like
--(3) Consider inline recompilation 
-- 		make sure you know it's requirements/limitations... 
--(4) Modularize the proc by creating a sub-procedure!!!