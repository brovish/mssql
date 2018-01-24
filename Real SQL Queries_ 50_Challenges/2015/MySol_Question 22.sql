USE AdventureWorks2012;

SELECT *
FROM Person.BusinessEntity AS BE 
INNER JOIN Person.EmailAddress AS EA ON EA.BusinessEntityID = BE.BusinessEntityID
INNER JOIN Production.ProductReview AS PRV ON PRV.EmailAddress = EA.EmailAddress
INNER JOIN Sales.Customer