USE AdventureWorks2012;


--NOT HAPPY WITH THE WORDING OF THE QUESTION. dOES NOT MATCH THE SOLUTION
SELECT CU.StoreID , MAX(SH.OrderDate) 
FROM Sales.SalesOrderHeader AS SH 
INNER JOIN Sales.Customer AS CU ON CU.CustomerID = SH.CustomerID
INNER JOIN Sales.Store AS ST ON CU.StoreID = ST.BusinessEntityID
--WHERE SH.OrderDate < '20121007'
GROUP BY ST.BusinessEntityID, CU.StoreID, SH.CustomerID, ST.Name 
HAVING DATEDIFF(MONTH,MAX(SH.OrderDate),'2012-10-07') >= 12
