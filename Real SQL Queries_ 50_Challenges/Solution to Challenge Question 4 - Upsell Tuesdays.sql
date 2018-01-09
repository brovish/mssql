/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

--Solution to Challenge Question 4: Upsell Tuesdays

SELECT 
	DayCategory =		DATENAME (WEEKDAY, OrderDate)
	,Revenue =			SUM (Subtotal)
	,Orders =			COUNT (*)
	,RevenuePerOrder =	SUM (Subtotal) / COUNT (*)
FROM Sales.SalesOrderHeader
WHERE YEAR (OrderDate) = 2008 AND OnlineOrderFlag = 0
GROUP BY DATENAME (WEEKDAY, OrderDate)
ORDER BY RevenuePerOrder DESC





