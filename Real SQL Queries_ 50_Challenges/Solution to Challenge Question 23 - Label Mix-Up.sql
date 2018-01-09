
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 23: Label Mix-Up

SELECT
	N1.SalesOrderID
	,N3.OrderDate
	,ProductName =		N2.[Name]
	,N5.FirstName
	,N5.LastName
	,N6.PhoneNumber
FROM Sales.SalesOrderDetail N1
INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
INNER JOIN Sales.SalesOrderHeader N3 ON N1.SalesOrderID = N3.SalesOrderID
INNER JOIN Sales.Customer N4 ON N3.CustomerID = N4.CustomerID
INNER JOIN Person.Person N5 ON N4.PersonID = N5.BusinessEntityID
INNER JOIN Person.PersonPhone N6 ON N5.BusinessEntityID = N6.BusinessEntityID
WHERE N2.[Name] like '%shorts%' 
		AND N3.OrderDate > '2008-07-07' 
		AND N3.OnlineOrderFlag = 1
ORDER BY N1.SalesOrderID


