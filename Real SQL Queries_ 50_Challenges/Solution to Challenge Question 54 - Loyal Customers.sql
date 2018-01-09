
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution to Challange Question 54: Loyal Customers

-- Part I
SELECT 
	LoyalCustomers =	COUNT (*)
	,TotalCustomers =	(SELECT COUNT (DISTINCT CustomerID) 
	  					 FROM Sales.SalesOrderHeader
						 WHERE SalesPersonID IS NOT NULL)
FROM (SELECT CustomerID
	  FROM Sales.SalesOrderHeader
	  WHERE SalesPersonID IS NOT NULL
	  GROUP BY CustomerID
	  HAVING COUNT (*) >= 10 
		AND COUNT (DISTINCT SalesPersonID) = 1) X1

-- Part II
DECLARE @CustomerID INT = 
	(SELECT TOP 1 CustomerID 
	 FROM (SELECT CustomerID
		   FROM Sales.SalesOrderHeader N1
		   WHERE SalesPersonID IS NOT NULL
		   GROUP BY N1.CustomerID
		   HAVING COUNT (*) >= 10 
			AND COUNT (DISTINCT SalesPersonID) = 1) X1
ORDER BY NEWID ())

SELECT * 
FROM Sales.SalesOrderHeader
WHERE CustomerID = @CustomerID