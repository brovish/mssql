/*============================================================================
  Summary: Safe plans and plan guides. This one shows how a statement
	that accesses a single table can become "safe" when it's covered.
	However, it's still fairly unlikely that you will be able to
	rely on "safe" statements and auto-parameterization. For that 
	reason, I still recommend sp_executesql (when the statement's
	plan is STABLE) and stored procedures when the plan vary (using
	a variety of methods to handle the different types of data
	distribution scenarios). 
	
	This procedure also shows how to force templatized plan guides.    
    
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

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 back and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE [Credit];
GO

SET STATISTICS IO ON;
GO

-- These procedures are just so that we can easily see
-- information from cache without having to run the same
-- queries over and over again...

-- And, if you want to dive into the sizes and amount of
-- data in the cache:
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
GO 

-- 2008 adds query_hash and query_plan_hash
CREATE PROCEDURE [QuickCheckOnCacheWSizeAndPlan]
    @StringToFind   NVARCHAR (4000)
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
	CROSS APPLY sys.dm_exec_sql_text ([qs].[sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
WHERE [st].[text] LIKE @StringToFind 
	AND ([st].[text] NOT LIKE '%syscacheobjects%'
		OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY 1, [qs].[execution_count] DESC;
GO

-- Some quick setup for the example
UPDATE [member]	
SET [lastname] = 'Tripp' 
WHERE [member_no] = 1234;
GO

-- Index on lastnames
CREATE INDEX [MemberLastName] ON [member] ([Lastname]);
GO

-- What if we have a query that has different plans?
-- And, it's run frequently...

-- Run a few select statements:
SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Tripp';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Jones';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Smith';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Anderson';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Test';
GO

-- Before showing cache (through the sps)
-- review the inconsistent plans (some use an index,
-- others do a scan)

EXEC [QuickCheckOnCacheWSize] '%phone_no%lastname%';
EXEC [QuickCheckOnCacheWSizeAndPlan]  '%phone_no%lastname%';
-- See that the query_hash is the same
-- But, check out the query_plan_hash; this statement
-- has two plans...
-- It's definitely NOT safe!
GO

--------------------------------------------------------
-- What if we can create a "SAFE" and consistent plan?
-- In this case, we might have single plan because of a
-- covering index...
--------------------------------------------------------

-- DROP INDEX [member].[FullNameIndex]
CREATE INDEX [FullNameIndex] 
ON [member] ([lastname])
INCLUDE ([firstname], [phone_no]);
GO

sp_recompile [member]; -- Sch-M on that table!
GO

-- Re-run the same select statements:
SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Tripp';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Jones';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Smith';
go

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Anderson';
GO

SELECT [m].[lastname], [m].[firstname], [m].[phone_no]
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Test';
GO
-- Before showing cache (through the sps)
-- review the CONSISTENT plans (all use the nonclustered, 
-- covering, seekable index)

EXEC [QuickCheckOnCacheWSize] '%phone_no%lastname%';
EXEC [QuickCheckOnCacheWSizeAndPlan]  '%phone_no%lastname%';
-- See that the query_hash is the same
-- And, now there's ONLY one plan is cache... wait, why only one?
-- This is ONLY one table... it's pretty simple and we actually
-- meet the definition of SAFE (wow, shocking! :))

-- **THIS** query is NOW safe!
GO

-- But, what if we had a bit more complicated statement:

-- Create an index to make it a very stable/consistent plan:
CREATE INDEX [ChargesByMember] 
ON [charge] ([member_no], [charge_amt]);
GO

-- Next, run a few statements:
SELECT [m].[lastname], [m].[firstname], MIN ([charge_amt])
FROM [dbo].[member] AS [m]
	JOIN [dbo].[charge] AS [c]
		ON [m].[member_no] = [c].[member_no]
WHERE [m].[lastname] = 'Test' AND [m].[firstname] = 'Bob'
GROUP BY [m].[lastname], [m].[firstname];
GO

SELECT [m].[lastname], [m].[firstname], MIN ([charge_amt])
FROM [dbo].[member] AS [m]
	JOIN [dbo].[charge] AS [c]
		ON [m].[member_no] = [c].[member_no]
WHERE [m].[lastname] = 'Tripp' AND [m].[firstname] = 'RFCLXE'
GROUP BY [m].[lastname], [m].[firstname];
GO

SELECT [m].[lastname], [m].[firstname], MIN ([charge_amt])
FROM [dbo].[member] AS [m]
	JOIN [dbo].[charge] AS [c]
		ON [m].[member_no] = [c].[member_no]
WHERE [m].[lastname] = 'Anderson'
	AND [m].[firstname] = 'ITZMOIWZGCSQLO'
GROUP BY [m].[lastname], [m].[firstname];
GO

-- Before showing cache (through the sps)
-- review the CONSISTENT plans (all use the TWO nonclustered, 
-- covering, seekable index)

EXEC [QuickCheckOnCacheWSize] '%charge_amt%';
EXEC [QuickCheckOnCacheWSizeAndPlan] '%charge_amt%';
-- See that the query_hash is the same
-- OK, this one IS STABLE but it's not "safe" 
-- How do we deal with this - a plan guide....
GO

-----------------------------------------------------------------
-- But, what if all of our plans are stable?

-- If all of our queries were stable then we could use
-- the FORCED parameterization at the database-level.

-- But, this is less likely. As an alternative, you 
-- can also use this "plan guides" in SQL Server 2008+

DECLARE @StableQuery NVARCHAR (MAX);
DECLARE @Parameters NVARCHAR (MAX);

EXEC sp_get_query_template 
	N'SELECT [m].[lastname], [m].[firstname], MIN ([charge_amt])
	FROM [dbo].[member] AS [m]
	JOIN [dbo].[charge] AS [c]
		ON [m].[member_no] = [c].[member_no]
	WHERE [m].[lastname] = ''Anderson''
		AND [m].[firstname] = ''ITZMOIWZGCSQLO''
	GROUP BY [m].[lastname], [m].[firstname]',
    @StableQuery  OUTPUT, -- Parameterized Version of the query
    @Parameters OUTPUT;

SELECT @StableQuery, @Parameters

EXEC sp_create_plan_guide 
    N'Member+Charge: Min charge by Member Name', 
	  -- you'll want to come up with a standard naming convention
    @StableQuery, 
    N'TEMPLATE', 
    NULL, 
    @Parameters, 
    N'OPTION (PARAMETERIZATION FORCED)';
GO

SELECT * FROM sys.plan_guides;
GO

sp_control_plan_guide N'enable',
	N'Member+Charge: Min charge by Member Name';
GO

-- Testing validity of plan_guides (When empty result 
-- set is returned, all plan guides are valid.)
SELECT [plan_guide_id], [msgnum], [severity], [state], [message]
FROM sys.plan_guides
CROSS APPLY fn_validate_plan_guide ([plan_guide_id]);
GO

-- DROP INDEX [charge].[ChargesByMember]
-- Plan is STILL VALID if you remove the index because
-- forced only affected whether or not it's cached - not
-- HOW it's processed.

SELECT * FROM sys.dm_exec_query_stats
	CROSS APPLY sys.dm_exec_sql_text ([plan_handle])
	WHERE [text] LIKE '%lastname%firstname%';
GO

SELECT [objtype], [dbid], [usecounts], [sql]
FROM sys.syscacheobjects
WHERE [cacheobjtype] = N'Compiled Plan';
GO

SELECT * FROM sys.dm_exec_cached_plans;
SELECT * FROM sys.dm_exec_query_optimizer_info;

-- What about an unstable plan?
DECLARE @UnstableQuery NVARCHAR (MAX);
DECLARE @Parameters NVARCHAR (MAX);

EXEC sp_get_query_template 
    N'unstable query',  -- you only need to do this if the 
			-- database is set to PARAMETERIZATION FORCED
    @UnstableQuery OUTPUT, -- this is the templatized version...
    @Parameters OUTPUT;

EXEC sp_create_plan_guide 
    N'name', -- come up with a standard naming convention
    @UnstableQuery, 
    N'TEMPLATE', 
    NULL, 
    @Parameters, 
    N'OPTION(PARAMETERIZATION SIMPLE)';

SELECT @UnstableQuery, @Parameters;
GO