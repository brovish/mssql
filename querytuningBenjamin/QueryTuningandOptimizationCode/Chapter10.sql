
-- Chapter 10

-- here is an example of a query showing the first case:
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID = 11020 OR SalesPersonID = 285

-- running the following two queries using a very selective predicate will create two plans using efficient Index Seek operators
SELECT SalesOrderID FROM Sales.SalesOrderDetail
WHERE ProductID = 897
SELECT SalesOrderID FROM Sales.SalesOrderHeader
WHERE CustomerID = 11020

-- however, if we join both tables using the same selective predicates SQL Server will now return a very expensive plan 
-- scanning the mentioned indexes
SELECT sod.SalesOrderID FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE sod.ProductID = 897 OR soh.CustomerID = 11020

-- this kind of query pattern can be fixed using the UNION clause instead of an OR condition
SELECT sod.SalesOrderID FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE sod.ProductID = 897
UNION
SELECT sod.SalesOrderID FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID = 11020

-- for example, the following unhinted query will produce the plan in Figure 10-5, which uses a Hash Join:
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID

-- this plan is shown partially in Figure 10-6.
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID
OPTION (LOOP JOIN, MERGE JOIN)

-- for example, in the following query, the hint to use a Merge Join will be ignored
SELECT AddressID, City, StateProvinceID, ModifiedDate
FROM Person.Address
WHERE City = 'Santa Fe'
OPTION (MERGE JOIN)

-- hints cannot force the query optimizer to generate invalid plans
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON sod.ProductID > p.ProductID
WHERE p.ProductID > 900
OPTION (HASH JOIN)

-- the following query will use a hint to request a Nested Loops Join instead
SELECT *
FROM Production.Product AS p
INNER LOOP JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID

-- however, as mentioned earlier, the join order is impacted as well
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER LOOP JOIN Production.Product AS p
ON p.ProductID = sod.ProductID

-- to see the effects of this, take a look at the following unhinted query
SELECT SalesOrderID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID

-- however, if we add a HASH GROUP hint to the previous query, as shown next
SELECT SalesOrderID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
OPTION (HASH GROUP)

-- on the other hand, a scalar aggregation will always use a Stream Aggregate operator
SELECT COUNT(*) FROM Sales.SalesOrderDetail
OPTION (HASH GROUP)

-- the following query, without hints, will show you the plan in Figure 10-11:
SELECT LastName, FirstName, soh.SalesOrderID
FROM Person.Person p JOIN HumanResources.Employee e
ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh
ON p.BusinessEntityID = soh.SalesPersonID
WHERE ShipDate > '2008-01-01'

-- it will produce the plan in Figure 10-12.
SELECT LastName, FirstName, soh.SalesOrderID
FROM Person.Person p JOIN HumanResources.Employee e
ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh
ON p.BusinessEntityID = soh.SalesPersonID
WHERE ShipDate > '2008-01-01'
OPTION (FORCE ORDER)

-- you can use this to create a right-deep tree, as shown in the next query, which shows the plan in Figure 10-13:
SELECT LastName, FirstName, soh.SalesOrderID
FROM Person.Person p JOIN HumanResources.Employee e
JOIN Sales.SalesOrderHeader soh
ON e.BusinessEntityID = soh.SalesPersonID
ON e.BusinessEntityID = p.BusinessEntityID
WHERE ShipDate > '2008-01-01'
OPTION (FORCE ORDER)

-- consider this unhinted example, which produces the plan shown in Figure 10-14:
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID

-- by adding a FORCE ORDER hint, as in the following query, you can cause the aggregation to be performed after the join
SELECT c.CustomerID, COUNT(*)
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
OPTION (FORCE ORDER)

-- you can also use the INDEX hint to avoid a bookmark lookup operation, as in the example shown next
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 897

-- the following query will force the use of a Clustered Index Scan operator, as shown in the plan in Figure 10-17:
SELECT * FROM Sales.SalesOrderDetail WITH (INDEX(0))
WHERE ProductID = 897

-- the same behavior can be obtained by using the FORCESCAN hint, as in the following query:
SELECT * FROM Sales.SalesOrderDetail WITH (FORCESCAN)
WHERE ProductID = 897

-- in the following example, the query optimizer estimates that a high number of records will be returned
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 870

-- because we have an index on ProductID (IX_SalesOrderDetail_ProductID), we can force the plan to use such an index
SELECT * FROM Sales.SalesOrderDetail WITH (INDEX(IX_SalesOrderDetail_ProductID))
WHERE ProductID = 870

-- you can also achieve a similar result by forcing a seek using the FORCESEEK table hint
SELECT * FROM Sales.SalesOrderDetail WITH (FORCESEEK)
WHERE ProductID = 870

-- you can even combine both hints to obtain the same plan, as in the following query
SELECT * FROM Sales.SalesOrderDetail
WITH (INDEX(IX_SalesOrderDetail_ProductID), FORCESEEK)
WHERE ProductID = 870

-- using FORCESEEK when SQL Server cannot perform an Index Seek operation will cause the query to not compile
SELECT * FROM Sales.SalesOrderDetail WITH (FORCESEEK)
WHERE OrderQty = 1

-- run the following query, which returns the plan shown in Figure 10-18:
SELECT * FROM Sales.SalesOrderDetail
ORDER BY ProductID

-- you can use the FAST hint to get these 20 records as quickly as possible, as seen in the next query:
SELECT * FROM Sales.SalesOrderDetail
ORDER BY ProductID
OPTION (FAST 20)

-- create an indexed view on AdventureWorks2012 by running the following code:
CREATE VIEW v_test
WITH SCHEMABINDING AS
SELECT SalesOrderID, COUNT_BIG(*) as cnt
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
GO
CREATE UNIQUE CLUSTERED INDEX ix_test ON v_test(SalesOrderID)

-- next, run the following query:
SELECT SalesOrderID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID

-- alternatively, you can use the EXPAND VIEWS hint, as in the following query, to avoid matching the index view
SELECT SalesOrderID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
OPTION (EXPAND VIEWS)

-- the following query shows how to use it to get the same results as our previous query
SELECT * FROM v_test WITH (NOEXPAND)

-- finally, drop the indexed view you just created:
DROP VIEW v_test

-- next, create the following stored procedure:
CREATE PROCEDURE test
AS
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID

-- next, create a plan guide to force the query to use a Nested Loops Join.
EXEC sp_create_plan_guide
@name = N'plan_guide_test',
@stmt = N'SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID',
@type = N'OBJECT',
@module_or_batch = N'test',
@params = NULL,
@hints = N'OPTION (LOOP JOIN)'

-- for example, the following statement will disable the previous plan guide
EXEC sp_control_plan_guide N'DISABLE', N'plan_guide_test'

-- to enable the plan guide again, use this:
EXEC sp_control_plan_guide N'ENABLE', N'plan_guide_test'

-- finally, to clean up, drop both the plan guide and the stored procedure
EXEC sp_control_plan_guide N'DROP', N'plan_guide_test'
DROP PROCEDURE test

-- suppose we have the same query we saw in the "Plan Guides" section, which produces a Hash Join:
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID

-- also suppose that you want SQL Server to use a different execution plan, which we can generate using a hint:
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID
OPTION (LOOP JOIN)

-- you can force this new plan to use a Nested Loops Join instead of a Hash Join
SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID
OPTION (USE PLAN N'<?xml version="1.0" encoding="utf-16"?>
...
</ShowPlanXML>')

-- you can combine both plan guides and the USE PLAN query hint to force a specific execution plan
EXEC sp_create_plan_guide
@name = N'plan_guide_test',
@stmt = N'SELECT *
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID',
@type = N'OBJECT',
@module_or_batch = N'test',
@params = NULL,
@hints = N'OPTION (USE PLAN N''<?xml version="1.0" encoding="utf-16"?>
...
</ShowPlanXML>'')'

