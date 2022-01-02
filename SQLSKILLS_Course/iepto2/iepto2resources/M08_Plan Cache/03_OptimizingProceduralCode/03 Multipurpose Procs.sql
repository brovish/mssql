/*============================================================================
  Summary: Multipurpose procs... very common and HORRIBLE for SQL
	Server to optimize. Be VERY careful with these procedures and
	if OSFA (one-size-fits-all) procs are desired - then build the
	statement dynamically and then choose the final setting:
		to recompile 
		to cache
  
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

-- Add an index to SEEK for LastNames
CREATE INDEX [MemberFirstName] 
ON [dbo].[member] ([firstname]);
GO

-- Add an index to SEEK for LastNames
CREATE INDEX [MemberLastName] 
ON [dbo].[member] ([lastname]);
GO

sp_helpindex [member];
GO

UPDATE [dbo].[member]
	SET [lastname] = 'Tripp'
	WHERE [member_no] = 1234;
GO

UPDATE [dbo].[member]
	SET [firstname] = 'Kimberly'
	WHERE [member_no] = 2479;
GO

IF OBJECTPROPERTY (OBJECT_ID (
	N'GetMemberInfoParam'), N'IsProcedure') = 1
	DROP PROCEDURE [GetMemberInfoParam];
GO

CREATE PROC [GetMemberInfoParam]
	@Lastname	VARCHAR (15) = NULL,
	@Firstname	VARCHAR (15) = NULL,
	@member_no	INT = NULL
AS
SELECT [m].* FROM [dbo].[member] AS [m]
WHERE ([m].[lastname] LIKE @lastname OR @lastname IS NULL)
	AND ([m].[member_no] = @member_no OR @member_no IS NULL)
	AND ([m].[firstname] LIKE @firstname OR @firstname IS NULL);
GO

--sp_recompile [GetMemberInfoParam];	

EXEC [GetMemberInfoParam] @Lastname = 'Tripp';
GO

EXEC [GetMemberInfoParam] @Firstname = 'Kimberly';
GO

EXEC [GetMemberInfoParam] @Member_no = 9912;
GO

-- What about with OPTION (RECOMPILE)??
ALTER PROC [GetMemberInfoParam]
	@Lastname	varchar(15) = NULL,
	@Firstname	varchar(15) = NULL,
	@member_no	int = NULL
AS
SELECT [m].* FROM [dbo].[member] AS [m]
WHERE ([m].[lastname] LIKE @lastname OR @lastname IS NULL)
	AND ([m].[member_no] = @member_no OR @member_no IS NULL)
	AND ([m].[firstname] LIKE @firstname OR @firstname IS NULL)
	OPTION (RECOMPILE);
	-- Note: this gets you a MUCH more optimal plan in 2008 R2 SP2+
    -- but it's requires too much CPU especially for stable combinations
	-- Therefore it's not ideal (nor is OPTION (RECOMPILE) consistent 
    -- across versions; it has a very checkered past so it makes me
    -- nervous.)
GO

EXEC [GetMemberInfoParam] @Lastname = 'Tripp';
GO

EXEC [GetMemberInfoParam] @Firstname = 'Kimberly';
GO

EXEC [GetMemberInfoParam] @Member_no = 9912;
GO

EXEC [GetMemberInfoParam] @Member_no = 4567;
GO

-- What about Dynamic String Execution:
CREATE PROC [GetMemberInfoParam2]
	@Lastname	VARCHAR (15) = NULL,
	@Firstname	VARCHAR (15) = NULL,
	@member_no	INT = NULL
AS
DECLARE @ExecStr	NVARCHAR (1000);
SELECT @ExecStr = 
	N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE 1=1 ' ;

IF @LastName IS NOT NULL
	SELECT @ExecStr = @ExecStr +
		N'AND [m].[lastname] LIKE CONVERT (VARCHAR (15), '
		+ QUOTENAME (@lastname, '''') + N') ';

IF @FirstName IS NOT NULL
	SELECT @ExecStr = @ExecStr +
		N'AND [m].[firstname] LIKE CONVERT (VARCHAR (15), '
		+ QUOTENAME (@firstname, '''') + N') ';

IF @Member_no IS NOT NULL
	SELECT @ExecStr = @ExecStr +
		N'AND [m].[member_no] = CONVERT (INT, ' 
		+ CONVERT (VARCHAR (5), @member_no) + N') ';

SELECT (@ExecStr);
EXEC(@ExecStr);
GO

EXEC [GetMemberInfoParam2] @Lastname = 'Tripp'
	, @FirstName = 'Kimberly';
GO

EXEC [GetMemberInfoParam2] @Firstname = 'Kimberly';
GO

EXEC [GetMemberInfoParam2] @Firstname = 'Kimberly'
	, @Member_no = 842;
GO

EXEC [GetMemberInfoParam2] @Member_no = 9912;
GO

EXEC [GetMemberInfoParam2] @Lastname = 'Florini'
	, @Member_no = 9912;
GO

-- Instead - using sp_executesql
-- if the majority of parameters are stable then sp_executesql 
-- can be great... for the parameters that are unstable 
-- then add OPTION (RECOMPILE)

-- And, if there's a single parameter that will guarantee a 
-- highly selective set you can turn off the @Recompile flag 
-- by placing it add the end of the list!

CREATE PROC [GetMemberInfoParam3]
(	@Lastname	VARCHAR (15) = NULL,
	@Firstname	VARCHAR (15) = NULL,
	@member_no	INT = NULL)
AS
IF @LastName IS NULL AND @FirstName IS NULL AND @Member_no IS NULL
	RAISERROR ('You must supply at least one parameter.', 16, -1);

DECLARE @ExecStr	NVARCHAR (4000)
		, @Recompile	bit = 1
       
SELECT @ExecStr =
	N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE 1=1';

IF @LastName IS NOT NULL
	SELECT @ExecStr = @ExecStr 
		+ N' AND [m].[lastname] LIKE @Lname'; 

IF @FirstName IS NOT NULL
	SELECT @ExecStr = @ExecStr 
		+ N' AND [m].[firstname] LIKE @Fname';

IF @Member_no IS NOT NULL
	SELECT @ExecStr = @ExecStr 
		+ N' AND [m].[member_no] = @Memno';

IF @member_no IS NOT NULL
	SELECT @Recompile = 0

IF @Recompile = 1
    SELECT @ExecStr = @ExecStr + N' OPTION(RECOMPILE)';
    
SELECT @ExecStr, @Lastname, @Firstname, @member_no;

EXEC sp_executesql @ExecStr
    , N'@Lname varchar(15), @Fname varchar(15), @Memno int'
	, @Lname = @Lastname
	, @Fname = @Firstname
	, @Memno = @Member_no;
GO

EXEC [GetMemberInfoParam3] 'Tripp', 'Kimberly';
GO

EXEC [GetMemberInfoParam3] @Firstname = 'Kimberly';
GO

EXEC [GetMemberInfoParam3] @Firstname = 'Kimberly'
	, @Member_no = 842;
GO

EXEC [GetMemberInfoParam3] @Member_no = 9912;
GO

EXEC [GetMemberInfoParam3] @Lastname = 'Florini'
	, @Member_no = 9912;
GO

-- This is another example of a frequently asked version...
-- This does not create an optimal plan either.
CREATE PROC [GetMemberInfoParam4]
	@Lastname	VARCHAR (30) = NULL,
	@Firstname	VARCHAR (30) = NULL,
	@member_no	INT = NULL
AS
SELECT [m].* FROM [dbo].[member] AS [m]
WHERE [m].[lastname] =
	CASE WHEN @lastname IS NULL THEN [m].[lastname]
			ELSE @lastname
	END
	AND [m].[firstname] =
	CASE WHEN @firstname IS NULL THEN [m].[firstname]
			ELSE @firstname
	END
	AND [m].[member_no] =
	CASE WHEN @member_no IS NULL THEN [m].[member_no]
			ELSE @member_no
	END;
GO

EXEC [GetMemberInfoParam4] 
	@Lastname = 'test'
	, @FirstName = 'Kimberly';
GO

EXEC [GetMemberInfoParam4] 
	@Firstname = 'Kimberly' WITH RECOMPILE;
GO

EXEC [GetMemberInfoParam4] 
	@Firstname = 'Kimberly'
	, @Member_no = 842 WITH RECOMPILE;
GO

EXEC [GetMemberInfoParam4] 
	@Member_no = 9912 WITH RECOMPILE;
GO

EXEC [GetMemberInfoParam4] 
	@Lastname = 'Florini'
	, @Member_no = 9912 WITH RECOMPILE;
GO