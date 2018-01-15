
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

--Solution to Challenge Question 11: Needy Accountant

SELECT
	Country =			N3.[Name]			
	,MaxTaxRate =		MAX (N1.TaxRate)
FROM Sales.SalesTaxRate N1
INNER JOIN Person.StateProvince N2 ON N1.StateProvinceID = N2.StateProvinceID
INNER JOIN Person.CountryRegion N3 ON N2.CountryRegionCode = N3.CountryRegionCode
GROUP BY N3.[Name]


