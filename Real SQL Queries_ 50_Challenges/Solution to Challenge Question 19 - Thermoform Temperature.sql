
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution to Challenge Question 19: Thermoform Temperature 

WITH Temp AS 
	(SELECT
		RNK =				ROW_NUMBER () OVER (PARTITION BY N1.ProductID 
												ORDER BY COUNT (N2.Name) DESC)
		,N1.ProductID
		,ProductName =		N2.Name
		,WorkOrderCount =	COUNT (N2.Name)
		,ScrapReason =		N3.Name
		FROM Production.WorkOrder N1
		INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
		INNER JOIN Production.ScrapReason N3 ON N1.ScrapReasonID = N3.ScrapReasonID
		GROUP BY N1.ProductID, N2.Name, N3.Name)

SELECT
	ProductID
	,ProductName
	,WorkOrderCount
	,ScrapReason
FROM Temp
WHERE RNK = 1
ORDER BY WorkOrderCount DESC
