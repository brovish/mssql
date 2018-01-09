
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution 1 to Challenge Question 53: Sales Order Counts

WITH Orders AS

(SELECT
	N2.LastName 
	,FY =		'FY' + CONVERT (CHAR (4), YEAR (DATEADD (MONTH, 6, (OrderDate))))
	,SalesOrderID
FROM Sales.SalesOrderHeader N1
INNER JOIN Person.Person AS N2 ON N1.SalesPersonID = N2.BusinessEntityID
WHERE OnlineOrderFlag = 0) 

SELECT X1.LastName, X1.FY2006, X1.FY2007, X1.FY2008
FROM Orders
PIVOT (COUNT (Orders.SalesOrderID)
	FOR FY IN (FY2006, FY2007, FY2008)) X1
ORDER BY X1.LastName;

-- Solution 2 to Challenge Question 53: Sales Order Counts

SELECT 
	N2.LastName
	,FY2006 = SUM (CASE WHEN YEAR (DATEADD (MONTH, 6, (OrderDate))) = 2006 THEN 1 ELSE 0 END)
	,FY2007 = SUM (CASE WHEN YEAR (DATEADD (MONTH, 6, (OrderDate))) = 2007 THEN 1 ELSE 0 END)
	,FY2008 = SUM (CASE WHEN YEAR (DATEADD (MONTH, 6, (OrderDate))) = 2008 THEN 1 ELSE 0 END)
FROM Sales.SalesOrderHeader N1
INNER JOIN Person.Person AS N2 ON N1.SalesPersonID = N2.BusinessEntityID
WHERE OnlineOrderFlag = 0
GROUP BY N2.LastName
ORDER BY LastName