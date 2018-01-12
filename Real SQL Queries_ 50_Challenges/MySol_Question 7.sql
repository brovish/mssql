USE AdventureWorks2012;

SELECT  EMP.LoginID, ST.Name, SUM(SH.SubTotal)
FROM Sales.SalesPerson AS SP INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID = SP.TerritoryID  INNER JOIN Sales.SalesOrderHeader AS SH ON SH.SalesPersonID = SP.BusinessEntityID INNER JOIN
HumanResources.Employee AS EMP ON EMP.BusinessEntityID = SP.BusinessEntityID
WHERE SH.OrderDate >= '20110101' AND SH.OrderDate < '20120101' 
GROUP BY EMP.LoginID, ST.Name
HAVING ST.Name IN ('NorthWest','Southwest', 'Canada')

--SELECT *
--FROM Sales.SalesOrderHeader
