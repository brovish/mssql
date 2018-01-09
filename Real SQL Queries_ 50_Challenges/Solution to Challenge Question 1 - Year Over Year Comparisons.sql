
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

-- Solution 1 to Challenge Question 1: Year Over Year Comparisons

--DROP TABLE #data

SELECT 
	SalesPersonID
	,FY =			DATEPART (YEAR, DATEADD (MONTH, 6, OrderDate))
	,FQ =			DATEPART (QUARTER, DATEADD (MONTH, 6, OrderDate))
	,FQSales =		SUM (Subtotal)
INTO #data
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY 
	SalesPersonID
	,DATEPART (YEAR, DATEADD (MONTH, 6, OrderDate))
	,DATEPART (QUARTER, DATEADD (MONTH, 6, OrderDate))

SELECT
	N3.LastName
	,N1.*
	,SalesSameFQLastYr =	N2.FQSales
	,Change =				N1.FQSales - N2.FQSales
	,[%Change] =			((N1.FQSales - N2.FQSales) / N2.FQSales) * 100
FROM #data N1
LEFT JOIN #Data N2 ON 1 = 1
	AND N1.SalesPersonID = N2.SalesPersonID 
	AND N1.FQ = N2.FQ 
	AND N1.FY -1 = N2.FY
INNER JOIN Person.Person N3 ON N1.SalesPersonID = N3.BusinessEntityID
WHERE N1.FY = 2008
ORDER BY SalesPersonID, FY DESC, FQ DESC;
---------------------------
-- Solution 2 to Challenge Question 1: Year Over Year Comparisons

--DROP TABLE #data2

SELECT 
	SalesPersonID
	,FY =			DATEPART (YEAR, DATEADD (MONTH, 6, OrderDate))
	,FQ =			DATEPART (QUARTER, DATEADD (MONTH, 6, OrderDate))
	,FQSales =		SUM (Subtotal)
INTO #data2
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY 
	SalesPersonID
	,DATEPART (YEAR, DATEADD (MONTH, 6, OrderDate))
	,DATEPART (QUARTER, DATEADD (MONTH, 6, OrderDate));

WITH Final AS
(SELECT
		N2.LastName
		,N1.*
		,SalesSameFQLastYr =	LAG (FQSales, 4) OVER (PARTITION BY SalesPersonID ORDER BY FY, FQ)
		,Change =				N1.FQSales - LAG (FQSales, 4) OVER (PARTITION BY SalesPersonID ORDER BY FY, FQ)

		,[%Change] =			((N1.FQSales - LAG (FQSales, 4) OVER (PARTITION BY SalesPersonID ORDER BY FY, FQ))
									/ LAG (FQSales, 4) OVER (PARTITION BY SalesPersonID ORDER BY FY, FQ)) 
									* 100
FROM #data2 N1
INNER JOIN Person.Person N2 ON N1.SalesPersonID = N2.BusinessEntityID)

SELECT * 
FROM Final
WHERE FY = 2008
ORDER BY SalesPersonID, FY DESC, FQ DESC