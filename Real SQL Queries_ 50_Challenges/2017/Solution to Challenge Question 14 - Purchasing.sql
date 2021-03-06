
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 14: Purchasing

	SELECT  
		N1.ProductID
		,ProductName =		N2.Name
		,N3.OrderDate
		,QuantityOrdered =	SUM (N1.OrderQty) 	 
	FROM Purchasing.PurchaseOrderDetail N1
	INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
	INNER JOIN Purchasing.PurchaseOrderHeader N3 ON N1.PurchaseOrderID = N3.PurchaseOrderID
	WHERE YEAR (N3.OrderDate) = 2007
	GROUP BY N1.Productid, N2.Name, N3.OrderDate
	ORDER BY SUM (N1.OrderQty) DESC