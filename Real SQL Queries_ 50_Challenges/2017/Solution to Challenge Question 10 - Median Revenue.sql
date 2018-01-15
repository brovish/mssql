
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

--Solution 1 to Challenge Question 10: Median Revenue

--DROP TABLE #Sales

SELECT 
	OrderYear =		YEAR (OrderDate)
	,SubTotal
	,RowNumbForMedian = ROW_NUMBER () OVER (PARTITION BY YEAR (OrderDate) ORDER BY SubTotal)
INTO #Sales
FROM Sales.SalesOrderHeader

--DROP TABLE #SalesGrouped

SELECT
	OrderYear
	,NumbOrders	=		COUNT (*)
	,NumbOrdersEven	=	CASE WHEN COUNT (*) % 2 = 0 THEN 1 ELSE 0 END
	,FindMedian	=		(COUNT (*) / 2) + 1
	,Median	=			CONVERT (FLOAT, NULL)
INTO #SalesGrouped
FROM #Sales
GROUP BY OrderYear

UPDATE N1 SET
	Median = N2.SubTotal
FROM #SalesGrouped N1
INNER JOIN #Sales N2 ON N1.OrderYear = N2.OrderYear
					AND N1.FindMedian = N2.RowNumbForMedian
WHERE NumbOrdersEven = 0

UPDATE N1 SET
	Median =			(SELECT AVG (SubTotal)
							FROM #Sales X1
							WHERE N1.OrderYear = X1.OrderYear
							AND X1.RowNumbForMedian IN (N1.FindMedian, (N1.FindMedian - 1)))
FROM #SalesGrouped N1
WHERE NumbOrdersEven = 1

SELECT
	N1.OrderYear
	,MinSale =			MIN (SubTotal)
	,MaxSale =			MAX (SubTotal)
	,AvgSale =			AVG (SubTotal)
	,MedianSale =		N2.Median
FROM #Sales N1
INNER JOIN #SalesGrouped N2 ON N1.OrderYear = N2.OrderYear
GROUP BY N1.OrderYear, N2.Median
ORDER BY N1.OrderYear;

--Solution 2 to Challenge Question 10: Median Revenue

WITH MedianSales AS 
	(SELECT DISTINCT
		OrderYear =		YEAR (OrderDate)
		,MedianSale =	PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY Subtotal) 
							OVER (PARTITION BY YEAR (OrderDate))
	FROM Sales.SalesOrderHeader)

SELECT 
	OrderYear = YEAR (N1.OrderDate)
	,MinSale =	MIN (N1.SubTotal)
	,MaxSale =	MAX (N1.SubTotal)
	,AvgSale =	AVG (N1.SubTotal)
	,N2.MedianSale
FROM Sales.SalesOrderHeader N1
INNER JOIN MedianSales N2 ON YEAR (N1.OrderDate) = N2.OrderYear
GROUP BY YEAR (N1.OrderDate), N2.MedianSale
ORDER BY YEAR (N1.OrderDate)