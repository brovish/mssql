
-- Chapter 3

-- to view the statistics for all the query optimizations since the SQL Server 
-- instance was started, we can just run the following:
SELECT * FROM sys.dm_exec_query_optimizer_info

-- for example, the next query displays the percentage of optimizations in the instance that include hints
SELECT (SELECT occurrence FROM sys.dm_exec_query_optimizer_info WHERE counter =
'hints' ) * 100.0 / ( SELECT occurrence FROM sys.dm_exec_query_optimizer_info
WHERE counter = 'optimizations' )

-- listing 3-1 sys.dm_exec_query_optimizer_info code
-- optimize these queries now
-- so they do not skew the collected results
GO
SELECT *
INTO after_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO
SELECT *
INTO before_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO
DROP TABLE before_query_optimizer_info
DROP TABLE after_query_optimizer_info
GO
-- real execution starts
GO
SELECT *
INTO before_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO
-- insert your query here
SELECT *
FROM Person.Address
-- keep this to force a new optimization
OPTION (RECOMPILE)
GO
SELECT *
INTO after_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO
SELECT a.counter,
(a.occurrence - b.occurrence) AS occurrence,
(a.occurrence * a.value - b.occurrence *
b.value) AS value
FROM before_query_optimizer_info b
JOIN after_query_optimizer_info a
ON b.counter = a.counter
WHERE b.occurrence <> a.occurrence
DROP TABLE before_query_optimizer_info
DROP TABLE after_query_optimizer_info

-- for example, the following query will successfully parse on the AdventureWorks2012 database
SELECT lname, fname FROM authors

-- the following query returns the names used by those trees:
SELECT * FROM sys.dm_xe_map_values WHERE name = 'query_optimizer_tree_id'

-- for example, the following query will have the tree representation shown in Figure 3-2:
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c JOIN Sales.SalesOrderHeader s
ON c.CustomerID = s.CustomerID
WHERE c.TerritoryID = 4
GROUP BY c.CustomerID

-- but first enable trace flag 3604, as shown next:
DBCC TRACEON(3604)

-- you will be able to see its output on the query’s Messages tab.
SELECT ProductID, name FROM Production.Product
WHERE ProductID = 877
OPTION (RECOMPILE, QUERYTRACEON 8605)

-- therefore, if I request
SELECT * FROM HumanResources.Employee WHERE VacationHours > 80

-- run the following query:
SELECT * FROM HumanResources.Employee WHERE VacationHours > 300

-- now, let’s see what happens if I disable the check constraint:
ALTER TABLE HumanResources.Employee NOCHECK CONSTRAINT CK_Employee_VacationHours

-- don’t forget to enable the constraint again by running the following statement:
ALTER TABLE HumanResources.Employee WITH CHECK CHECK CONSTRAINT
CK_Employee_VacationHours

-- take a look at the following query:
SELECT * FROM HumanResources.Employee WHERE VacationHours > 10
AND VacationHours < 5

-- now, let’s see the logical trees created during contradiction detection
SELECT * FROM HumanResources.Employee WHERE VacationHours > 300
OPTION (RECOMPILE, QUERYTRACEON 8606)

-- the following query joins two tables and shows the execution plan in Figure 3-5:
SELECT soh.SalesOrderID, c.AccountNumber
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID

-- let’s see what happens if we comment out the AccountNumber column:
SELECT soh.SalesOrderID --, c.AccountNumber
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID

-- as a test, temporarily disable the foreign key by running the following statement:
ALTER TABLE Sales.SalesOrderHeader NOCHECK CONSTRAINT
FK_SalesOrderHeader_Customer_CustomerID

-- don’t forget to reenable the foreign key by running the following statement:
ALTER TABLE Sales.SalesOrderHeader WITH CHECK CHECK CONSTRAINT
FK_SalesOrderHeader_Customer_CustomerID

-- to see this again, use the undocumented trace flag 8606, as shown next:
SELECT soh.SalesOrderID --, c.AccountNumber
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
OPTION (RECOMPILE, QUERYTRACEON 8606)

-- for example, the following AdventureWorks2012 query will produce a trivial plan:
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659

-- however, if we slightly change the query to the following
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 870

-- finally, you can use an undocumented trace flag to disable the trivial plan optimization
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659
OPTION (RECOMPILE, QUERYTRACEON 8757)

-- to start looking at this DMV, run the following query:
SELECT * FROM sys.dm_exec_query_transformation_stats

-- listing 3-2 sys.dm_exec_query_transformation_stats code
-- optimize these queries now
-- so they do not skew the collected results
GO
SELECT *
INTO before_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats
GO
SELECT *
INTO after_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats
GO
DROP TABLE after_query_transformation_stats
DROP TABLE before_query_transformation_stats
-- real execution starts
GO
SELECT *
INTO before_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats
GO
-- insert your query here
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659
-- keep this to force a new optimization
OPTION (RECOMPILE)
GO
SELECT *
INTO after_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats
GO
SELECT a.name, (a.promised - b.promised) as promised
FROM before_query_transformation_stats b
JOIN after_query_transformation_stats a
ON b.name = a.name
WHERE b.succeeded <> a.succeeded
DROP TABLE before_query_transformation_stats
DROP TABLE after_query_transformation_stats

-- for example, testing with a very simple AdventureWorks2012 query, such as
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659

-- let’s again add the undocumented trace flag 8757 to avoid a trivial plan
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659
OPTION (RECOMPILE, QUERYTRACEON 8757)

-- include the following query in the code in Listing 3-2 to explore the transformation rules it uses:
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID

-- run the following statement to temporarily disable the use of the GbAggBeforeJoin
-- transformation rule for the current session:
DBCC RULEOFF('GbAggBeforeJoin')

-- to test it, try running the following code:
DBCC TRACEON (3604)
DBCC SHOWONRULES

-- in the same way, the following code will show the rules that are disabled:
DBCC SHOWOFFRULES

-- we can disable the use of a Merge Join by disabling the rule JNtoSM 
DBCC RULEOFF('JNtoSM')

-- finally, before we finish, don’t forget to reenable the GbAggBeforeJoin and 
-- JNtoSM transformation rules by running the following commands:
DBCC RULEON('JNtoSM')
DBCC RULEON('GbAggBeforeJoin')

-- you may also want to clear your plan cache
DBCC FREEPROCCACHE

-- for example, the following code using the QUERYRULEOFF hint will disable the GbAggBeforeJoin rule
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
OPTION (RECOMPILE, QUERYRULEOFF GbAggBeforeJoin)

-- you can include more than one QUERYRULEOFF hint, like in the following example
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
OPTION (RECOMPILE, QUERYRULEOFF GbAggBeforeJoin, QUERYRULEOFF JNtoSM)

-- for example, if you run the query
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
OPTION (RECOMPILE, QUERYRULEOFF GbAggToStrm, QUERYRULEOFF GbAggToHS)

-- for example
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
OPTION (RECOMPILE, QUERYTRACEON 2373)

-- also, notice that a very simple query may not show anything, like in the following example
SELECT ProductID, name FROM Production.Product
OPTION (RECOMPILE, QUERYTRACEON 8608)

-- you can force a full optimization by using undocumented trace flag 8757
SELECT ProductID, name FROM Production.Product
OPTION (RECOMPILE, QUERYTRACEON 8608, QUERYTRACEON 8757)

-- let’s try a simple query that does not qualify for a trivial plan
SELECT ProductID, ListPrice FROM Production.Product
WHERE ListPrice > 90
OPTION (RECOMPILE, QUERYTRACEON 8606)

-- now let’s look at the initial Memo structure using undocumented trace flag 8608:
SELECT ProductID, ListPrice FROM Production.Product
WHERE ListPrice > 90
OPTION (RECOMPILE, QUERYTRACEON 8608)

-- finally, we can use the undocumented trace flag 8615 to see the Memo structure 
-- at the end of the optimization process:
SELECT ProductID, ListPrice FROM Production.Product
WHERE ListPrice > 90
OPTION (RECOMPILE, QUERYTRACEON 8615)

-- running the following query:
SELECT ProductID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
OPTION (RECOMPILE, QUERYTRACEON 8608)

-- now run the following query to look at the final Memo structure:
SELECT ProductID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
OPTION (RECOMPILE, QUERYTRACEON 8615)

-- as an additional test, you can see the Memo contents by forcing a Hash Aggregate 
-- by running the following query with a hint:
SELECT ProductID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
OPTION (RECOMPILE, HASH GROUP, QUERYTRACEON 8615)

-- take a look at the query
SELECT ProductID, name FROM Production.Product
WHERE ProductID = 877
OPTION (RECOMPILE, QUERYTRACEON 9292, QUERYTRACEON 9204)

-- to better understand how it works, let’s create additional statistics objects:
CREATE STATISTICS stat1 ON Production.Product(ProductID)
CREATE STATISTICS stat2 ON Production.Product(ProductID)
CREATE STATISTICS stat3 ON Production.Product(ProductID)
CREATE STATISTICS stat4 ON Production.Product(ProductID)

-- run the following query:
SELECT ProductID, name FROM Production.Product
WHERE ProductID = 877
OPTION (RECOMPILE, QUERYTRACEON 9292)

-- test the following code:
SELECT ProductID, name FROM Production.Product
WHERE ProductID = 877
OPTION (RECOMPILE, QUERYTRACEON 9204)

-- to clean up, drop the statistics object you’ve just created:
DROP STATISTICS Production.Product.stat1
DROP STATISTICS Production.Product.stat2
DROP STATISTICS Production.Product.stat3
DROP STATISTICS Production.Product.stat4

-- as an example, the following query does not qualify for search 0 and will go directly to search 1:
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 870

-- for example, the query
SELECT soh.SalesOrderID, sod.SalesOrderDetailID, SalesReasonID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = soh.SalesOrderID
JOIN Sales.SalesOrderHeaderSalesReason sohsr
ON sohsr.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 43697

-- for example, run the following query:
SELECT DISTINCT pp.LastName, pp.FirstName
FROM Person.Person pp JOIN HumanResources.Employee e
ON e.BusinessEntityID = pp.BusinessEntityID
JOIN Sales.SalesOrderHeader soh
ON pp.BusinessEntityID = soh.SalesPersonID
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p
ON sod.ProductID = p.ProductID
WHERE ProductNumber = 'BK-M18B-44'
OPTION (RECOMPILE, QUERYTRACEON 8675)


