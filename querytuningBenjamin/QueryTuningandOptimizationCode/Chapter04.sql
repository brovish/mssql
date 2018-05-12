
-- Chapter 4

-- the following query on the AdventureWorks2012 database will use a Table Scan
SELECT * FROM DatabaseLog

-- similarly, the following query will show a Clustered Index Scan operator
SELECT * FROM Person.Address

-- if you want to know whether your data has been sorted, the Ordered property can show if the data 
SELECT * FROM Person.Address
ORDER BY AddressID

-- run the following query, which will show the plan in Figure 4-4:
SELECT AddressID, City, StateProvinceID
FROM Person.Address

-- now let’s look at Index Seeks
SELECT AddressID, City, StateProvinceID FROM Person.Address
WHERE AddressID = 12037

-- the next query and Figure 4-6 both illustrate a nonclustered Index Seek operator
SELECT AddressID, StateProvinceID FROM Person.Address
WHERE StateProvinceID = 32

-- the previous query just returned one row, but you can change it to a new parameter like in the following example:
SELECT AddressID, StateProvinceID FROM Person.Address
WHERE StateProvinceID = 9

-- a more complicated example of partial ordered scans involves using a nonequality operator or a BETWEEN clause
SELECT AddressID, City, StateProvinceID FROM Person.Address
WHERE AddressID BETWEEN 10000 and 20000

-- this is shown in the next query, which returns one record and produces the plan in Figure 4-7.
SELECT AddressID, City, StateProvinceID, ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 32

-- for example, run the following query:
SET SHOWPLAN_TEXT ON
GO
SELECT AddressID, City, StateProvinceID, ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 32
GO
SET SHOWPLAN_TEXT OFF
GO

-- this will produce the plan shown in Figure 4-8.
SELECT AddressID, City, StateProvinceID, ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 20

-- to follow the next example, create an index on the DatabaseLog table, 
-- which is a heap, by running the following statement:
CREATE INDEX IX_Object ON DatabaseLog(Object)

-- then run the following query, which will produce the plan in Figure 4-11:
SELECT * FROM DatabaseLog
WHERE Object = 'City'

-- to clean up, simply remove the index you just created:
DROP INDEX DatabaseLog.IX_Object

-- to demonstrate, run the following query, which shows the plan in Figure 4-12:
SELECT AVG(ListPrice) FROM Production.Product

-- run the following query:
SET SHOWPLAN_TEXT ON
GO
SELECT AVG(ListPrice) FROM Production.Product
GO
SET SHOWPLAN_TEXT OFF
GO

-- now let’s see an example of a query using the GROUP BY clause
SELECT ProductLine, COUNT(*) FROM Production.Product
GROUP BY ProductLine

-- a Stream Aggregate can also use an index to have its input sorted, as in the following query
SELECT SalesOrderID, SUM(LineTotal)FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID

-- for example, the SalesOrderHeader table has no index on the TerritoryID column, 
-- so the following query will use a Hash Aggregate operator
SELECT TerritoryID, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID

-- run the following statement to create an index
CREATE INDEX IX_TerritoryID ON Sales.SalesOrderHeader(TerritoryID)

-- to clean up, drop the index using the following DROP INDEX statement:
DROP INDEX Sales.SalesOrderHeader.IX_TerritoryID

-- the query optimizer will estimate which operation is the least expensive
SELECT TerritoryID, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
ORDER BY TerritoryID

-- the following two queries return the same data and produce the same execution plan
SELECT DISTINCT(JobTitle)
FROM HumanResources.Employee
GO
SELECT JobTitle
FROM HumanResources.Employee
GROUP BY JobTitle

-- to test it, run this:
CREATE INDEX IX_JobTitle ON HumanResources.Employee(JobTitle)

-- drop the index before continuing by using this statement:
DROP INDEX HumanResources.Employee.IX_JobTitle

-- finally, for a bigger table without an index to provide order, a Hash Aggregate may be used, as in the two following examples:
SELECT DISTINCT(TerritoryID)
FROM Sales.SalesOrderHeader
GO
SELECT TerritoryID
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID

-- this creates the plan in Figure 4-20, which uses a Nested Loops Join.
SELECT e.BusinessEntityID, TerritoryID
FROM HumanResources.Employee AS e
JOIN Sales.SalesPerson AS s ON e.BusinessEntityID = s.BusinessEntityID

-- let’s change the query to add a filter by TerritoryID:
SELECT e.BusinessEntityID, HireDate
FROM HumanResources.Employee AS e
JOIN Sales.SalesPerson AS s ON e.BusinessEntityID = s.BusinessEntityID
WHERE TerritoryID = 1

-- the execution plan is shown in Figure 4-23.
SELECT h.SalesOrderID, s.SalesOrderDetailID, OrderDate
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail s ON h.SalesOrderID = s.SalesOrderID

-- if you run the following query, you will notice that it uses a Nested Loops Join
SELECT * FROM Sales.SalesOrderDetail s
JOIN Production.Product p ON s.ProductID = p.ProductID
WHERE SalesOrderID = 43659

-- obviously, these additional operations are more expensive than a Clustered Index Seek
SELECT * FROM Sales.SalesOrderdetail s
JOIN Production.Product p ON s.ProductID = p.ProductID
WHERE SalesOrderID = 43659
OPTION (MERGE JOIN)

-- run the following query to produce the plan displayed in Figure 4-26
SELECT h.SalesOrderID, s.SalesOrderDetailID FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail s ON h.SalesOrderID = s.SalesOrderID

-- a simple way to do this is to copy the data from Sales.SalesOrderDetail a few times by running the following statements:
SELECT *
INTO #temp
FROM Sales.SalesOrderDetail
UNION ALL SELECT * FROM Sales.SalesOrderDetail
UNION ALL SELECT * FROM Sales.SalesOrderDetail
UNION ALL SELECT * FROM Sales.SalesOrderDetail
UNION ALL SELECT * FROM Sales.SalesOrderDetail
UNION ALL SELECT * FROM Sales.SalesOrderDetail

SELECT IDENTITY(int, 1, 1) AS ID, CarrierTrackingNumber, OrderQty, ProductID,
UnitPrice, LineTotal, rowguid, ModifiedDate
INTO dbo.SalesOrderDetail FROM #temp

SELECT IDENTITY(int, 1, 1) AS ID, CarrierTrackingNumber, OrderQty, ProductID,
UnitPrice, LineTotal, rowguid, ModifiedDate
INTO dbo.SalesOrderDetail2 FROM #temp
DROP TABLE #temp

-- the following query, using one of the tables we just created, will produce a parallel plan
SELECT ProductID, COUNT(*)
FROM dbo.SalesOrderDetail
GROUP BY ProductID

-- one way to do this is by using the MAXDOP hint to force a serial plan on the same query, as shown next:
SELECT ProductID, COUNT(*)
FROM dbo.SalesOrderDetail
GROUP BY ProductID
OPTION (MAXDOP 1)

-- an interesting test you can perform in your test environment is to change the cost threshold for parallelism option to 10
EXEC sp_configure 'cost threshold for parallelism', 10
GO
RECONFIGURE
GO

-- do not forget to change the cost threshold for the parallelism configuration option back to the default value of 5
EXEC sp_configure 'cost threshold for parallelism', 5
GO
RECONFIGURE
GO

-- to see how it works, run the next query, which creates the parallel plan shown in Figure 4-28.
SELECT * FROM dbo.SalesOrderDetail
WHERE LineTotal > 3234

-- for example, compare the execution plans of these two versions of the first example on this section
SELECT ProductID, COUNT(*)
FROM dbo.SalesOrderDetail
GROUP BY ProductID
GO
SELECT ProductID, COUNT(*)
FROM dbo.SalesOrderDetail
GROUP BY ProductID
ORDER BY ProductID

-- in this case, hash partitioning distributes the build and probe rows among the individual Hash Join threads
SELECT * FROM dbo.SalesOrderDetail s1 JOIN dbo.SalesOrderDetail2 s2
ON s1.id = s2.id

-- a bitmap operator is also used to eliminate most of the rows from table2, which greatly improves the performance of the query
SELECT * FROM dbo.SalesOrderDetail s1
JOIN dbo.SalesOrderDetail2 s2 ON s1.ProductID = s2.ProductID
WHERE s1.id = 123

-- for example, the following code shows how the first parallel example in this section turns into a serial plan
CREATE FUNCTION dbo.ufn_test(@ProductID int)
RETURNS int
AS
BEGIN
RETURN @ProductID
END
GO
SELECT dbo.ufn_test(ProductID), ProductID, COUNT(*)
FROM dbo.SalesOrderDetail
GROUP BY ProductID

-- just for demonstration purposes, see the following example using a small table
SELECT ProductID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID

-- using trace flag 8649, as shown next, will create a parallel plan with the slightly lower cost of 0.386606 units:
SELECT ProductID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
OPTION (QUERYTRACEON 8649)

-- inserting a new record on the Person.CountryRegion table using the following query creates a very simple plan
INSERT INTO Person.CountryRegion (CountryRegionCode, Name)
VALUES ('ZZ', 'New Country')

-- however, the operation gets complicated very quickly when you try to delete the same record by running the next statement
DELETE FROM Person.CountryRegion
WHERE CountryRegionCode = 'ZZ'

-- the following query will create a per-row plan, which is shown in Figure 4-36
DELETE FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID = 61130

-- let’s add two nonclustered indexes to the table:
CREATE NONCLUSTERED INDEX AK_SalesOrderDetail_rowguid
ON dbo.SalesOrderDetail (rowguid)
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID
ON dbo.SalesOrderDetail (ProductID)

-- when a large number of records is being updated, the query optimizer may choose a per-index plan
DELETE FROM dbo.SalesOrderDetail WHERE ProductID < 953

-- you can now delete the tables you have created for these exercises:
DROP TABLE dbo.SalesOrderDetail
DROP TABLE dbo.SalesOrderDetail2

-- for example, the following query on Sales.SalesOrderDetail requires this trace flag to produce a per-index plan
DELETE FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID < 43740
OPTION (QUERYTRACEON 8790)

-- run the following statement to create a new table:
SELECT * INTO dbo.Product FROM Production.Product

-- run the following UPDATE statement, which produces the execution plan on Figure 4-39:
UPDATE dbo.Product SET ListPrice = ListPrice * 1.2

-- now, to demonstrate the problem, let’s create a clustered index on the ListPrice column, like so:
CREATE CLUSTERED INDEX CIX_ListPrice ON dbo.Product(ListPrice)

-- finally, drop the table you have just created.
DROP TABLE dbo.Product


