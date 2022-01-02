/*============================================================================
  File:     05_OperatorMemory.sql

  SQL Server Versions: 2008, 2008R2, 2012, 2014, 2016, 2017, 2019
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2020 SQLskills.com. All rights reserved.
  ,
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

SET STATISTICS IO ON;
GO

SELECT
	TOP 10
	[CustomerID],
	[OrderDate]
FROM [Sales].[Orders];
GO

/*
	SELECT query with a TOP, and an ORDER BY...
	because people usually want to see the data in some order, right?
*/
SELECT
	TOP 10
	[CustomerID],
	[OrderDate]
FROM [Sales].[Orders]
ORDER BY [OrderID] DESC;
GO


/*
	Another SELECT query with a TOP, and an ORDER BY...
*/
SELECT
	TOP 10
	[CustomerID],
	[OrderDate]
FROM [Sales].[Orders]
ORDER BY [OrderDate] DESC;
GO

/*
	variations in SORT operators (for reference)
	SORT vs. top N SORT vs. distinct SORT
	http://sqlperformance.com/2015/04/sql-plan/internals-of-the-seven-sql-server-sorts-part-1
	http://sqlperformance.com/2015/05/sql-plan/internals-of-the-seven-sql-server-sorts-part-2
*/


/*
	SELECT query with an ORDER BY 
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [CustomerID] = 500
ORDER BY [CustomerID];
GO


/*
	Add a covering index to support the query
*/
CREATE NONCLUSTERED INDEX [IX_SalesOrders_CustomerID]
	ON [Sales].[Orders] (
		[CustomerID]
		)
	INCLUDE (
		[OrderDate], [ContactPersonID]
		)
	ON USERDATA;
GO

/*
	Now with an index to support
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [CustomerID] = 500
ORDER BY [CustomerID];
GO

/*
	Check the columns in the index
*/
EXEC sp_SQLskills_helpindex 'Sales.Orders';


/*
	What if we order on BOTH columns descending?
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [CustomerID] = 500
ORDER BY [CustomerID] DESC, [OrderID] DESC;
GO

/*
	What if we have add a sort order for an included column?
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [CustomerID] = 500
ORDER BY [CustomerID] DESC, [OrderDate] DESC;
GO



/*
	Clean up
*/
DROP INDEX [IX_SalesOrders_CustomerID]
	ON [Sales].[Orders]



/*
	A second query, looking at a lot more data
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [OrderDate] BETWEEN '2016-01-01 00:00:00.000' AND '2016-12-31 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO


/*
	Check out row and page count
*/
SELECT 
	OBJECT_NAME([p].[object_id]) [TableName], 
	[si].[name] [IndexName], 
	[au].[type_desc] [Type], 
	[p].[rows] [RowCount], 
	[au].total_pages [PageCount]
FROM [sys].[partitions] [p]
JOIN [sys].[allocation_units] [au] ON [p].[partition_id] = [au].[container_id]
JOIN [sys].[indexes] [si] on [p].[object_id] = [si].object_id and [p].[index_id] = [si].[index_id]
WHERE [p].[object_id] = OBJECT_ID(N'Sales.Orders');
GO

/*
	Trick the optimize a bit here and change row count
	**Don't try this at home!!**
*/
UPDATE STATISTICS  [Sales].[Orders]
	WITH ROWCOUNT = 1000000, PAGECOUNT = 15509;
GO

/*
	re-run
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [OrderDate] BETWEEN '2016-01-01 00:00:00.000' AND '2016-12-31 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO


/*
	How to track these?
	In the default trace...
	C:\Program Files\Microsoft SQL Server\MSSQL14.ROGERS\MSSQL\Log

	Can we get better information through XEvents?  Yes ;)
*/
CREATE EVENT SESSION [SortWarnings] 
	ON SERVER 
	ADD EVENT sqlserver.hash_warning(
		ACTION(
			sqlserver.sql_text,sqlserver.tsql_stack)
			),
	ADD EVENT sqlserver.sort_warning(
		ACTION(
			sqlserver.sql_text,sqlserver.tsql_stack)
			),
	ADD EVENT sqlserver.rpc_completed
ADD TARGET package0.event_file(
	SET filename=N'C:\temp\SortWarnings',max_file_size=(512)
	)
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [SortWarnings]
	ON SERVER
	STATE=START;
GO

/*
	re-run again
	view the data
*/
SELECT
	[CustomerID],
	[OrderDate],
	[ContactPersonID]
FROM [Sales].[Orders]
WHERE [OrderDate] BETWEEN '2016-01-01 00:00:00.000' AND '2016-12-31 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO


/*
	note that the XE session isn't perfect - you can't rely on sql_text
	either use tsql_stack and remove sql_batch_completed, or,
	remove tsql_stack and sql_text, and keep sql_batch_completed

	clean up 
*/
ALTER EVENT SESSION [SortWarnings]
	ON SERVER
	STATE=STOP;
GO

DROP EVENT SESSION [SortWarnings]
	ON SERVER;
GO

UPDATE STATISTICS  [Sales].[Orders]
	WITH ROWCOUNT = 4595157, PAGECOUNT = 15509;
GO















/*
	Need a columnstore index...
*/
ALTER TABLE [Sales].[Invoices] DROP CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders];
GO

ALTER TABLE [Sales].[Orders] DROP CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders];
GO

ALTER TABLE [Sales].[OrderLines] DROP CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders];
GO

ALTER TABLE [Sales].[Orders] DROP CONSTRAINT [PK_Sales_Orders] WITH ( ONLINE = OFF );
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_Orders
ON [Sales].[Orders];



/*
	Set compat mode to 120
*/
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 120;
GO

/*
	Clear procedure cache for the DB
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_OrderInfo_OrderDate];
GO

CREATE PROCEDURE [Sales].[usp_OrderInfo_OrderDate]
	@StartDate DATETIME,
	@EndDate DATETIME
AS
SELECT
	[o].[CustomerID],
	[o].[OrderDate],
	[o].[ContactPersonID],
	[ol].[Quantity]
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol]
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [OrderDate] BETWEEN @StartDate AND @EndDate
ORDER BY [OrderDate];
GO

/*
	Run each of these a few times and check memory grant
*/
DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-01-08'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-06-30'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO



/*
	Set compat mode to 140
*/
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO

/*
	Clear procedure cache for the DB
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/*
	Run each of these a few times and check memory grant
*/
DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-01-08'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-06-30'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO


/*
	reset
*/
ALTER TABLE [Sales].[Orders] ADD  CONSTRAINT [PK_Sales_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
GO

ALTER TABLE [Sales].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[Invoices] CHECK CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders]
GO

ALTER TABLE [Sales].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders] FOREIGN KEY([BackorderOrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[Orders] CHECK CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders]
GO

ALTER TABLE [Sales].[OrderLines]  WITH CHECK ADD  CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[OrderLines] CHECK CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
GO