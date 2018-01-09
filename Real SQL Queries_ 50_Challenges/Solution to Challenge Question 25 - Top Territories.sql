
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--	Solution to Challenge Question 25: Top Territories

WITH TerritoryRank AS

(SELECT 
	FY =				YEAR (DATEADD (MONTH, 6, N1.OrderDate)) 
	,Territory =		N2.Name
	,Revenue =			SUM (N1.SubTotal)
	,[Territory$Rank] = DENSE_RANK () OVER (PARTITION BY YEAR (DATEADD (MONTH, 6, N1.OrderDate))   
											ORDER BY SUM (N1.Subtotal) DESC)
FROM Sales.SalesOrderHeader N1
INNER JOIN Sales.SalesTerritory N2 ON N1.TerritoryID = N2.TerritoryID
GROUP BY YEAR (DATEADD (MONTH, 6, N1.OrderDate)), N2.Name)

SELECT * 
FROM TerritoryRank 
WHERE FY IN (2006, 2007) AND Territory$Rank IN (1, 2) 
ORDER BY FY, Territory$Rank