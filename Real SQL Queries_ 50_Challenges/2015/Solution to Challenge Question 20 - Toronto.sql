USE AdventureWorks2012;
--Solution to Challenge Question 20: Totonto

SELECT  
	AddressType	=		N3.Name
	,StoreName =		N4.Name
	,N2.AddressLine1
	,N2.AddressLine2
	,N2.City
	,StateProvince =	N5.Name
	,N2.PostalCode
FROM Person.BusinessEntityAddress N1
INNER JOIN Person.[Address] N2 ON N1.AddressID = N2.AddressID
INNER JOIN Person.AddressType N3 ON N1.AddressTypeID = N3.AddressTypeID
INNER JOIN Sales.Store N4 ON N1.BusinessEntityID = N4.BusinessEntityID
INNER JOIN Person.StateProvince N5 ON N2.StateProvinceID = N5.StateProvinceID
WHERE N3.Name = 'Main office' and N2.City = 'Toronto'