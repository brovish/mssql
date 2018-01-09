
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 18: Costs Vary

SELECT 
	N1.ProductID
	,ProductName =	N2.[Name]
	,SubCategory =	N3.[Name]
	,MinCost =		MIN (N1.StandardCost)
	,MaxCost =		MAX (N1.StandardCost)
	,CostVar=		MAX (N1.StandardCost) - MIN (N1.StandardCost)

	,CostVarRank =	CASE 
						WHEN MAX (N1.StandardCost) - MIN (N1.StandardCost) = 0 THEN 0 
						ELSE DENSE_RANK () OVER (ORDER BY MAX (N1.StandardCost) - MIN (N1.StandardCost) DESC) 
					END

FROM Production.ProductCostHistory N1
INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
INNER JOIN Production.ProductSubcategory N3 ON N2.ProductSubcategoryID = N3.ProductSubcategoryID
GROUP BY N1.ProductID, N2.[Name], N3.[Name]
ORDER BY MAX (N1.StandardCost) - MIN (N1.StandardCost) DESC