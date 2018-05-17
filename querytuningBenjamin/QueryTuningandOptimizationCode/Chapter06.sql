
-- Chapter 6

-- but first make sure you are using the new cardinality estimator by running the following statement:
ALTER DATABASE AdventureWorks2012
SET COMPATIBILITY_LEVEL = 120

-- existing statistics for a specific object can be displayed using the sys.stats catalog view, as used in the following query:
SELECT * FROM sys.stats
WHERE object_id = OBJECT_ID('Sales.SalesOrderDetail')

-- for example, run the following statement to verify that there are no statistics on the UnitPrice column
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', UnitPrice)

-- by then running the following query, the query optimizer will automatically create statistics on the UnitPrice column
SELECT * FROM Sales.SalesOrderDetail
WHERE UnitPrice = 35

-- run the following statement to inspect the statistics of the existing index, IX_SalesOrderDetail_ProductID:
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', IX_SalesOrderDetail_ProductID)

--  in this case, we have 1 / 0.003759399, which gives us 266, which is the estimated number of rows shown in the plan in Figure 6-1.
SELECT ProductID FROM Sales.SalesOrderDetail
GROUP BY ProductID

-- next is an example of how the density can be used to estimate the cardinality of a query using local variables:
DECLARE @ProductID int
SET @ProductID = 921
SELECT ProductID FROM Sales.SalesOrderDetail
WHERE ProductID = @ProductID

-- finally, run this query with an inequality operator:
DECLARE @pid int = 897
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID < @pid

-- to see how the histogram is used, run the following statement
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', IX_SalesOrderDetail_ProductID)

-- run the following query to obtain the real number of records for ProductIDs 827 to 831
SELECT ProductID, COUNT(*) AS Total
FROM Sales.SalesOrderDetail
WHERE ProductID BETWEEN 827 AND 831
GROUP BY ProductID

-- let’s look at the first query:
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 831

-- the following is the query in question, and the estimated number of rows is shown in the execution plan in Figure 6-6:
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID < 714

-- for that, make sure you are using the old cardinality estimator by running the following statement
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 110

-- then run this statement:
SELECT * FROM Person.Address WHERE City = 'Burbank'

-- in a similar way, the following statement will get an estimate of 194:
SELECT * FROM Person.Address WHERE PostalCode = '91502'

-- if we use both predicates, we have the following query, which will have an estimated 1.93862 number of rows:
SELECT * FROM Person.Address
WHERE City = 'Burbank' AND PostalCode = '91502'

-- let’s see the same estimations using the new cardinality estimator:
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 120
GO
SELECT * FROM Person.Address WHERE City = 'Burbank' AND PostalCode = '91502'

-- now let’s test the same example using OR’ed predicates, first using the old cardinality estimator:
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 110
GO
SELECT * FROM Person.Address WHERE City = 'Burbank' OR PostalCode = '91502'

-- testing the same example for the new cardinality estimator would return an estimate of 292.269 rows, as shown in Figure 6-8.
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 120
GO
SELECT * FROM Person.Address WHERE City = 'Burbank' OR PostalCode = '91502'

-- you can use trace flag 9481, as explained earlier:
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 120
GO
SELECT * FROM Person.Address WHERE City = 'Burbank' AND PostalCode = '91502'
OPTION (QUERYTRACEON 9481)

-- for example, the following code will show an estimated number of rows of 194
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 110
GO
SELECT * FROM Person.Address
WHERE City = 'Burbank' AND PostalCode = '91502'
OPTION (QUERYTRACEON 4137)

-- in the next query, I show you how to use the SET STATISTICS PROFILE statement
SET STATISTICS PROFILE ON
GO
SELECT * FROM Sales.SalesOrderDetail
WHERE OrderQty * UnitPrice > 10000
GO
SET STATISTICS PROFILE OFF
GO

-- first, we need to create a partitioned table using the AdventureWorks2012 database:
CREATE PARTITION FUNCTION TransactionRangePF1 (datetime)
AS RANGE RIGHT FOR VALUES
(
'20071001', '20071101', '20071201', '20080101',
'20080201', '20080301', '20080401', '20080501',
'20080601', '20080701', '20080801'
)
GO
CREATE PARTITION SCHEME TransactionsPS1 AS PARTITION TransactionRangePF1 TO
(
[PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY],
[PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY],
[PRIMARY], [PRIMARY], [PRIMARY]
)
GO
CREATE TABLE dbo.TransactionHistory
(
TransactionID int NOT NULL,
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL DEFAULT (0),
TransactionDate datetime NOT NULL DEFAULT (GETDATE()),
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL DEFAULT (GETDATE()),
CONSTRAINT CK_TransactionType
CHECK (UPPER(TransactionType) IN (N'W', N'S', N'P'))
)
ON TransactionsPS1 (TransactionDate)
GO

-- we currently have data to populate 12 partitions. Let’s start by first populating only 11:
INSERT INTO dbo.TransactionHistory
SELECT * FROM Production.TransactionHistory
WHERE TransactionDate < '2008-08-01'

-- if required, you can use the following statement to inspect the contents of the partitions:
SELECT * FROM sys.partitions
WHERE object_id = OBJECT_ID('dbo.TransactionHistory')

-- let’s create an incremental statistics object using the CREATE STATISTICS statement
CREATE STATISTICS incrstats ON dbo.TransactionHistory(TransactionDate)
WITH FULLSCAN, INCREMENTAL = ON

-- you can inspect the created statistics object using the following query:
DBCC SHOW_STATISTICS('dbo.TransactionHistory', incrstats)

-- let’s add data to partition 12:
INSERT INTO dbo.TransactionHistory
SELECT * FROM Production.TransactionHistory
WHERE TransactionDate >= '2008-08-01'

-- now, we update the statistics object using the following statement:
UPDATE STATISTICS dbo.TransactionHistory(incrstats)
WITH RESAMPLE ON PARTITIONS(12)

-- if you want to disable the incremental statistics object for any reason
UPDATE STATISTICS dbo.TransactionHistory(incrstats)
WITH FULLSCAN, INCREMENTAL = OFF

-- to clean up the objects created for this exercise, run the following statements:
DROP TABLE dbo.TransactionHistory
DROP PARTITION SCHEME TransactionsPS1
DROP PARTITION FUNCTION TransactionRangePF1

-- to see an example, run this query, which creates the plan shown in Figure 6-9:
SELECT * FROM Sales.SalesOrderDetail
WHERE OrderQty * UnitPrice > 10000

-- now create a computed column:
ALTER TABLE Sales.SalesOrderDetail
ADD cc AS OrderQty * UnitPrice

-- note that creating the computed column does not create statistics
SELECT * FROM sys.stats
WHERE object_id = OBJECT_ID('Sales.SalesOrderDetail')

-- use the following command to display the details about the statistics object
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', _WA_Sys_0000000E_44CA3770)

-- you can also use “cc” as the name of the object to get the same results
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', cc)

-- unfortunately, for automatic matching to work, the expression must be exactly the same as the computed column definition
SELECT * FROM Sales.SalesOrderDetail
WHERE UnitPrice * OrderQty > 10000

-- finally, drop the created computed column:
ALTER TABLE Sales.SalesOrderDetail
DROP COLUMN cc

-- running the following query will correctly estimate the number of rows to be 93:
SELECT * FROM Person.Address
WHERE City = 'Los Angeles'

-- in the same way, running the next query will correctly estimate 4,564 rows:
SELECT * FROM Person.Address
WHERE StateProvinceID = 9

-- however, because StateProvinceID 9 corresponds to the state of California
SELECT * FROM Person.Address
WHERE City = 'Los Angeles' AND StateProvinceID = 9

-- you can create a filtered statistics object for the state of California, as shown in the next statement:
CREATE STATISTICS california
ON Person.Address(City)
WHERE StateProvinceID = 9

-- clearing the cache and running the previous query again will now give a better estimate
DBCC FREEPROCCACHE
GO
SELECT * FROM Person.Address
WHERE City = 'Los Angeles' AND StateProvinceID = 9

--  let’s now inspect the filtered statistics object by running the following statement:
DBCC SHOW_STATISTICS('Person.Address', california)

-- finally, drop the statistics object you have just created by running the following statement:
DROP STATISTICS Person.Address.california

-- to show you what the problem is and how these trace flags work, let’s start by creating a table in AdventureWorks2012
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 110
GO
CREATE TABLE dbo.SalesOrderHeader (
SalesOrderID int NOT NULL,
RevisionNumber tinyint NOT NULL,
OrderDate datetime NOT NULL,
DueDate datetime NOT NULL,
ShipDate datetime NULL,
Status tinyint NOT NULL,
OnlineOrderFlag dbo.Flag NOT NULL,
SalesOrderNumber nvarchar(25) NOT NULL,
PurchaseOrderNumber dbo.OrderNumber NULL,
AccountNumber dbo.AccountNumber NULL,
CustomerID int NOT NULL,
SalesPersonID int NULL,
TerritoryID int NULL,
BillToAddressID int NOT NULL,
ShipToAddressID int NOT NULL,
ShipMethodID int NOT NULL,
CreditCardID int NULL,
CreditCardApprovalCode varchar(15) NULL,
CurrencyRateID int NULL,
SubTotal money NOT NULL,
TaxAmt money NOT NULL,
Freight money NOT NULL,
TotalDue money NOT NULL,
Comment nvarchar(128) NULL,
rowguid uniqueidentifier NOT NULL,
ModifiedDate datetime NOT NULL
)

-- populate the table with some initial data and create an index on it
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate < '2008-07-20 00:00:00.000'
CREATE INDEX IX_OrderDate ON SalesOrderHeader(OrderDate)

-- after creating the index, SQL Server will also create a statistics object for it
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-19 00:00:00.000'

-- now, let’s suppose we add new data for July 20:
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate = '2008-07-20 00:00:00.000'

-- so let’s change the query to look for records for July 20:
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-20 00:00:00.000'

-- run the next statements
DBCC TRACEON (2388)
DBCC TRACEON (2389)

-- trace flag 2390 enables a similar behavior to 2389, even if the ascending nature of the column is not known
DBCC SHOW_STATISTICS ('dbo.SalesOrderHeader', 'IX_OrderDate')

-- run the following statement to update statistics, including the data you just added for February 20:
UPDATE STATISTICS dbo.SalesOrderHeader WITH FULLSCAN

-- now run the second batch:
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate = '2008-07-21 00:00:00.000'

-- again, running this query will verify the one-row estimate in the plan:
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-21 00:00:00.000'

-- now update statistics again:
UPDATE STATISTICS dbo.SalesOrderHeader WITH FULLSCAN

-- now for a third batch:
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate = '2008-07-22 00:00:00.000'

-- update statistics one last time:
UPDATE STATISTICS dbo.SalesOrderHeader WITH FULLSCAN

-- to test it, try this batch:
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate = '2008-07-23 00:00:00.000'

-- now run the following query:
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-23 00:00:00.000'

-- in addition, if we look for data that does not exist, we still get the one-row estimate
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-24 00:00:00.000'

-- finally, you could use the trace flags on a query without defining them at the session
-- or global level using the QUERYTRACEON hint, as shown next:
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-23 00:00:00.000'
OPTION (QUERYTRACEON 2389, QUERYTRACEON 2390)

-- to see how it works, drop the dbo.SalesOrderHeader table:
DROP TABLE dbo.SalesOrderHeader

-- disable trace flags 2388 and 2389, as shown next, or open a new session:
DBCC TRACEOFF (2388)
DBCC TRACEOFF (2389)

-- insert some data again and create an index, as shown next:
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate < '2008-07-20 00:00:00.000'
CREATE INDEX IX_OrderDate ON SalesOrderHeader(OrderDate)

-- now add new data for July 20:
INSERT INTO dbo.SalesOrderHeader SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate = '2008-07-20 00:00:00.000'

-- running the following query with the old cardinality estimator will estimate one row, as we saw earlier:
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 110
GO
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-20 00:00:00.000'

-- running the same query with the new cardinality estimator will give a better estimate of 27.9631
ALTER DATABASE AdventureWorks2012 SET COMPATIBILITY_LEVEL = 120
GO
SELECT * FROM dbo.SalesOrderHeader WHERE OrderDate = '2008-07-20 00:00:00.000'

-- run the following query to create a new table on the AdventureWorks2012 database:
SELECT * INTO dbo.Address
FROM Person.Address

-- inspect the number of rows by running the following query; the row_count column should show 19,614 rows:
SELECT * FROM sys.dm_db_partition_stats
WHERE object_id = OBJECT_ID('dbo.Address')

-- now run the following query and inspect the graphical execution plan:
SELECT * FROM dbo.Address
WHERE City = 'London'

-- now run the following UPDATE STATISTICS WITH ROWCOUNT, PAGECOUNT statement
UPDATE STATISTICS dbo.Address WITH ROWCOUNT = 1000000, PAGECOUNT = 100000

-- clear the plan cache and run the query again.
DBCC FREEPROCCACHE
GO
SELECT * FROM dbo.Address WHERE City = 'London'

-- run the following statement:
DBCC UPDATEUSAGE(AdventureWorks2012, 'dbo.Address') WITH COUNT_ROWS

-- however, after you finish your testing, it is recommended that you drop this table
DROP TABLE dbo.Address

-- so let’s see how it works using a linked server
SELECT l.SalesOrderID, l.CustomerID
FROM AdventureWorks2012.Sales.SalesOrderHeader l
JOIN [remote].AdventureWorks2012.Sales.SalesOrderHeader r
ON l.SalesOrderID = r.SalesOrderID
WHERE r.CustomerID = 11000

-- run the following statement to enable trace flag 9485:
DBCC TRACEON (9485)

-- create a new table called dbo.SalesOrderDetail:
SELECT * INTO dbo.SalesOrderDetail FROM Sales.SalesOrderDetail

-- the next query uses the sys.stats catalog view to show that there are no statistics objects for the new table:
SELECT name, auto_created, STATS_DATE(object_id, stats_id) AS update_date
FROM sys.stats
WHERE object_id = OBJECT_ID('dbo.SalesOrderDetail')

-- now run the following query:
SELECT * FROM dbo.SalesOrderDetail
WHERE SalesOrderID = 43670 AND OrderQty = 1

-- now create the following index and run the sys.stats query again
CREATE INDEX IX_ProductID ON dbo.SalesOrderDetail(ProductID)

-- run the next command to update just the column statistics:
UPDATE STATISTICS dbo.SalesOrderDetail WITH FULLSCAN, COLUMNS

-- this command will do the same for just the index statistics:
UPDATE STATISTICS dbo.SalesOrderDetail WITH FULLSCAN, INDEX

-- and these commands will update both the index and column statistics:
UPDATE STATISTICS dbo.SalesOrderDetail WITH FULLSCAN
UPDATE STATISTICS dbo.SalesOrderDetail WITH FULLSCAN, ALL

-- you’ll see how an ALTER INDEX REBUILD statement only updates index statistics:
ALTER INDEX ix_ProductID ON dbo.SalesOrderDetail REBUILD

-- and you can verify that reorganizing an index does not update any statistics:
ALTER INDEX ix_ProductID on dbo.SalesOrderDetail REORGANIZE

-- finally, for good housekeeping, remove the table you have just created:
DROP TABLE dbo.SalesOrderDetail

-- run the following query and look at the estimated CPU and I/O costs for the Clustered Index Scan operator
SELECT * FROM Sales.SalesOrderDetail
WHERE LineTotal = 35

-- because this operator scans the entire table, I can use the next query to find the number of database pages
SELECT in_row_data_page_count, row_count
FROM sys.dm_db_partition_stats
WHERE object_id = OBJECT_ID('Sales.SalesOrderDetail')
AND index_id = 1

