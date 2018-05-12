
-- Chapter 9

-- Here is an example of a typical star join query in AdventureWorksDW2012 showing all the characteristics just mentioned:
SELECT TOP 10 p.ModelName, p.EnglishDescription,
SUM(f.SalesAmount) AS SalesAmount
FROM FactResellerSales f JOIN DimProduct p
ON f.ProductKey = p.ProductKey
JOIN DimEmployee e
ON f.EmployeeKey = e.EmployeeKey
WHERE f.OrderDateKey >= 20030601
AND e.SalesTerritoryKey = 1
GROUP BY p.ModelName, p.EnglishDescription
ORDER BY SUM(f.SalesAmount) DESC

-- For this example, let’s run the following query:
SELECT TOP 10 p.ModelName, p.EnglishDescription,
SUM(f.SalesAmount) AS SalesAmount
FROM FactResellerSales f JOIN DimProduct p
ON f.ProductKey = p.ProductKey
JOIN DimEmployee e
ON f.EmployeeKey = e.EmployeeKey
WHERE f.OrderDateKey >= 20030601
AND e.SalesTerritoryKey = 1
GROUP BY p.ModelName, p.EnglishDescription
ORDER BY SUM(f.SalesAmount) DESC

-- To simulate a larger table with 100,000 rows and 10,000 pages, run the following statement:
UPDATE STATISTICS dbo.FactResellerSales WITH ROWCOUNT = 100000, PAGECOUNT = 10000

-- Clean the plan cache by running a statement such as
DBCC FREEPROCCACHE

-- Finally, run the following statement to correct the page and row count we just changed on the FactResellerSales table:
DBCC UPDATEUSAGE (AdventureWorksDW2012, 'dbo.FactResellerSales') WITH COUNT_ROWS

-- For example, suppose you create the following clustered columnstore index using a small version of FactInternetSales2:
CREATE TABLE dbo.FactInternetSales2 (
ProductKey int NOT NULL,
OrderDateKey int NOT NULL,
DueDateKey int NOT NULL,
ShipDateKey int NOT NULL)
GO
CREATE CLUSTERED COLUMNSTORE INDEX csi_FactInternetSales2
ON dbo.FactInternetSales2

-- When you try to create the nonclustered columnstore index
CREATE NONCLUSTERED COLUMNSTORE INDEX ncsi_FactInternetSales2
ON dbo.FactInternetSales2
(ProductKey, OrderDateKey)

-- drop the existing table before running the next exercise
DROP TABLE FactInternetSales2

-- run the following code to create the FactInternetSales2 table on the AdventureWorksDW2012 database:
USE AdventureWorksDW2012
GO
CREATE TABLE dbo.FactInternetSales2 (
ProductKey int NOT NULL,
OrderDateKey int NOT NULL,
DueDateKey int NOT NULL,
ShipDateKey int NOT NULL,
CustomerKey int NOT NULL,
PromotionKey int NOT NULL,
CurrencyKey int NOT NULL,
SalesTerritoryKey int NOT NULL,
SalesOrderNumber nvarchar(20) NOT NULL,
SalesOrderLineNumber tinyint NOT NULL,
RevisionNumber tinyint NOT NULL,
OrderQuantity smallint NOT NULL,
UnitPrice money NOT NULL,
ExtendedAmount money NOT NULL,
UnitPriceDiscountPct float NOT NULL,
DiscountAmount float NOT NULL,
ProductStandardCost money NOT NULL,
TotalProductCost money NOT NULL,
SalesAmount money NOT NULL,
TaxAmt money NOT NULL,
Freight money NOT NULL,
CarrierTrackingNumber nvarchar(25) NULL,
CustomerPONumber nvarchar(25) NULL,
OrderDate datetime NULL,
DueDate datetime NULL,
ShipDate datetime NULL
)

-- we can now insert some records by copying data from an existing fact table:
INSERT INTO dbo.FactInternetSales2
SELECT * FROM AdventureWorksDW2012.dbo.FactInternetSales
WHERE SalesOrderNumber < 'SO6'

-- run the following statement to create a clustered columnstore index:
CREATE CLUSTERED COLUMNSTORE INDEX csi_FactInternetSales2
ON dbo.FactInternetSales2

-- the following statement will show that, as of SQL Server 2014, columnstore indexes are now updatable
INSERT INTO dbo.FactInternetSales2
SELECT * FROM AdventureWorksDW2012.dbo.FactInternetSales
WHERE SalesOrderNumber > 'SO6'

-- test it by running the following query:
SELECT d.CalendarYear,
SUM(SalesAmount) AS SalesTotal
FROM dbo.FactInternetSales2 AS f
JOIN dbo.DimDate AS d
ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear

-- let’s add more records by running the following INSERT statement 20 times:
INSERT INTO dbo.FactInternetSales2
SELECT * FROM AdventureWorksDW2012.dbo.FactInternetSales
GO 20

-- similar to a rowstore, you can use the ALTER INDEX REBUILD statement to remove fragmentation of a columnstore index, as shown next:
ALTER INDEX csi_FactInternetSales2 on FactInternetSales2 REBUILD

-- to verify this, run the following query:
SELECT * FROM sys.indexes
WHERE object_id = OBJECT_ID('FactInternetSales2')

-- dropping the index running by using the next DROP INDEX statement and then running the previous query again 
-- will change index_id to 0 and type_desc to HEAP:
DROP INDEX FactInternetSales2.csi_FactInternetSales2

-- to test it, create the following index on the existing FactInternetSales table:
CREATE NONCLUSTERED COLUMNSTORE INDEX csi_FactInternetSales
ON dbo.FactInternetSales (
	ProductKey,
	OrderDateKey,
	DueDateKey,
	ShipDateKey,
	CustomerKey,
	PromotionKey,
	CurrencyKey,
	SalesTerritoryKey,
	SalesOrderNumber,
	SalesOrderLineNumber,
	RevisionNumber,
	OrderQuantity,
	UnitPrice,
	ExtendedAmount,
	UnitPriceDiscountPct,
	DiscountAmount,
	ProductStandardCost,
	TotalProductCost,
	SalesAmount,
	TaxAmt,
	Freight,
	CarrierTrackingNumber,
	CustomerPONumber,
	OrderDate,
	DueDate,
	ShipDate
)

-- the following query shows how the INDEX hint can be used:
SELECT d.CalendarYear,
SUM(SalesAmount) AS SalesTotal
FROM dbo.FactInternetSales AS f
WITH (INDEX(csi_FactInternetSales))
JOIN dbo.DimDate AS d
ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear

-- the new hint IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX could be used in this case, as shown in the following query:
SELECT d.CalendarYear,
SUM(SalesAmount) AS SalesTotal
FROM dbo.FactInternetSales AS f
JOIN dbo.DimDate AS d
ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)

-- finally, drop the created columnstore index by running the following statement:
DROP INDEX FactInternetSales.csi_FactInternetSales





