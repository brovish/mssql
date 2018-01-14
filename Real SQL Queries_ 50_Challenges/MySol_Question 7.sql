USE AdventureWorks2012;

SELECT  EMP.LoginID, ST.Name, SUM(SH.SubTotal)
FROM Sales.SalesPerson AS SP INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID = SP.TerritoryID  INNER JOIN Sales.SalesOrderHeader AS SH ON SH.SalesPersonID = SP.BusinessEntityID INNER JOIN
HumanResources.Employee AS EMP ON EMP.BusinessEntityID = SP.BusinessEntityID
WHERE SH.OrderDate >= '20110101' AND SH.OrderDate < '20120101' 
GROUP BY EMP.LoginID, ST.Name
HAVING ST.Name IN ('NorthWest','Southwest', 'Canada')

DROP TABLE #TOPSALESPERSON
--with salary
SELECT  PR.FirstName,PR.LastName, ST.Name, SUM(SH.SubTotal) AS TOTALSALES
INTO #TOPSALESPERSON
FROM Sales.SalesPerson AS SP INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID = SP.TerritoryID  INNER JOIN Sales.SalesOrderHeader AS SH ON SH.SalesPersonID = SP.BusinessEntityID INNER JOIN
Person.Person AS PR ON PR.BusinessEntityID = SP.BusinessEntityID
WHERE SH.OrderDate >= '20110101' AND SH.OrderDate < '20120101' 
GROUP BY PR.FirstName, PR.LastName, ST.Name
HAVING ST.Name IN ('NorthWest','Southwest', 'Canada')

ALTER TABLE #TOPSALESPERSON
	ADD SALARY MONEY


UPDATE #TOPSALESPERSON
	SET SALARY = CASE WHEN LastName = 'CAMPBELL' THEN 79500 WHEN LastName = 'CAMPBELL' THEN 60000
						WHEN LastName = 'CAMPBELL' THEN 59500  WHEN LastName = 'CAMPBELL' THEN 56000 
						WHEN LastName = 'CAMPBELL' THEN 680000  WHEN LastName = 'CAMPBELL' THEN 80000 END