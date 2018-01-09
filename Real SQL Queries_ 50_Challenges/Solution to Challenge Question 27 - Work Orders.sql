
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 27: Work Orders

-- Part I
SELECT
	ProductID
	,WorkOrders = COUNT (*)
FROM Production.WorkOrder
GROUP BY ProductID
ORDER BY COUNT (*) DESC

-- Part II
SELECT
	ProductName = N2.[Name]
	,WorkOrders = COUNT (*)
FROM Production.WorkOrder N1
INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
GROUP BY N2.[Name]
ORDER BY COUNT (*) DESC
