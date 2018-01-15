
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 17: Long Time No Sale

WITH Stores AS
(SELECT
	N3.BusinessEntityID
	,N1.CustomerID
	,N2.StoreID 
	,StoreName =			N3.Name
	,LastOrderDate =		MAX (N1.OrderDate)
	,MonthsSinceLastOrder =	DATEDIFF (MONTH, MAX (N1.OrderDate), '2008-10-07')
FROM Sales.SalesOrderHeader N1
INNER JOIN Sales.Customer N2 ON N1.CustomerID = N2.CustomerID
INNER JOIN Sales.Store N3 ON N2.StoreID = N3.BusinessEntityID
GROUP BY N3.BusinessEntityID, N2.StoreID, N1.CustomerID, N3.Name)

SELECT * 
FROM Stores
WHERE MonthsSinceLastOrder > = 12
ORDER BY MonthsSinceLastOrder DESC