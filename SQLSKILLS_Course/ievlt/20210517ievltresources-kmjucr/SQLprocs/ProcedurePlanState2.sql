-----------------------------------------------------------------------
-- Course: SQL Server: Optimizing Stored Procedure Performance - Part 2
-- Module: Session Settings (Section 2)
--   Demo: Plan cache attributes and execute state
-----------------------------------------------------------------------

USE [Credit];
GO

IF OBJECT_ID('[dbo].[ProcedurePlanState2]') IS NOT NULL
    DROP PROCEDURE [dbo].[ProcedurePlanState2];
GO

CREATE PROCEDURE [dbo].[ProcedurePlanState2]
    (@SchemaName    sysname,
     @ObjectName    sysname)
AS    
SELECT 
      ISNULL(db_name([ps].[database_id]), 'resourcedb') 
            AS [Database Name]

    , CASE 
        WHEN db_name([ps].[database_id]) IS NOT NULL 
            THEN OBJECT_SCHEMA_NAME([ps].[object_id], [ps].[database_id]) 
        ELSE OBJECT_SCHEMA_NAME([ps].[object_id])
        END AS [Schema Name]

    , CASE 
        WHEN db_name([ps].[database_id]) IS NOT NULL 
            THEN OBJECT_NAME([ps].[object_id], [ps].[database_id])
        ELSE OBJECT_NAME([ps].[object_id])
        END AS [Object Name]

	, [ps].[execution_count] 
            AS [Exec Count]

	, [SetOpts].[value] 
            AS [SetOpts]

	-- Causes recompilation
	, CASE WHEN CONVERT(int, [SetOpts].[value]) & 128 = 128 
        THEN 'ON' ELSE 'OFF' END AS [ANSI_NULL_DFLT_ON]		    
	
    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 256 = 256 
        THEN 'ON' ELSE 'OFF' END AS [ANSI_NULL_DFLT_OFF]	    

	, CASE WHEN CONVERT(int, [SetOpts].[value]) & 1 = 1 
        THEN 'ON' ELSE 'OFF' END AS [ANSI_PADDING]			    
	
    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 16 = 16 
        THEN 'ON' ELSE 'OFF' END AS [ANSI_WARNINGS]			    
	
    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 4096 = 4096 
        THEN 'ON' ELSE 'OFF' END AS [ARITHABORT]			    

	, CASE WHEN CONVERT(int, [SetOpts].[value]) & 8 = 8 
        THEN 'ON' ELSE 'OFF' END AS [CONCAT_NULL_YIELDS_NULL]	

	, CASE WHEN CONVERT(int, [SetOpts].[value]) & 4 = 4 
        THEN 'ON' ELSE 'OFF' END AS [FORCEPLAN]					

    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 512 = 512 
        THEN 'ON' ELSE 'OFF' END AS [NoBrowseTable]			    
        -- 512: Indicates that the plan does not use a work table 
        -- to implement a FOR BROWSE operation.
	
    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 8192 = 8192 
        THEN 'ON' ELSE 'OFF' END AS [NUMERIC_ROUNDABORT]	    

    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 262144 = 262144 
        THEN 'ON' ELSE 'OFF' END AS [ROWCOUNT]		            
        -- 262144: Indicates non-zero ROWCOUNT

	-- Language / Date Format / Date First
    --, CASE WHEN CONVERT(int, pa.value) & 65536 = 65536 
    --      THEN 'ON' ELSE 'OFF' END AS [LanguageID]		
    -- Doesn't actually get set...

    , [sl].[name] AS [Language]
	
    --, CASE WHEN CONVERT(int, pa.value) & 16384 = 16384 
    --      THEN 'ON' ELSE 'OFF' END AS [DATEFIRST]		    
    -- Doesn't actually get set...

    -- Actual DATEFIRST setting
    , CASE WHEN CONVERT(int, [DFirst].[value]) <> 7 
       THEN [DFirst].[value] ELSE 'Default (7)' END AS [DATEFIRST]		
        
	--, CASE WHEN CONVERT(int, pa.value) & 32768 = 32768 
    --      THEN 'ON' ELSE 'OFF' END AS [DATEFORMAT]		
    -- Doesn't actually get set...
    
    -- Actual DATEFORMAT setting
    , CASE WHEN [DFmt].[value] = 1 THEN 'mdy'
           WHEN [DFmt].[value] = 2 THEN 'dmy'
           WHEN [DFmt].[value] = 3 THEN 'ymd'
           WHEN [DFmt].[value] = 4 THEN 'ydm'
           WHEN [DFmt].[value] = 5 THEN 'myd'
           WHEN [DFmt].[value] = 6 THEN 'dym'
           ELSE [DFmt].[value] END AS [DATEFORMAT]
	
	-- Just CREATE TIME indicator bits (no recompilation)
	, CASE WHEN CONVERT(int, [SetOpts].[value]) & 32 = 32 
        THEN 'ON' ELSE 'OFF' END AS [ANSI_NULLS]			

    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 64 = 64 
        THEN 'ON' ELSE 'OFF' END AS [QUOTED_IDENTIFIER]		
    
    -- Others of interest
    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 2 = 2 
        THEN 'ON' ELSE 'OFF' END AS [Parallel Plan]			

    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 1024 = 1024 
        THEN 'ON' ELSE 'OFF' END AS [TriggerOneRow]		    
        -- 1024: Indicates that the plan contains single row 
        -- optimization for AFTER trigger delta tables.

	, CASE WHEN CONVERT(int, [SetOpts].[value]) & 131072 = 131072 
        THEN 'ON' ELSE 'OFF' END AS [PARAM FORCED]			
        -- 131072: Indicates that the database option 
        -- PARAMETERIZATION was set to FORCED when the plan was compiled.

    , CASE WHEN CONVERT(int, [SetOpts].[value]) & 2048 = 2048 
        THEN 'ON' ELSE 'OFF' END AS [ResyncQuery]			
        -- 2048: Indicates that the query was submitted by internal 
        -- system stored procedures.

    , [pool].[name] AS [Resource Governor Pool Name]

	, [qp].[query_plan]

FROM [sys].[dm_exec_procedure_stats] AS [ps]
	INNER JOIN [sys].[dm_exec_cached_plans] AS [cp]
		ON [ps].[plan_handle] = [cp].[plan_handle]
    INNER JOIN [sys].[dm_resource_governor_resource_pools] AS [pool]
        ON [cp].[pool_id] = [pool].[pool_id]
	CROSS APPLY [sys].[dm_exec_plan_attributes] ([ps].[plan_handle]) AS [SetOpts]
    CROSS APPLY [sys].[dm_exec_plan_attributes] ([ps].[plan_handle]) AS [DFirst]
    CROSS APPLY [sys].[dm_exec_plan_attributes] ([ps].[plan_handle]) AS [DFmt]
    CROSS APPLY sys.dm_exec_query_plan ([cp].[plan_handle]) AS [qp]
	CROSS APPLY [sys].[dm_exec_plan_attributes] ([ps].[plan_handle]) AS [Lang]
    INNER JOIN [sys].[syslanguages] AS [sl] 
        ON [Lang].[value] = [sl].[langid]
	
WHERE [SetOpts].[attribute] = ('set_options')
    AND [DFirst].[attribute] = ('date_first')
    AND [DFmt].[attribute] = ('date_format')
    AND [Lang].[attribute] = ('language_id')
	AND [ps].[database_id] = DB_ID()
    AND OBJECT_NAME([ps].[object_id]) = @ObjectName
    AND OBJECT_SCHEMA_NAME([ps].[object_id]) = @SchemaName
ORDER BY [Database Name], [Object Name], [ps].[cached_time];
GO