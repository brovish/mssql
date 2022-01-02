/*============================================================================
  Summary: Strange behavior when you manually UPDATE STATISTICS and
	the database-level option AUTO UPDATE STATISTICS is OFF.
  
  SQL Server Version: ONLY SQL Server 2005/2008/2008R2
	This does not happen on SQL Server 2012
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

-- Turn on Graphical Showplan


CREATE INDEX [test] 
ON [dbo].[member] ([lastname]);
GO

UPDATE [dbo].[member]
    SET [lastname] = 'Tripp'
    WHERE [member_no] = 1234;
GO

CREATE PROCEDURE [testrecompile]
(@lastname  VARCHAR (15))
AS
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @lastname;
GO

SET STATISTICS IO ON;
GO

EXEC [testrecompile] 'Tripp';
GO
-- plan uses the index

EXEC [testrecompile] 'Anderson';
GO
-- plan uses the index

UPDATE STATISTICS [member];
GO

sp_recompile [testrecompile];
GO

EXEC [testrecompile] 'Anderson';
GO
-- plan uses a table scan because the update statistics
-- invalidated the plan

ALTER DATABASE [Credit]
SET AUTO_UPDATE_STATISTICS OFF;
GO

EXEC [testrecompile] 'Tripp';
GO
-- uses an index because turning the option off forced 
-- invalidation

EXEC [testrecompile] 'Anderson';
GO
-- uses the index... 

UPDATE STATISTICS [member];
GO

EXEC [testrecompile] 'Anderson';
GO
-- STILL uses the index... this did NOT get updated!!!

-- This is a better fix (re: locking):
sp_recompile [testrecompile];
GO

-- An OK/easy fix (req: SCH_M):
sp_recompile [member];
GO

EXEC [testrecompile] 'Anderson';
GO
-- now, the plan does a table scan....
