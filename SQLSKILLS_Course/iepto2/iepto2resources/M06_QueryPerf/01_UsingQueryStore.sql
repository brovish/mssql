/*============================================================================
  File:     01_UsingQueryStore.sql

  SQL Server Versions: 2016, 2017, 2019, Azure SQL DB
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

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

/*
	Check resource use through the UI
*/

/*
	Textual matching in effect!
*/
USE [WideWorldImporters];
GO

SELECT TOP 100 
	[qst].[query_text_id],
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id],  
	[qsq].[query_hash],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qst].[query_sql_text] LIKE '%SELECT%' 
	AND [qst].[query_sql_text] LIKE '%StockItemID]%'
	AND [qsq].[object_id] = 0;
GO

SELECT 
	[query_hash] AS [query_hash], 
	COUNT([query_id]) AS [Count]
FROM [sys].[query_store_query] 
GROUP BY [query_hash]
HAVING COUNT(*) > 1;
GO


/*
	Individual QUERIES are captured
*/
SELECT OBJECT_DEFINITION (OBJECT_ID(N'Sales.usp_GetFullProductInfo'));
GO

 CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]   
	@StockItemID INT  
AS      
	SELECT     
		[o].[CustomerID],     
		[o].[OrderDate],     
		[ol].[StockItemID],     
		[ol].[Quantity],    
		[ol].[UnitPrice]   
	FROM [Sales].[Orders] [o]   
	JOIN [Sales].[OrderLines] [ol]     
		ON [o].[OrderID] = [ol].[OrderID]   
	WHERE [ol].[StockItemID] = @StockItemID   
	ORDER BY [o].[OrderDate] DESC;     
  
	SELECT    
		[o].[CustomerID],     
		SUM([ol].[Quantity]*[ol].[UnitPrice])   
	FROM [Sales].[Orders] [o]   
	JOIN [Sales].[OrderLines] [ol]     
		ON [o].[OrderID] = [ol].[OrderID]   
	WHERE [ol].[StockItemID] = @StockItemID   
	GROUP BY [o].[CustomerID]   
	ORDER BY [o].[CustomerID] ASC;  
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[rs].[count_executions],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo');
GO


/*
	Find top resource consumers with TSQL
	Longest execution times in the last hour
*/

SELECT 
	TOP 10 AVG([rs].[avg_duration]) [AvgDuration], 
	SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY AVG([rs].[avg_duration]) DESC;  
GO


/*
	Highest logical IO in last 1 hour
*/
SELECT 
	TOP 10 AVG([rs].[avg_logical_io_reads]) [AvgLogicalIO], 
	SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY AVG([rs].[avg_logical_io_reads]) DESC;  
GO


/*
	Highest execution count in last 1 hour
*/
SELECT 
	TOP 10 SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY SUM([rs].[count_executions]) DESC;  
GO



/*
	Queries executed in the last 8 hours
	with multiple plans
*/
SELECT
	[qsq].[query_id], 
	COUNT([qsp].[plan_id]) AS [PlanCount],
	OBJECT_NAME([qsq].[object_id]) [ObjectName], 
	MAX(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time])) AS [LocalLastExecutionTime],
	MAX([qst].query_sql_text) AS [Query_Text]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[last_execution_time] > DATEADD(HOUR, -8, GETUTCDATE())
GROUP BY [qsq].[query_id], [qsq].[object_id]
HAVING COUNT([qsp].[plan_id]) > 1;
GO

/*
	What are the plans for that query?
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[query_id] = 2;
GO
















/*
	Why does the same SP have multiple rows in the above query?
*/
SELECT 	
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsq].[object_id], 
	OBJECT_NAME([qsq].[object_id]) 
FROM  [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo');
GO

SELECT OBJECT_DEFINITION(OBJECT_ID(N'Sales.usp_GetFullProductInfo'));
GO

/*
	Stored procedure definition
*/
CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]   @StockItemID INT  
AS      
SELECT     
[o].[CustomerID],     
[o].[OrderDate],     
[ol].[StockItemID],     
[ol].[Quantity],    
[ol].[UnitPrice]   
FROM [Sales].[Orders] [o]   JOIN [Sales].[OrderLines] [ol]     
ON [o].[OrderID] = [ol].[OrderID]   
WHERE [ol].[StockItemID] = @StockItemID   
ORDER BY [o].[OrderDate] DESC;     
  
SELECT    
[o].[CustomerID],     
SUM([ol].[Quantity]*[ol].[UnitPrice])   
FROM [Sales].[Orders] [o]   JOIN [Sales].[OrderLines] [ol]     
ON [o].[OrderID] = [ol].[OrderID]   
WHERE [ol].[StockItemID] = @StockItemID   
GROUP BY [o].[CustomerID]   
ORDER BY [o].[CustomerID] ASC;  


/*
	How do you view runtime data for a stored procedure?
	(slides)
*/
SELECT *
FROM [sys].[query_store_runtime_stats_interval];
GO


/*
	Runtime stats are tied to a plan!
*/
SELECT *
FROM [sys].[query_store_runtime_stats] [rs] 
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
ORDER BY [rs].[plan_id], [rs].[runtime_stats_interval_id];
GO


/*
	Runtime stats for each query in the SP, by interval
*/

SELECT 
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[rsi].[runtime_stats_interval_id],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
AND [rs].[execution_type] = 0
ORDER BY [qsq].[query_id], [rsi].[runtime_stats_interval_id];
GO

/*
	Runtime stats for the SP, by interval
*/
SELECT 
	[rsi].[runtime_stats_interval_id],
	[rsi].[start_time],
	[rsi].[end_time],
	MAX([rs].[count_executions]) [ExecutionCount],
	SUM([rs].[avg_duration]) [Total_Avg_Duration],
	SUM([rs].[avg_cpu_time]) [Total_Avg_CPU],
	SUM([rs].[avg_logical_io_reads]) [Total_Avg_LogicalIO],
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
AND [rs].[execution_type] = 0
GROUP BY 
	[qsq].[object_id],
	[rsi].[runtime_stats_interval_id],
	[rsi].[start_time],
	[rsi].[end_time]
ORDER BY 
	[rsi].[runtime_stats_interval_id];
GO


