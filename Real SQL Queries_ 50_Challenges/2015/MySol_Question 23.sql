USE AdventureWorks2012;

SELECT SH.SalesOrderID, SH.OrderDate, PR.Name, PER.FirstName, PER.LastName
FROM Sales.SalesOrderHeader AS SH
INNER JOIN Sales.SalesOrderDetail AS SD ON SD.SalesOrderID = SH.SalesOrderID
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID
INNER JOIN Production.ProductSubcategory AS PS ON PS.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Sales.Customer AS CU ON CU.CustomerID = SH.CustomerID
INNER JOIN Person.Person AS PER ON PER.BusinessEntityID = CU.PersonID
INNER JOIN Person.PersonPhone AS PP ON PP.BusinessEntityID = PER.BusinessEntityID
WHERE SH.OnlineOrderFlag = 1 AND SH.OrderDate > '20080707' AND PS.Name = 'Shorts'
