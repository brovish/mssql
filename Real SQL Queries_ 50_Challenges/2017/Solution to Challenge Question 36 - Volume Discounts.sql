
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 36: Volume Discounts

--DROP TABLE #data

SELECT
	N1.SalesOrderID 
	,N3.OrderDate
	,TotalVolumeDiscount =	SUM (N1.UnitPriceDiscount * N1.UnitPrice * N1.OrderQty)
INTO #data
FROM Sales.SalesOrderDetail N1
INNER JOIN Sales.SpecialOffer N2 ON N1.SpecialOfferID = N2.SpecialOfferID
INNER JOIN Sales.SalesOrderHeader N3 ON N1.SalesOrderID = N3.SalesOrderID
WHERE N2.[Type] = 'Volume Discount'
GROUP BY N1.SalesOrderID, N2.[Type], N3.OrderDate
HAVING SUM (N1.UnitPriceDiscount * N1.UnitPrice * N1.OrderQty) > 0

-- Part I
SELECT * 
FROM #data
ORDER BY SalesOrderID

-- Part II
SELECT 
	OrderYear =				YEAR (OrderDate)
	,TotalVolumeDiscount =	SUM (TotalVolumeDiscount)
FROM #data
GROUP BY YEAR (OrderDate)


