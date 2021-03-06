/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

--Solution to Challenge Question 6: Print Catalog

SELECT 
	N1.ProductID
	,ProductName =	N1.Name
	,N1.Color
	,N1.ListPrice
	,N2.TotalQty
FROM Production.Product N1
INNER JOIN (SELECT 
				ProductID
				,TotalQty = SUM (Quantity) 
			FROM Production.ProductInventory 
			GROUP BY ProductID) N2 ON N1.ProductID = N2.ProductID
WHERE N1.SellEndDate IS NULL 
		AND N2.TotalQty > = 150
		AND N1.ListPrice > = 1500
		AND N1.FinishedGoodsFlag = 1




