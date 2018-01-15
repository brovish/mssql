--Solution to Challenge Question 1: Year Over Year Comparisons

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
ORDER BY SalesPersonID, FY DESC, FQ DESC