
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 34: Revenue by State

SELECT
	[State] =		N3.[Name]
	,TotalSales =	SUM (N1.TotalDue)
FROM Sales.SalesOrderHeader N1
INNER JOIN Person.[Address] N2 ON N1.ShipToAddressID = N2.AddressID
INNER JOIN Person.StateProvince N3 ON N2.StateProvinceID = N3.StateProvinceID
WHERE YEAR (N1.OrderDate) = 2006
GROUP BY N3.[Name]
ORDER BY SUM (N1.TotalDue) DESC