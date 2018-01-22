USE AdventureWorks2012;

SELECT CU.StoreID , MAX(SH.OrderDate) 
FROM Sales.Store AS ST INNER JOIN Sales.SalesOrderHeader AS SH ON SH.SalesPersonID = ST.SalesPersonID
INNER JOIN Sales.Customer AS CU ON CU.StoreID = ST.BusinessEntityID
GROUP BY CU.StoreID 
--HAVING < '20121007'