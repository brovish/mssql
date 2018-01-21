USE AdventureWorks2012;

DECLARE @ORDERCOUNT AS INT = (SELECT COUNT(*) from Sales.SalesOrderHeader);

--CROSS APPLY TOOK 4 SECONDS. RUNNING THE QUERYWITH CROSS APPLY TOOK JUST 2 SECONDS. 
--CROSS JOIN TOOK THE SAME AMOUNT OF TIME. 
--TRY WITH CTE APPROACH
--SELECT *, OC.ORDERCOUNT
--FROM Sales.SalesOrderHeader AS SH INNER JOIN Sales.SalesOrderDetail AS SD ON SD.SalesOrderID = SH.SalesOrderID 
--INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
--INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
--INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID
--CROSS APPLY (SELECT @ORDERCOUNT) AS OC(ORDERCOUNT)


;WITH CTE AS
(--FIRST FIND ORDERS WITH BIKES 
SELECT SD.SalesOrderID
FROM Sales.SalesOrderDetail AS SD 
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID 
GROUP BY SD.SalesOrderID, PC.Name
HAVING PC.Name = 'Bikes'

INTERSECT--ORDERS WITH BOTH BIKES AND ACESSORIES

--NOW FIND ORDERS WITH ACCESSORIES
SELECT SD.SalesOrderID
FROM Sales.SalesOrderDetail AS SD 
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID 
GROUP BY SD.SalesOrderID, PC.Name
HAVING PC.Name = 'Accessories'
)
SELECT * 
INTO #TT
FROM CTE

--PART 1.1
SELECT COUNT(DISTINCT SalesOrderID), (SELECT COUNT(*) from Sales.SalesOrderHeader), CAST(COUNT(DISTINCT SalesOrderID) AS float) / (SELECT COUNT(*) from Sales.SalesOrderHeader) AS PERCENTAGE1BIKE1ACCESSORY--NO NEED FOR DISTINCT HERE AS INTERSECT IS A SET OPERATION. SO ITS RESULT WOULD BE DISTINCT
FROM #TT 


;WITH CTE2 AS
(--FIRST FIND ORDERS WITH BIKES 
SELECT SD.SalesOrderID
FROM Sales.SalesOrderDetail AS SD 
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID 
GROUP BY SD.SalesOrderID, PC.Name
HAVING PC.Name = 'Bikes'

INTERSECT--ORDERS WITH BOTH BIKES AND ACESSORIES

--NOW FIND ORDERS WITH AT LEAST 2 DIFFERENT CLOTHING PRODUCTS
SELECT SD.SalesOrderID
FROM Sales.SalesOrderDetail AS SD 
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID 
GROUP BY SD.SalesOrderID, PC.Name
HAVING PC.Name = 'Clothing' AND COUNT(PSC.ProductSubcategoryID)>1
)
SELECT *
INTO #TT2
FROM CTE2

--PART 1.2
SELECT COUNT(DISTINCT SalesOrderID), (SELECT COUNT(*) from Sales.SalesOrderHeader),
	 CAST(COUNT(DISTINCT SalesOrderID) AS float) / (SELECT COUNT(*) from Sales.SalesOrderHeader) AS PERCENTAGE1BIKE2CLOTHING--NO NEED FOR DISTINCT HERE AS INTERSECT IS A SET OPERATION. SO ITS RESULT WOULD BE DISTINCT
FROM #TT2

--PART 2. FIRST WITHOUT PIVOT SOLUTION(CUMBERSOME TO MAINTAIN IF TOO MANY CATEGORIES)
;WITH CTE3 AS
(
SELECT SD.SalesOrderID, PC.Name
FROM Sales.SalesOrderDetail AS SD 
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID 
GROUP BY SD.SalesOrderID, PC.Name
)
SELECT * 
INTO #TT3
FROM CTE3 

--YOU SEE THAT YOU HAVE TO DO ALL HE COMBINATIONS BY HAND. WE MIGHT AVOID THIS BY USING PITVOT
SELECT 1 AS ACCESSORIES, 1 AS CLOTHING, 1 AS COMPONENTS, 1 AS BIKES,  COUNT(*) FROM (SELECT SalesOrderID FROM #TT3 WHERE Name='Accessories' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Clothing' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Components' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Bikes') AS T1 
UNION
SELECT 1 AS ACCESSORIES, 1 AS CLOTHING, 0 AS COMPONENTS, 0 AS BIKES,  COUNT(*) FROM (SELECT SalesOrderID FROM #TT3 WHERE Name='Accessories' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Clothing') AS T2
UNION
SELECT 0 AS ACCESSORIES, 0 AS CLOTHING, 1 AS COMPONENTS, 1 AS BIKES,  COUNT(*) FROM (SELECT SalesOrderID FROM #TT3 WHERE Name='Components' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Bikes') AS T1 
UNION
SELECT 1 AS ACCESSORIES, 0 AS CLOTHING, 1 AS COMPONENTS, 1 AS BIKES,  COUNT(*) FROM (SELECT SalesOrderID FROM #TT3 WHERE Name='Accessories' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Components' INTERSECT SELECT SalesOrderID FROM #TT3 WHERE Name='Bikes') AS T1 



--select *
--from (values(1)) as a(d) cross apply (select * from (values(12)) as aa(s)) as b

--select *
--from (values(1),(2)) as a(d) cross apply (select * from (values(12),(13)) as aa(s)) as b

--select *
--from (values(1)) as a(d) cross apply (select 1 as s where 1=0) as b

