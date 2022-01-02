/*============================================================================
  Summary: Using a variable to simulate optimize for unknown plus a 
	server-wide trace flag for disabling parameter sniffing (NOT
	generally recommended).
  
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

-- Some setup:
UPDATE [member] 
    SET [lastname] = 'TRIPP' 
    WHERE [member_no] = 123;
GO

CREATE INDEX MemberLastName ON [member] ([lastname]);
GO

-- This proc is a typical proc...
CREATE PROC [proc_w_Parameter]
    @lname  VARCHAR (15)
AS
SELECT * 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @lname;
GO

sp_SQLskills_helpindex member;
go

DBCC SHOW_STATISTICS (N'member', N'MemberLastName')
WITH HISTOGRAM;
GO

-- On first execution, SQL Server uses parameter sniffing...
-- This is GOOD for the first execution as the 
-- estimate is correct and SQL Server chooses 
-- the right plan for this value.
EXEC [proc_w_Parameter] 'Tripp';
GO

-- However, what if you supply a different value?
-- Since the plan was already determined by the first execution
-- then we're GOing to get THAT plan. Is that GOod for this
-- value? Maybe... but, maybe not? This is where parameter
-- sniffing becomes a problem!
EXEC [proc_w_Parameter] 'Anderson';
GO

-- One solution that people found is to "obfuscate" the
-- parameter coming in...

-- This procedure uses a variable inside the procedure 
-- to "trick" SQL Server at optimization/compilation time.
-- This turns the parameter into an "unknown" value and
-- as a result - SQL Server cannot "sniff" the incoming
-- value.
CREATE PROC [proc_w_Variable]
    @lname  VARCHAR (15)
AS
DECLARE @lastname   VARCHAR (15);
SELECT @lastname = @lname;
SELECT * 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @lastname;
GO

EXEC [proc_w_Variable] 'tripp';
GO
-- estimate is incorrect. SQL Server chose a
-- plan based on the density vector (the all density)
-- which is the "AVERAGE"

DBCC SHOW_STATISTICS (N'member', N'MemberLastName');
--WITH HISTOGRAM
GO

EXEC [proc_w_Variable] 'anderson';
GO
-- Here we get a "better" plan for this parameter...

-- What SQL Server is doing is getting the "average" plan...
-- If we actually look at the data, you'll find that 'Tripp'
-- is the anomalie. So, it might actually be preferred to
-- use the "average" plan. To simplify this process, they
-- added a new statement hint in SQL Server 2008.

-- In SQL Server 2008
CREATE PROC [proc_w_OptUnknown]
    @lname  VARCHAR (15)
AS
SELECT * 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @lname
OPTION (OPTIMIZE FOR UNKNOWN);
GO

EXEC [proc_w_OptUnknown] 'tripp';
GO

EXEC [proc_w_OptUnknown] 'anderson';
GO

-- There are cases where the average plan is Good enough. 
-- But, you need to be careful because those that would
-- not have been optimal with the average plan might be
-- very slow.
-- 
-- And, don't forget the other options...

-- OPTION (RECOMPILE)
-- OPTION (OPTIMIZE FOR ( ))

-- Finally, there is a way to disable parameter sniffing 
-- SERVER-WIDE (not recommended) using Trace Flag 4136

-- http://support.microsoft.com/kb/980653 

-- If this trace flag is on then parameter sniffing will be
-- turned off and all code will use the density vector
-- for optimization. It's as if you added OPTIMIZE FOR UNKNOWN
-- to ALL of your code.