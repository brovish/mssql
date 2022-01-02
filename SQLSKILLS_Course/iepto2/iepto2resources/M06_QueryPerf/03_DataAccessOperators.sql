/*============================================================================
  File:     03_DataAccessOperators.sql

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

EXEC sp_SQLskills_helpindex 'Sales.SalesOrderHeader';
GO

SET STATISTICS IO, TIME ON;
GO

/*
	create a copy of the table
*/
SELECT *
INTO [Sales].[Copy_SalesOrderHeader]
FROM [Sales].[SalesOrderHeader];
GO


/*
	Include actual plan
*/
SELECT 
	[SalesOrderID], 
	[CustomerID], 
	[OrderDate]
FROM [Sales].[Copy_SalesOrderHeader]
WHERE [CustomerID] > 18101;
GO


/*
	Same query against original table
*/
SELECT 
	[SalesOrderID], 
	[CustomerID], 
	[OrderDate]
FROM [Sales].[SalesOrderHeader]
WHERE [CustomerID] > 18101;
GO


/*
	Removed [OrderDate] and predicate
*/
SELECT 
	[SalesOrderID], 
	[CustomerID]
FROM [Sales].[SalesOrderHeader];
GO


/*
	Does it always scan the entire index?
*/
SELECT 
	TOP 100
	[SalesOrderID], 
	[CustomerID], 
	[OrderDate]
FROM [Sales].[SalesOrderHeader];
GO


/*
	check index usage stats for two indexes
*/
EXEC sp_SQLskills_helpindex 'Sales.SalesOrderHeader'

SELECT 
	index_id, 
	singleton_lookup_count, 
	range_scan_count
FROM sys.dm_db_index_operational_stats
(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), NULL, NULL)
WHERE index_id IN (1,4);
GO

/*
	rebuild to clear out index info
*/
ALTER INDEX [IX_SalesOrderHeader_CustomerID] 
	ON [Sales].[SalesOrderHeader] REBUILD;
GO
ALTER INDEX [PK_SalesOrderHeader_SalesOrderID] 
	ON [Sales].[SalesOrderHeader] REBUILD;
GO


/*
	verify
*/
SELECT 
	index_id, 
	singleton_lookup_count, 
	range_scan_count
FROM sys.dm_db_index_operational_stats
(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), NULL, NULL)
WHERE index_id IN (1,4);
GO



/* 
	Singleton or Range Scan Index Seek?
*/
SELECT 
	[SalesOrderID]
FROM [Sales].[SalesOrderHeader]
WHERE [CustomerID] = 19242;
GO

SELECT 
	index_id, 
	singleton_lookup_count, 
	range_scan_count
FROM sys.dm_db_index_operational_stats
(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), NULL, NULL)
WHERE index_id IN (1,4);
GO


/* 
	Singleton or Range Scan Index Seek?
*/
SELECT 
	[SalesOrderID]
FROM [Sales].[SalesOrderHeader]
WHERE [SalesOrderID] = 53560;
GO

SELECT 
	index_id, 
	singleton_lookup_count, 
	range_scan_count
FROM sys.dm_db_index_operational_stats
(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), NULL, NULL)
WHERE index_id IN (1,4);
GO


/*
	Singleton or Range Scan Index Seek?
*/
SELECT 
	[SalesOrderID], 
	[CustomerID]
FROM [Sales].[SalesOrderHeader]
WHERE [CustomerID] > 1;

SELECT 
	index_id, 
	singleton_lookup_count, 
	range_scan_count
FROM sys.dm_db_index_operational_stats
(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), NULL, NULL)
WHERE index_id IN (1,4);
GO



/*
	clean up
*/
DROP TABLE [Sales].[Copy_SalesOrderHeader];
GO



/*
	review of what's in the index
*/
EXEC sp_SQLskills_helpindex 'Sales.SalesOrderHeader';
GO


/*
	What do we see in the plan?
*/
SELECT 
	[CustomerID],
	[OrderDate], 
	[ShipDate], 
 	[SubTotal]
FROM [Sales].[SalesOrderHeader] [soh]
WHERE [CustomerID] = 11300;
GO


/*
	Edit existing index
*/
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID]
	ON [Sales].[SalesOrderHeader](
		[CustomerID]
	)
	INCLUDE (
		[OrderDate],
		[ShipDate],
		[SubTotal]
	)
WITH (DROP_EXISTING = ON) 
ON [PRIMARY]
GO

/*
	Re-run the query
*/
SELECT 
	[CustomerID],
	[OrderDate], 
	[ShipDate], 
 	[SubTotal]
FROM [Sales].[SalesOrderHeader] [soh]
WHERE [CustomerID] = 11300;
GO


/*
	What if someone adds on to our WHERE clause?
*/
SELECT 
	[CustomerID],
	[OrderDate], 
	[ShipDate], 
 	[SubTotal]
FROM [Sales].[SalesOrderHeader] [soh]
WHERE [CustomerID] = 11300
AND [OrderDate] BETWEEN '2016-05-01 00:00:00.000' AND '2016-05-31 00:00:00.000';
GO


/*
	USE TF 9130 (undocumented) to push this out to a filter to see it better
	(don't use in production code)
*/
SELECT 
	[CustomerID],
	[OrderDate], 
	[ShipDate], 
 	[SubTotal]
FROM [Sales].[SalesOrderHeader] [soh]
WHERE [CustomerID] = 11300
AND [OrderDate] BETWEEN '2016-05-01 00:00:00.000' AND '2016-05-31 00:00:00.000'
OPTION (QUERYTRACEON 9130);
GO


/*
	We could change the index
*/
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID]
	ON [Sales].[SalesOrderHeader](
		[CustomerID],
		[OrderDate]
	)
	INCLUDE (
		[ShipDate],
		[SubTotal]
	)
WITH (DROP_EXISTING = ON) 
ON [PRIMARY]
GO

/*
	Now what do predicates look like?
*/
SELECT 
	[CustomerID],
	[OrderDate], 
	[ShipDate], 
 	[SubTotal]
FROM [Sales].[SalesOrderHeader] [soh]
WHERE [CustomerID] = 11300
AND [OrderDate] BETWEEN '2016-05-01 00:00:00.000' AND '2016-05-31 00:00:00.000';
GO


/*
	Look at a range
*/
SELECT 
	[CustomerID],
	[OrderDate], 
	[ShipDate], 
 	[SubTotal]
FROM [Sales].[SalesOrderHeader] [soh]
WHERE [CustomerID] BETWEEN 11000 AND 12000
AND [OrderDate] BETWEEN '2016-05-01 00:00:00.000' AND '2016-05-31 00:00:00.000';
GO


/*
	Index Seek + Seek Predicate + Filter
	Does it push down the filter(s)?
*/
SELECT 
	[CustomerID], 
	[OrderDate], 
	SUM([SubTotal])
FROM [Sales].[SalesOrderHeader] 
WHERE [CustomerID] IN (11035, 11432, 11918)
GROUP BY [CustomerID], [OrderDate]
HAVING SUM([SubTotal]) > 2000.00
GO

/*
	With the group by and aggregation, cannot filter until after
	If you see additional filters that don't expect, explore futher!
*/


/*
	residuals can appear in lookups...  
*/
SELECT 
	[soh].[CustomerID], 
	[soh].[OrderDate],
	[soh].[ShipDate], 
 	[soh].[SubTotal],
	[sod].[ProductID]
FROM [Sales].[SalesOrderDetail] [sod]
INNER JOIN  [Sales].[SalesOrderHeader] [soh]
	ON [sod].SalesOrderID = [soh].SalesOrderID
WHERE [soh].[CustomerID] = 11300;
GO

SELECT 
	[soh].[CustomerID], 
	[soh].[OrderDate],
	[soh].[ShipDate], 
 	[soh].[SubTotal],
	[sod].[ProductID],
	[soh].[ShipMethodID]
FROM [Sales].[SalesOrderDetail] [sod]
INNER JOIN  [Sales].[SalesOrderHeader] [soh]
	ON [sod].SalesOrderID = [soh].SalesOrderID
WHERE [soh].[CustomerID] = 11300
AND [soh].[ShipMethodID] < 5;
GO


/*
	Can use TF 9130 to see this better
*/
SELECT 
	[soh].[CustomerID], 
	[soh].[OrderDate],
	[soh].[ShipDate], 
 	[soh].[SubTotal],
	[sod].[ProductID],
	[soh].[ShipMethodID]
FROM [Sales].[SalesOrderDetail] [sod]
INNER JOIN  [Sales].[SalesOrderHeader] [soh]
	ON [sod].SalesOrderID = [soh].SalesOrderID
WHERE [soh].[CustomerID] = 11300
AND [soh].[ShipMethodID] < 5
OPTION (QUERYTRACEON 9130);
GO


/*
	you can also find them in hash matches...
*/
SELECT 
	[s].[Name], 
	COUNT_BIG(*)
FROM [Production].[ProductSubcategory] [s]
INNER JOIN [Production].[Product] [p]
	ON [s].[ProductSubcategoryID] = [p].[ProductSubcategoryID]
WHERE RIGHT([p].[Name], LEN([s].[Name])) = 'Locks'
GROUP BY [s].[Name]; 
GO

/*
	Reset
*/
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID]
	ON [Sales].[SalesOrderHeader](
		[CustomerID] ASC
	)
WITH (DROP_EXISTING = ON) 
ON [PRIMARY]
GO

/*
	End
*/