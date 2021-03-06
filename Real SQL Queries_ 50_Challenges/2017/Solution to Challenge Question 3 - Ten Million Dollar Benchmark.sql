/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012


-- Solutions to Challenge Question 3: Ten Million Dollar Benchmark

--------------
-- SOLUTION 1
--------------

DROP TABLE #Sales

SELECT
	FiscalYear =	YEAR (DATEADD (MONTH, 6, OrderDate))
	,OrderDate =	CAST(OrderDate AS DATE)
	,OrderNumber =	ROW_NUMBER () OVER (PARTITION BY YEAR (DATEADD (MONTH, 6, OrderDate)) 
										ORDER BY OrderDate)
	,SubTotal
	,RunningTotal =	CONVERT (FLOAT, NULL)
INTO #Sales
FROM Sales.SalesOrderHeader

UPDATE N1 SET
	RunningTotal =	(SELECT SUM (SubTotal)
						FROM #Sales X1
						WHERE N1.FiscalYear = X1.FiscalYear
						AND X1.OrderNumber <= N1.OrderNumber)
FROM #Sales N1


DROP TABLE #FindOrder

SELECT
	FiscalYear
	,OrderNumberOver10M =	(SELECT TOP 1 X1.OrderNumber
								FROM #Sales X1
								WHERE N1.FiscalYear = X1.FiscalYear
								AND X1.RunningTotal > = 100000
								ORDER BY X1.RunningTotal)
INTO #FindOrder
FROM #Sales N1
GROUP BY N1.FiscalYear

SELECT
	N2.FiscalYear
	,N2.OrderDate
	,N2.OrderNumber
	,N2.RunningTotal
FROM #FindOrder N1
INNER JOIN #Sales N2 ON N1.FiscalYear = N2.FiscalYear
				AND N1.OrderNumberOver10M = N2.OrderNumber
WHERE N1.FiscalYear IN (2011, 2012)

--------------
-- SOLUTION 2
--------------

;WITH FY2011 AS  
		(SELECT
			FY =			2011
			,OrderDate =	CAST (OrderDate AS DATE)
			,[OrderNumber] =	ROW_NUMBER () OVER (ORDER BY SalesOrderID)

			,RunningTotal =	SUM (SubTotal) OVER (ORDER BY Orderdate 
											ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
			FROM Sales.SalesOrderHeader
			WHERE DATEPART (YEAR, DATEADD (MONTH, 6, OrderDate)) = 2011)

	,FY2012 AS 
		(SELECT
			FY =			2012
			,OrderDate =	CAST (OrderDate AS DATE)
			,[OrderNumber] =	ROW_NUMBER () OVER (ORDER BY SalesOrderID)

			,RunningTotal =	SUM (SubTotal) OVER (ORDER BY Orderdate 
											ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
			FROM Sales.SalesOrderHeader
			WHERE DATEPART (YEAR, DATEADD (MONTH, 6, OrderDate)) = 2012)

SELECT TOP 1 * FROM FY2011 WHERE RunningTotal > = 100000
UNION
SELECT TOP 1 * FROM FY2012 WHERE RunningTotal > = 100000













		
