
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 16: Online/Offline

SELECT
	TerritoryID
	,TotalOrders			= COUNT(*)
	,PercOnline				= CONVERT(VARCHAR(50),
								ROUND(
									(CONVERT(FLOAT,
										SUM(CASE WHEN OnlineOrderFlag = 1 THEN 1 ELSE 0 END)) 
										/COUNT(*))
										* 100
									,0)
								) + '%'
	,PercOffline			= CONVERT(VARCHAR(50),
								ROUND(
									(CONVERT(FLOAT,
										SUM(CASE WHEN OnlineOrderFlag = 0 THEN 1 ELSE 0 END)) 
										/COUNT(*))
										* 100
									,0)
								) + '%'
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
ORDER BY TerritoryID