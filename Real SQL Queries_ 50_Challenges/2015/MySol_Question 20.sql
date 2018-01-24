USE AdventureWorks2012;

SELECT ST.Name, AD.AddressLine1, AD.AddressLine2, AD.City, SP.StateProvinceCode, AD.PostalCode
FROM Sales.Store AS ST 
--INNER JOIN Person.BusinessEntity AS BE ON BE.BusinessEntityID = ST.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress AS BEA ON BEA.BusinessEntityID = ST.BusinessEntityID
INNER JOIN Person.AddressType AS [AT] ON AT.AddressTypeID = BEA.AddressTypeID
INNER JOIN Person.Address AS AD ON AD.AddressID = BEA.AddressID
INNER JOIN Person.StateProvince AS SP ON SP.StateProvinceID = AD.StateProvinceID
WHERE [AT].Name = 'Main Office' AND AD.City = 'Toronto'
