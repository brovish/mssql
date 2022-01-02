USE AdventureWorks2008R2;
GO

-- Setup Tempdb usage tracking
DECLARE @internal_object_alloc_page_count BIGINT

SELECT @internal_object_alloc_page_count = SUM(internal_objects_alloc_page_count)
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID

DECLARE @SalesOrderID INT, @AccountNumber NVARCHAR(30), @TotalFreight MONEY, 
	@DistinctItemTotal INT, @TotalItemCount INT

-- Create a significant I/O and tempdb query
SELECT 
	@SalesOrderID = soh.SalesOrderID, 
	@AccountNumber = soh.AccountNumber, 
	@TotalFreight = SUM(soh.Freight),
	@DistinctItemTotal = COUNT(DISTINCT sod.ProductID),
	@TotalItemCount = SUM(OrderQty)
FROM Sales.SalesOrderHeaderEnlarged AS soh
JOIN Sales.SalesOrderDetailEnlarged AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate BETWEEN '01/01/2009' AND '01/01/2010'
GROUP BY 
	soh.SalesOrderID, 
	soh.AccountNumber

-- Setup Tempdb usage tracking
DECLARE @internal_object_alloc_page_count BIGINT

SELECT @internal_object_alloc_page_count = SUM(internal_objects_alloc_page_count)
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID

SELECT (SUM(internal_objects_alloc_page_count) - @internal_object_alloc_page_count) * 8 AS internal_objects_alloc_KB
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID
GO







-- Create some supporting indexes
CREATE NONCLUSTERED INDEX [IE2_SalesOrderHeaderEnlarged_KOrderDate_IAccountNumber_IFreight] 
ON [Sales].[SalesOrderHeaderEnlarged] 
( [SalesOrderID] ASC, [OrderDate] ASC )
INCLUDE ( [AccountNumber], [Freight] ) 

CREATE NONCLUSTERED INDEX [IE2_SalesOrderDetailEnlarged_KSalesOrderID_KProductID_IOrderQty] 
ON [Sales].[SalesOrderDetailEnlarged] 
( [SalesOrderID] ASC, [ProductID] ASC )
INCLUDE ( [OrderQty])
GO

-- Setup Tempdb usage tracking
DECLARE @internal_object_alloc_page_count BIGINT

SELECT @internal_object_alloc_page_count = SUM(internal_objects_alloc_page_count)
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID

DECLARE @SalesOrderID INT, @AccountNumber NVARCHAR(30), @TotalFreight MONEY, 
	@DistinctItemTotal INT, @TotalItemCount INT

-- Create a significant I/O and tempdb query
SELECT 
	@SalesOrderID = soh.SalesOrderID, 
	@AccountNumber = soh.AccountNumber, 
	@TotalFreight = SUM(soh.Freight),
	@DistinctItemTotal = COUNT(DISTINCT sod.ProductID),
	@TotalItemCount = SUM(OrderQty)
FROM Sales.SalesOrderHeaderEnlarged AS soh
JOIN Sales.SalesOrderDetailEnlarged AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate BETWEEN '01/01/2009' AND '01/01/2010'
GROUP BY 
	soh.SalesOrderID, 
	soh.AccountNumber

SELECT (SUM(internal_objects_alloc_page_count) - @internal_object_alloc_page_count) * 8 AS internal_objects_alloc_KB
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID
GO












-- Remove the Indexes
DROP INDEX [IE2_SalesOrderHeaderEnlarged_KOrderDate_IAccountNumber_IFreight] 
ON [Sales].[SalesOrderHeaderEnlarged] 

DROP INDEX [IE2_SalesOrderDetailEnlarged_KSalesOrderID_KProductID_IOrderQty] 
ON [Sales].[SalesOrderDetailEnlarged] 
GO




-- Create an Indexed View to store our rollup
CREATE VIEW Sales.IE2_OrderDetailProductRollup
WITH SCHEMABINDING
AS 
SELECT 
	sod.SalesOrderID, 	
	sod.ProductID AS ProductID,
	SUM(sod.OrderQty) AS TotalItemCount,
	COUNT_BIG(*) AS Occurs
FROM Sales.SalesOrderDetailEnlarged AS sod
GROUP BY sod.SalesOrderID, sod.ProductID
GO

CREATE UNIQUE CLUSTERED INDEX IE2_OrderDetailProductRollup_KSalesOrderID_KProductID
ON Sales.IE2_OrderDetailProductRollup (SalesOrderID, ProductID)
GO

-- Create some supporting indexes
CREATE NONCLUSTERED INDEX [IE2_SalesOrderHeaderEnlarged_KOrderDate_IAccountNumber_IFreight] 
ON [Sales].[SalesOrderHeaderEnlarged] 
( [SalesOrderID] ASC, [OrderDate] ASC )
INCLUDE ( [AccountNumber], [Freight] ) 



-- Setup Tempdb usage tracking
DECLARE @internal_object_alloc_page_count BIGINT

SELECT @internal_object_alloc_page_count = SUM(internal_objects_alloc_page_count)
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID

DECLARE @SalesOrderID INT, @AccountNumber NVARCHAR(30), @TotalFreight MONEY, 
	@DistinctItemTotal INT, @TotalItemCount INT	

-- Test a rewritten version of the query
SELECT 
	@SalesOrderID = soh.SalesOrderID, 
	@AccountNumber = soh.AccountNumber, 
	@TotalFreight = SUM(soh.Freight),
	@DistinctItemTotal = DistinctItemTotal,
	@TotalItemCount = TotalItemCount
FROM Sales.SalesOrderHeaderEnlarged AS soh
JOIN (SELECT 
		sod.SalesOrderID, 	
		COUNT(DISTINCT sod.ProductID) AS DistinctItemTotal,
		SUM(sod.TotalItemCount) AS TotalItemCount 
	FROM Sales.IE2_OrderDetailProductRollup AS sod WITH(NOEXPAND) 
	GROUP BY sod.SalesOrderID) AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate BETWEEN '01/01/2009' AND '01/01/2010'
GROUP BY 	soh.SalesOrderID, 
	soh.AccountNumber,
	DistinctItemTotal,
	TotalItemCount
	


SELECT (SUM(internal_objects_alloc_page_count) - @internal_object_alloc_page_count) * 8 AS internal_objects_alloc_KB
FROM sys.dm_db_task_space_usage
WHERE session_id = @@SPID
GO












-- Reset the Environment
IF EXISTS (	SELECT 1 
			FROM sys.objects AS o 
			JOIN sys.indexes AS i ON o.object_id = i.object_id
			WHERE o.name = 'SalesOrderHeaderEnlarged'
			  AND i.name = 'IE2_SalesOrderHeaderEnlarged_KOrderDate_IAccountNumber_IFreight')
BEGIN
	DROP INDEX [IE2_SalesOrderHeaderEnlarged_KOrderDate_IAccountNumber_IFreight] 
	ON [Sales].[SalesOrderHeaderEnlarged] 
END
IF EXISTS (	SELECT 1 
			FROM sys.objects AS o 
			JOIN sys.indexes AS i ON o.object_id = i.object_id
			WHERE o.name = 'SalesOrderHeaderEnlarged'
			  AND i.name = 'IE2_SalesOrderDetailEnlarged_KSalesOrderID_KProductID_IOrderQty')
BEGIN
	DROP INDEX [IE2_SalesOrderDetailEnlarged_KSalesOrderID_KProductID_IOrderQty] 
	ON [Sales].[SalesOrderDetailEnlarged] 
END

IF OBJECT_ID('Sales.IE2_OrderDetailRollup') IS NOT NULL
BEGIN
	DROP VIEW Sales.IE2_OrderDetailRollup;
END

IF OBJECT_ID('Sales.IE2_OrderDetailProductRollup') IS NOT NULL
BEGIN
	DROP VIEW Sales.IE2_OrderDetailProductRollup;
END

