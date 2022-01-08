/*============================================================================
  File:     SQLskills_MostExpensiveQueries.sql

  Summary:  This script shows the 25 most expensive queries

  Date:     June 2010

  SQL Server Versions:
		10.0.2531.00 (SS2008 SP1)
		9.00.4035.00 (SS2005 SP3)
------------------------------------------------------------------------------
  Adapted by Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/
:Setvar SQLCMDMAXVARTYPEWIDTH 0
:Setvar SQLCMDHEADERS 5000

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULL_DFLT_ON ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ANSI_NULLS ON

SELECT '-- SQLskills_MostExpensiveQueries'

-- Based on code by Jimmy May
SELECT TOP 25
	qs.execution_count 
    , round (convert (float, qs.total_worker_time) / convert (float, qs.execution_count) / 1000.0, 1) as avg_worker_ms
    , qs.total_physical_reads / qs.execution_count as avg_phys_rds
    , qs.total_logical_reads  / qs.execution_count as avg_log_rds 
    , qs.total_logical_writes / qs.execution_count as avg_log_wrts
    , round (convert (float, qs.total_elapsed_time) / convert (float, qs.execution_count) / 1000.0, 1) as avg_elapsed_ms

      -- the following four columns are NULL for ad hoc and prepared batches
    ,  DB_Name(qp.dbid) as dbname , qp.dbid , qp.objectid , qp.number 
    , qp.query_plan --the query plan can be *very* useful; enable if desired
    , qt.text 
    , SUBSTRING(qt.text, (qs.statement_start_offset/2) + 1,
        ((CASE statement_end_offset 
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset END 
                - qs.statement_start_offset)/2) + 1) as statement_text
    , qs.creation_time , qs.last_execution_time ,     qs.total_clr_time       / qs.execution_count as avg_clr_time
    , qs.total_worker_time , qs.last_worker_time , qs.min_worker_time , qs.max_worker_time 
    , qs.total_physical_reads , qs.last_physical_reads , qs.min_physical_reads , qs.max_physical_reads 
    , qs.total_logical_reads , qs.last_logical_reads , qs.min_logical_reads , qs.max_logical_reads 
    , qs.total_logical_writes , qs.last_logical_writes , qs.min_logical_writes , qs.max_logical_writes 
    , qs.total_elapsed_time , qs.last_elapsed_time , qs.min_elapsed_time , qs.max_elapsed_time
    , qs.total_clr_time , qs.last_clr_time , qs.min_clr_time , qs.max_clr_time 
    --, qs.sql_handle , qs.statement_start_offset , qs.statement_end_offset 
    , qs.plan_generation_num  -- , qp.encrypted 
    FROM sys.dm_exec_query_stats as qs 
    CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
    --WHERE...
    where qs.total_worker_time    / qs.execution_count > 100000
    ORDER BY qs.execution_count      DESC  --Frequency
    --ORDER BY qs.total_worker_time    DESC  --CPU
    --ORDER BY qs.total_elapsed_time   DESC  --Durn
    --ORDER BY qs.total_logical_reads  DESC  --Reads 
    --ORDER BY qs.total_logical_writes DESC  --Writes
    --ORDER BY qs.total_physical_reads DESC  --PhysicalReads    
    --ORDER BY avg_worker_time         DESC  --AvgCPU
    --ORDER BY avg_elapsed_time        DESC  --AvgDurn     
    --ORDER BY avg_logical_reads       DESC  --AvgReads
    --ORDER BY avg_logical_writes      DESC  --AvgWrites
    --ORDER BY avg_physical_reads      DESC  --AvgPhysicalReads

    --sample WHERE clauses
    --WHERE last_execution_time > '20070507 15:00'
    --WHERE execution_count = 1
    --  WHERE SUBSTRING(qt.text, (qs.statement_start_offset/2) + 1,
    --    ((CASE statement_end_offset 
    --        WHEN -1 THEN DATALENGTH(qt.text)
    --        ELSE qs.statement_end_offset END 
    --            - qs.statement_start_offset)/2) + 1)
    --      LIKE '%MyText%'
