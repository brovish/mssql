/*============================================================================
  File:     03_CEversion.sql

  SQL Server Versions: 2016, 2017, 2019
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
	Start with a clean copy of WWI
*/
USE [master];
GO
RESTORE DATABASE [WideWorldImporters] 
FROM  DISK = N'C:\Backups\WideWorldImportersEnlarged.bak' 
WITH  FILE = 1,  
MOVE N'WWI_Primary' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters.mdf',  
MOVE N'WWI_UserData' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters_UserData.ndf',  
MOVE N'WWI_Log' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters.ldf',  
MOVE N'WWI_InMemory_Data_1' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters_InMemory_Data_1',  
NOUNLOAD, 
REPLACE, 
STATS = 5;
GO

USE [master];
GO
ALTER DATABASE [WideWorldImporters] 
	SET COMPATIBILITY_LEVEL = 110;
GO

USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = ON;
GO


/*
	Enable Query Store with settings we want
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), 
	DATA_FLUSH_INTERVAL_SECONDS = 60,  
	INTERVAL_LENGTH_MINUTES = 10, 
	MAX_STORAGE_SIZE_MB = 100, 
	QUERY_CAPTURE_MODE = ALL, 
	SIZE_BASED_CLEANUP_MODE = AUTO, 
	MAX_PLANS_PER_QUERY = 200)
GO

/*
	Clear out any old data, just in case
*/
ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE CLEAR;
GO



/*
	Create a SP and execute
*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Sales].[Order_CE];
GO

CREATE PROCEDURE [Sales].[Order_CE]
	@Description NVARCHAR(200),
	@OrderDate DATE 
AS
BEGIN
	SELECT 
		[ol].[StockItemID], 
		[ol].[Description], 
		[ol].[UnitPrice],
		[o].[CustomerID], 
		[o].[SalespersonPersonID],
		[o].[OrderDate]
	FROM [Sales].[OrderLines] [ol]
	JOIN [Sales].[Orders] [o]
		ON [ol].[OrderID] = [o].[OrderID]
	WHERE [ol].[Description] LIKE @Description
	AND [o].[OrderDate] = @OrderDate;
END
GO

/*
	Run our SP
*/
EXEC [Sales].[Order_CE] @Description = 'Superhero action jacket (Blue)%', @OrderDate = '2016-08-22';
GO

/*
	Find our query
	can note the query_id
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[rs].[count_executions],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
--WHERE [qsp].[compatibility_level] < 120;
WHERE [qsq].[object_id] = OBJECT_ID('Sales.Order_CE');
GO

/*
	Now set compat mode to 150
	and use new CE
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] 
	SET COMPATIBILITY_LEVEL = 150;
GO

USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

/*
	Re-run the SP
*/
EXEC [Sales].[Order_CE] @Description = 'Superhero action jacket (Blue)%', @OrderDate = '2016-08-22';
GO


/*
	Flush QS data to disk
*/
EXEC [sys].[sp_query_store_flush_db];
GO

/*
	Find our query
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[rs].[count_executions],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qsq].[object_id] = OBJECT_ID('Sales.Order_CE');
--WHERE [qsq].[query_id] = 8293; 
GO

/*
	Compare performance of different compat modes
	(or used Tracked Queries report)
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsp].[plan_id], 
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qst].[query_sql_text],
	[qsp].[query_plan_hash]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qsq].[object_id] = OBJECT_ID('Sales.Order_CE');
GO


/*
	Second CE example...
	Enable actual plan!
*/
USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = ON;
GO

SELECT 
	[CustomerID], 
	[CustomerTransactionID]
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 401
AND [TransactionDate] = '2016-11-13';
GO 10


/*
	Get the query_text_id!
	Note the CE, etc.
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsq].[query_hash],
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qst].[query_sql_text] LIKE '%CustomerTransactions%'
ORDER BY (DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) DESC;
GO



USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

SELECT 
	[CustomerID], 
	[CustomerTransactionID]
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 401
AND [TransactionDate] = '2016-11-13';
GO 10

/*
	Same plan, but different CE versions in plan
	Only the first version is stored in cache
	(query_plan_hash doesn't change)
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsq].[query_hash],
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
--WHERE [qst].[query_text_id] = 15
ORDER BY (DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) DESC;
GO


/*
	just in case...
*/
EXEC sp_query_store_remove_query @query_ID = 2932
GO

