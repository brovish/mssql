/*============================================================================
  File:     02_ComparePerf.sql

  SQL Server Versions: 2016, 2017, 2019, Azure SQL DB
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2020, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [WideWorldImporters];
GO

/*
	Create SP to use for testing
*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Application].[usp_GetPersonInfoMetrics];
GO

CREATE PROCEDURE [Application].[usp_GetPersonInfoMetrics] (@PersonID INT)
AS

	SELECT 
		[p].[FullName], 
		[p].[EmailAddress], 
		[c].[FormalName]
	FROM [Application].[People] [p]
	LEFT OUTER JOIN [Application].[Countries] [c] 
		ON [p].[PersonID] = [c].[LastEditedBy]
	WHERE [p].[PersonID] = @PersonID;
GO

/*
	Create XE session again to capture 
	sql_statement_completed	and sp_statement_completed
	AND query_post_execution_showplan (use with caution!)
*/
IF EXISTS (
	SELECT * 
	FROM sys.server_event_sessions
	WHERE [name] = 'QueryPerf')
BEGIN
	DROP EVENT SESSION [QueryPerf] ON SERVER;
END
GO

CREATE EVENT SESSION [QueryPerf] 
	ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
	WHERE ([duration]>(1000))),
ADD EVENT sqlserver.sql_statement_completed(
	WHERE ([duration]>(1000))),
ADD EVENT sqlserver.query_post_execution_showplan
ADD TARGET package0.event_file(
	SET filename=N'C:\Temp\QueryPerf',max_file_size=(256))
WITH (
	MAX_MEMORY=16384 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF);
GO


/*
	Check that Query Store is enabled
*/
SELECT 
	[actual_state_desc], 
	[readonly_reason], 
	[desired_state_desc], 
	[current_storage_size_mb], 
    [max_storage_size_mb], 
	[flush_interval_seconds], 
	[interval_length_minutes], 
    [stale_query_threshold_days], 
	[size_based_cleanup_mode_desc], 
    [query_capture_mode_desc], 
	[max_plans_per_query]
FROM [sys].[database_query_store_options];
GO

/*
	Remove everything from the plan cache
*/
DBCC FREEPROCCACHE;
GO

/*
	Start session
*/
ALTER EVENT SESSION [QueryPerf] 
	ON SERVER
	STATE = START;
GO

/*
	Copy below to a separate window 
	We want to keep SSMS query output separate 
	from our demo code
*/

/*
	Enable stats
*/
SET STATISTICS IO ON;
GO
SET STATISTICS TIME ON;
GO
SET STATISTICS XML ON;
GO

/*
	Enable client statistics (toolbar)
*/

/*
	Run SP and query one time
*/
USE [WideWorldImporters];
GO

EXECUTE [Application].[usp_GetPersonInfoMetrics] 1234;
GO

SELECT 
	[s].[StateProvinceName], 
	[s].[SalesTerritory], 
	[s].[LatestRecordedPopulation], 
	[s].[StateProvinceCode]
FROM [Application].[Countries] [c]
JOIN [Application].[StateProvinces] [s]
	ON [s].[CountryID] = [c].[CountryID]
WHERE [c].[CountryName] = 'United States';
GO


/*
	Stop event session
*/
ALTER EVENT SESSION [QueryPerf] 
	ON SERVER
	STATE = STOP;
GO



/*
	IN ANOTHER WINDOW, look at data in 
	XE, cache, and Query Store
	(SSMS data already in another window)
*/


/*
	Query for cache
*/
SELECT
	[qs].[last_execution_time],
	[qs].[execution_count],
	[qs].[total_elapsed_time],
	[qs].[total_elapsed_time]/[qs].[execution_count] [AvgDuration],
	[qs].[total_logical_reads],
	[qs].[total_logical_reads]/[qs].[execution_count] [AvgLogicalReads],
	[t].[text],
	[p].[query_plan]
FROM sys.dm_exec_query_stats [qs]
CROSS APPLY sys.dm_exec_sql_text([qs].sql_handle) [t]
CROSS APPLY sys.dm_exec_query_plan([qs].[plan_handle]) [p]
WHERE [t].[text] LIKE '%Countries%';
GO


/*
	Query for Query Store
*/
USE [WideWorldImporters];
GO

SELECT 
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	[rs].[count_executions],
	[rs].[avg_logical_io_reads], 
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qst].[query_sql_text] LIKE '%Countries%'; 
GO


/*
	Now look at options for comparing performance data
*/

/*
	Clean up
*/
DROP EVENT SESSION [QueryPerf] 
	ON SERVER;
GO
