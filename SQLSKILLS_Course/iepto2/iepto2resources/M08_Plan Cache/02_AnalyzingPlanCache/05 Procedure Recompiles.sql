USE [Credit];
GO

-- Some quick setup
UPDATE [member]	
SET [lastname] = 'Tripp' 
WHERE [member_no] = 1234;
GO

CREATE INDEX [MemberLastName]
ON [dbo].[member] ([lastname])
GO

-- Drop / recreate the test procedures
IF OBJECT_ID('GetLastName') IS NOT NULL
    DROP PROCEDURE GetLastName
GO

IF OBJECT_ID('GetLastNameOpRecompile') IS NOT NULL
    DROP PROCEDURE GetLastNameOpRecompile
GO

IF OBJECT_ID('GetLastNameProcRecompile') IS NOT NULL
    DROP PROCEDURE GetLastNameProcRecompile
GO

-- No recompiles
GO

CREATE PROCEDURE GetLastName
    ( @Lastname varchar(15) )
AS
SELECT * 
FROM member AS mem123
WHERE lastname = @Lastname;
GO

-- Statement-level recompiles
GO

CREATE PROCEDURE GetLastNameOpRecompile
    ( @Lastname varchar(15) )
AS
SELECT * 
FROM member AS mem456
WHERE lastname = @Lastname
OPTION (RECOMPILE);
GO

-- Procedure-level recompiles
GO

CREATE PROCEDURE GetLastNameProcRecompile
    ( @Lastname varchar(15) )
WITH RECOMPILE
AS
SELECT * 
FROM member AS mem789
WHERE lastname = @Lastname;
GO

-- Execute the scenarios
GO

SET STATISTICS IO, TIME ON;
GO

EXEC GetLastName 'Tripp';
GO

EXEC GetLastNameOpRecompile 'Tripp';
GO

EXEC GetLastNameProcRecompile 'Tripp';
GO

-- Now, where / how can we see this?

-- Code executed in procedures created w/RECOMPILE 
-- is not visible through:
--    sys.dm_exec_procedure_stats
--    sys.dm_exec_query_stats

-- Check sys.dm_exec_query_stats
GO
 
SELECT [st].[text], [qs].[execution_count], [qs].*, [p].* 
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) [p]
WHERE [st].[text] LIKE '%member as mem%'
ORDER BY 1, [qs].[execution_count] DESC;
GO

-- Execute the scenarios
GO

EXEC GetLastName 'Anderson';
GO

EXEC GetLastNameOpRecompile 'Anderson';
GO

EXEC GetLastNameProcRecompile 'Anderson';
GO

SELECT [st].[text], [qs].[execution_count], [qs].*, [p].* 
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) [p]
WHERE [st].[text] LIKE '%member as mem%'
ORDER BY 1, [qs].[execution_count] DESC;
GO


-----------------------------------------------------------------------
-- The following proc is from Kimberly's Pluralsight course
-- Optimizing Stored Procedure Performance - Part 1
--
-- Please review that course for more information on 
-- this script and other associated demos but you can
-- also use it with our discussion from IEPTO2 on 
-- CREATE w/RECOMPILE vs. OPTION (RECOMPILE)

-- What you really need to do is watch for the module
-- on Creation, Compilation, and Invalidation

-----------------------------------------------------------------------
-- Course: SQL Server: Optimizing Stored Procedure Performance - Part 1
-- Module: Creation, Compilation, and Invalidation
--   Demo: Credit Sample Database Setup Analysis Procedures
-----------------------------------------------------------------------
GO

SELECT OBJECT_NAME([ps].[object_id], [ps].[database_id]) 
            AS [ProcedureName]
	, [ps].[execution_count] AS [ProcedureExecutes]
	, [qs].[plan_generation_num] AS [VersionOfPlan]
	, [qs].[execution_count] AS [ExecutionsOfCurrentPlan]
	, SUBSTRING ([st].[text], 
		([qs].[statement_start_offset] / 2) + 1, 
	    ((CASE [statement_end_offset] 
			WHEN -1 THEN DATALENGTH ([st].[text]) 
		    ELSE [qs].[statement_end_offset] END 
			- [qs].[statement_start_offset]) / 2) + 1) 
		    AS [StatementText]
    , [qs].[statement_start_offset] AS [offset]
    , [qs].[statement_end_offset] AS [offset_end]
    , [qp].[query_plan] AS [Query Plan XML]
    , [qs].[query_hash] AS [Query Fingerprint]
    , [qs].[query_plan_hash] AS [Query Plan Fingerprint]
FROM [sys].[dm_exec_procedure_stats] AS [ps]
	INNER JOIN [sys].[dm_exec_query_stats] AS [qs]
		ON [ps].[plan_handle] = [qs].[plan_handle]
    CROSS APPLY [sys].[dm_exec_query_plan] 
                        ([qs].[plan_handle]) AS [qp]
	CROSS APPLY [sys].[dm_exec_sql_text] 
                        ([qs].[sql_handle]) AS [st]
WHERE [ps].[database_id] = DB_ID()
ORDER BY [ProcedureName]
	, [qs].[statement_start_offset];
GO

-- Not there either........

-- Any other easy way? Just check to see if there are ANY procedures
-- created WITH RECOMPILE
GO

SELECT OBJECT_NAME([object_id], db_id()) 
            AS [ProcedureName]
     , [is_recompiled]
FROM [sys].[sql_modules]
WHERE [is_recompiled] = 1;
GO