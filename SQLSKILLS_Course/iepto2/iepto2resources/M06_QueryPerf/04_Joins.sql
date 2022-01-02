/*============================================================================
  File:     04_Joins.sql

  SQL Server Versions: 2008, 2008R2, 2012, 2014, 2016, 2017, 2019
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
USE [AdventureWorks2019];
GO

SET STATISTICS IO ON;
GO

/*
	what's the "outer" table?
	what's the "inner" table?
	What is the cost?
	--
*/
SELECT 
	[h].[CustomerID], 
	[d].[ProductID]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Sales].[SalesOrderHeader] [h] 
	ON [d].[SalesOrderID] = [h].[SalesOrderID]
WHERE [h].[CustomerID] = 29712;
GO


/*
	What if we reverse the OUTER/INNER
	*use caution with this hint
*/
SELECT 
	[h].[CustomerID], 
	[d].[ProductID]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Sales].[SalesOrderHeader] [h] 
	ON [d].[SalesOrderID] = [h].[SalesOrderID]
WHERE [h].[CustomerID] = 29712
OPTION (FORCE ORDER);
GO


/*
	Force the order AND force a loop
*/
SELECT 
	[h].[CustomerID], 
	[d].[ProductID]
FROM [Sales].[SalesOrderDetail] [d] 
INNER LOOP JOIN [Sales].[SalesOrderHeader] [h] 
	ON [d].[SalesOrderID] = [h].[SalesOrderID]
WHERE [h].[CustomerID] = 29712
OPTION (FORCE ORDER);


/*
	Run all three variations together and 
	compare cost and IO
*/
SELECT 
	[h].[CustomerID], 
	[d].[ProductID]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Sales].[SalesOrderHeader] [h] 
	ON [d].[SalesOrderID] = [h].[SalesOrderID]
WHERE [h].[CustomerID] = 29712;
GO

SELECT 
	[h].[CustomerID], 
	[d].[ProductID]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Sales].[SalesOrderHeader] [h] 
	ON [d].[SalesOrderID] = [h].[SalesOrderID]
WHERE [h].[CustomerID] = 29712
OPTION (FORCE ORDER);
GO

SELECT 
	[h].[CustomerID], 
	[d].[ProductID]
FROM [Sales].[SalesOrderDetail] [d] 
INNER LOOP JOIN [Sales].[SalesOrderHeader] [h] 
	ON [d].[SalesOrderID] = [h].[SalesOrderID]
WHERE [h].[CustomerID] = 29712
OPTION (FORCE ORDER);
GO


/*
	Pay attention to scans in the inner table
	note the cost and IOs
*/
SELECT 
	[d].[SalesOrderID], 
	[p].[Name], 
	[d].[OrderQty]
FROM [Production].[Product] [p]
INNER JOIN [Sales].[SalesOrderDetail] [d] 
	ON [p].[ProductID] = [d].[ProductID]
WHERE [d].[ProductID] IN (870);
GO



/*
	Modify existing NCI to try and improve it
	Note: you could force an index here, 
	that's not my favorite thing to do
*/
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID 
ON [Sales].[SalesOrderDetail](
	[ProductID] ASC
	)
INCLUDE (
	[OrderQty]
	)
WITH (DROP_EXISTING = ON)
ON [PRIMARY];
GO


/*
	Did we improve performance?
	Do cost and IO values change?
*/
SELECT 
	[d].[SalesOrderID], 
	[p].[Name], 
	[d].[OrderQty]
FROM [Production].[Product] [p]
INNER JOIN [Sales].[SalesOrderDetail] [d] 
	ON [p].[ProductID] = [d].[ProductID]
WHERE [d].[ProductID] = 870;
GO


/*
	Change NCI back
*/
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID 
ON [Sales].[SalesOrderDetail](
	[ProductID] ASC
	)
WITH (DROP_EXISTING = ON)
ON [PRIMARY];
GO


/*
	check out our data first
*/
EXEC sp_SQLskills_helpindex 'Sales.SalesOrderHeader';
GO
EXEC sp_SQLskills_helpindex 'Sales.SalesOrderDetail';
GO


SELECT [SalesOrderID]
FROM [Sales].[SalesOrderDetail]
	INTERSECT
SELECT [SalesOrderID]
FROM [Sales].[SalesOrderHeader];
GO

SELECT [SalesOrderID]
FROM [Sales].[SalesOrderDetail]
	EXCEPT
SELECT [SalesOrderID]
FROM [Sales].[SalesOrderHeader];
GO

SELECT [SalesOrderID]
FROM [Sales].[SalesOrderHeader]
	EXCEPT
SELECT [SalesOrderID]
FROM [Sales].[SalesOrderDetail];
GO


/*
	Enable actual plan
	Join on SalesOrderID
	What is the join type and the cost?
	How is the data ordered?
	What indexes are used?
	Many to many?
*/

SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[SalesOrderHeader] [h]
JOIN [Sales].[SalesOrderDetail] [d]	
	ON [h].[SalesOrderID] = [d].[SalesOrderID];
GO

/*
	Create a copy of SalesOrderHeader and SalesOrderDetail
	Change the primary key slightly for SalesOrderDetail
*/

SELECT *
INTO [Sales].[Copy_SalesOrderHeader]
FROM [Sales].[SalesOrderHeader];

ALTER TABLE [Sales].[Copy_SalesOrderHeader] 
ADD  CONSTRAINT [PK_Copy_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED 
(
	[SalesOrderID] ASC
)
GO

SELECT *
INTO [Sales].[Copy_SalesOrderDetail]
FROM [Sales].[SalesOrderDetail];
GO

ALTER TABLE [Sales].[Copy_SalesOrderDetail] 
ADD  CONSTRAINT [PK_Copy_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] 
PRIMARY KEY CLUSTERED 
(
	[SalesOrderID] DESC,
	[SalesOrderDetailID] DESC
)
GO


/*
	Same query, but index ordered in reverse 
	What do we expect for join type and indexes?
	What is the cost?
*/
SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[Copy_SalesOrderHeader] [h]
JOIN [Sales].[Copy_SalesOrderDetail] [d]
	ON [h].[SalesOrderID] = [d].[SalesOrderID];
GO

/*
	Drop constraint
*/
ALTER TABLE [Sales].[Copy_SalesOrderHeader] 
	DROP CONSTRAINT [PK_Copy_SalesOrderHeader_SalesOrderID];
GO


/*
	re-run the query...
	what type of join and why?
*/
SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[Copy_SalesOrderHeader] [h]
JOIN [Sales].[Copy_SalesOrderDetail] [d]
	ON [h].[SalesOrderID] = [d].[SalesOrderID];
GO

/*
	re-run the query and force the merge
	how does the data get ordered?
*/
SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[Copy_SalesOrderHeader] [h]
JOIN [Sales].[Copy_SalesOrderDetail] [d]
	ON [h].[SalesOrderID] = [d].[SalesOrderID]
OPTION (MERGE JOIN);
GO


/*
	recreate the clustered index on Copy_SalesOrderHeader...but without a primary key
*/
CREATE CLUSTERED INDEX [CI_Copy_SalesOrderHeader] 
	ON [Sales].[Copy_SalesOrderHeader] ([SalesOrderID] ASC);
GO


/*
	re-run again...
	what's the join type?
	cost?
*/
SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[Copy_SalesOrderHeader] [h]
JOIN [Sales].[Copy_SalesOrderDetail] [d]
	ON [h].[SalesOrderID] = [d].[SalesOrderID];
GO

/*
	force the merge
*/
SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[Copy_SalesOrderHeader] [h]
JOIN [Sales].[Copy_SalesOrderDetail] [d]
	ON [h].[SalesOrderID] = [d].[SalesOrderID]
OPTION (MERGE JOIN);
GO

/*
	compared forced merge against optimizer merge (original table)
*/
SELECT 
	[h].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[h].[OrderDate], 
	[h].[CustomerID], 
	[h].[SubTotal]
FROM [Sales].[SalesOrderHeader] [h]
JOIN [Sales].[SalesOrderDetail] [d]
	ON [h].[SalesOrderID] = [d].[SalesOrderID];
GO

/*
	drop our tables
*/
DROP TABLE [Sales].[Copy_SalesOrderHeader];
GO
DROP TABLE [Sales].[Copy_SalesOrderDetail];
GO

/*
	Which is the "build" input?
	Which is the "probe" input?
	What is the cost? Memory grant in KB?
	Did the optimizer make a "good decision?"
*/
SELECT 
	[d].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[d].[ProductID], 
	[d].[OrderQty], 
	[p].[Name], 
	[p].[ListPrice]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Production].[Product] [p] 
	ON [d].[ProductID] = [p].[ProductID];
GO

/*
	What if we reversed build/probe?
	Compare the following two queries side-by-side

	Run both at the same time (both queries)
	** Actual Plan **
	Original query and forced
	How does the plan change? The cost? Memory grant?
	note the cost estimates :)
*/
DBCC FREEPROCCACHE;
GO

SELECT 
	[d].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[d].[ProductID], 
	[d].[OrderQty], 
	[p].[Name], 
	[p].[ListPrice]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Production].[Product] [p] 
	ON [d].[ProductID] = [p].[ProductID];
GO

SELECT 
	[d].[SalesOrderID], 
	[d].[SalesOrderDetailID], 
	[d].[ProductID], 
	[d].[OrderQty], 
	[p].[Name], 
	[p].[ListPrice]
FROM [Sales].[SalesOrderDetail] [d] 
INNER JOIN [Production].[Product] [p] 
	ON [d].[ProductID] = [p].[ProductID]
OPTION (FORCE ORDER);
GO



/*
	Adaptive Joins
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 150;
GO

USE [WideWorldImporters];
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
	Check distribution
*/
SELECT ContactPersonID, count(*)
FROM Sales.Orders
GROUP BY ContactPersonID
ORDER BY COUNT(*) DESC;

/*
	Query variations
*/
SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 3292;
GO

SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 3291;
GO

SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 3267;
GO

SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 1181;
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_OrderInfo_ContactPerson];
GO

CREATE PROCEDURE [Sales].[usp_OrderInfo_ContactPerson]
	@ContactPersonID INT
AS	

	SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
	FROM Sales.Orders o
	JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
	WHERE o.ContactPersonID = @ContactPersonID;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3292;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3267;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 1181;
GO

sp_recompile '[Sales].[usp_OrderInfo_ContactPerson]';
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 1181;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3267;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3292;
GO

/*
	What's in cache?
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT 
	[qs].execution_count, 
	[s].[text], 
	[qs].[query_hash], 
	[qs].[query_plan_hash], 
	[cp].[size_in_bytes]/1024 AS [PlanSizeKB], 
	[qp].[query_plan], 
	[qs].[plan_handle]
FROM sys.dm_exec_query_stats AS [qs]
CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
CROSS APPLY sys.dm_exec_sql_text([qs].[plan_handle]) AS [s]
INNER JOIN sys.dm_exec_cached_plans AS [cp] 
	ON [qs].[plan_handle] = [cp].[plan_handle]
WHERE [s].[text] LIKE '%usp_OrderInfo_ContactPerson%';
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO


/*
	reset
*/
DROP INDEX  CCI_Orders ON [Sales].[Orders];
GO

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

USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO