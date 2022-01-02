/*============================================================================
  Summary: Conditional logic can be a nightmare with parameter 
	sensitivity issues. Modularization might be a much better choice;
	SQL Server never steps into a procedure unless it's actually
	executed.
  
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

-- Turn Graphical Showplan on, plus:
SET STATISTICS IO ON;
SET STATISTICS time ON;
go

--Review the structure and indexes on member
--sp_help 'dbo.member'
GO
-- Create a small number of rows where lastname is 'Tripp'
UPDATE [dbo].[member]
	SET [lastname] = 'Tripp'
		WHERE [member_no] IN (1234, 5678, 9876);
GO

-- UPDATE STATISTICS [member];
-- DBCC SHOW_STATISTICS (N'member', N'MemberLastName');
GO

-- Add an index to SEEK for LastNames
CREATE INDEX [MemberLastName] ON [dbo].[member] ([lastname]);
GO

IF OBJECTPROPERTY (OBJECT_ID (
	N'dbo.GetMemberNo'), N'IsProcedure') = 1
	DROP PROCEDURE [dbo].[GetMemberNo];
GO

CREATE PROCEDURE [dbo].[GetMemberNo]
(
	@MemberName		VARCHAR (30)
)
AS
IF @MemberName LIKE '%[%]%'
BEGIN
	PRINT 'Using the first select';
	SELECT [member_no]
		, [firstname]
		, [lastname]
		, [phone_no]
		, [region_no]
	FROM [dbo].[member]
	WHERE [lastname] LIKE @MemberName;
    -- OPTION (RECOMPILE) 
END
ELSE
BEGIN
	PRINT 'Using the second select';
	SELECT [member_no]
		, [firstname]
		, [lastname]
		, [phone_no]
		, [region_no]
	FROM [dbo].[member]
	WHERE [lastname] = @MemberName;
    -- OPTION (OPTIMIZE FOR...)
END
GO

-- The following execution should execute the SECOND select 
-- and therefore the FIRST should not be optimized?
EXEC [dbo].[GetMemberNo] 'Tripp';

-- This execution should generate the plan for the FIRST
-- select... Yet it doesn't. In the previous execution 
-- (even though the FIRST select was NOT executed) the 
-- first select was optimized using the parameters specified
-- on the first execution...
+

-- Basically, SQL Server optimizes the process of optimization
-- and doesn't actually know what will end up being executed.
-- So, they optimize EVERY statement that's optimizable!!

-- What's really a better idea?

-- One option would be to execute with recompile BUT this 
-- leaves too much up to chance
EXEC [dbo].[GetMemberNo] 'T%' WITH RECOMPILE;

-- A second option would be to CREATE with RECOMPILE
-- but the whole procedure doesn't need to be recompiled
-- and that was the original reason for splitting it into two
-- statements... so now what?

-- Consider using Dynamic String Execution for the wildcard
-- version...

-- This is a bit harder to write and if there's more code it 
-- wouldn't prevent the non-wildcard version from getting
-- optimized with a wildcard based parameter... Is there
-- no optimal way???

-- YES - modularize this code. Do not create large monolithic
-- procedures... Create smaller more modular code!!!

IF OBJECTPROPERTY (OBJECT_ID (
	N'dbo.GetMemberNoWithWC'), N'IsProcedure') = 1
	DROP PROCEDURE [dbo].[GetMemberNoWithWC];
GO

CREATE PROCEDURE [dbo].[GetMemberNoWithWC]
(
	@MemberName		VARCHAR (30)
) --WITH RECOMPILE      -- DO NOT USE THIS EVER!!!
AS
PRINT 'Using the Wildcard Procedure';
SELECT [m].[member_no]
	, [m].[firstname]
	, [m].[lastname]
	, [m].[phone_no]
	, [m].[region_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] LIKE @MemberName 
--OPTION (RECOMPILE);  -- If you want to recompile USE THIS!!
GO


IF OBJECTPROPERTY (OBJECT_ID (
	N'dbo.GetMemberNoWithOutWC'), N'IsProcedure') = 1
	DROP PROCEDURE [dbo].[GetMemberNoWithOutWC];
GO
CREATE PROCEDURE [dbo].[GetMemberNoWithOutWC]
(
	@MemberName		VARCHAR (30)
)
AS
PRINT 'Using the Procedure without a Wildcard';
SELECT [m].[member_no]
	, [m].[firstname]
	, [m].[lastname]
	, [m].[phone_no]
	, [m].[region_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @MemberName;
GO

IF OBJECTPROPERTY (OBJECT_ID (
	N'dbo.GetMemberNo'), N'IsProcedure') = 1
	DROP PROCEDURE [dbo].[GetMemberNo];
GO
CREATE PROCEDURE [dbo].[GetMemberNo]
(
	@MemberName		VARCHAR (30)
)
AS
SET NOCOUNT ON
IF @MemberName LIKE '%[%]%'
BEGIN
	EXEC [dbo].[GetMemberNoWithWC] @MemberName; -- WITH RECOMPILE
                                                -- DO NOT USE THIS EVER!!!
END
ELSE
BEGIN
	EXEC [dbo].[GetMemberNoWithoutWC] @MemberName;
END
GO

-- The plan for parameters that produce only a few rows is 
-- pretty consistent therefore the subproc does not use 
-- WITH RECOMPILE
EXEC [dbo].[GetMemberNo] 'Tripp';

-- The plan for parameters that vary significantly is 
-- NOT consistent therefore the subproc uses 
-- OPTION RECOMPILE
EXEC [dbo].[GetMemberNo] 'T%';  -- Table Scan
EXEC [dbo].[GetMemberNo] 'Tri%'; -- Index Seek + Bookmark Lookup
EXEC [dbo].[GetMemberNo] '%T%'; -- Table Scan
