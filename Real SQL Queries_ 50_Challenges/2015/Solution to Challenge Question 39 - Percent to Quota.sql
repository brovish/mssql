USE AdventureWorks2012;
--Solution to Challenge Question 39: Percent to Quota


--	Part I

--DROP TABLE #SalesQuotaSummary

SELECT
	 N1.BusinessEntityID
	,N1.QuotaDate
	,N1.SalesQuota
	,ActualSales = CONVERT (DECIMAL (10,2), SUM (N2.SubTotal))
	,PercToQuota = CONVERT (DECIMAL (10,2), CONVERT (FLOAT, SUM (N2.SubTotal)) / N1.SalesQuota)
INTO #SalesQuotaSummary
FROM Sales.SalesPersonQuotaHistory N1
LEFT JOIN Sales.SalesOrderHeader N2 ON N1.BusinessEntityID = N2.SalesPersonID
								AND N2.OrderDate >= N1.QuotaDate 
								AND N2.OrderDate < DATEADD (MONTH, 3, N1.QuotaDate)
GROUP BY 
	N1.BusinessEntityID
	,N1.QuotaDate
	,N1.SalesQuota

SELECT *
FROM #SalesQuotaSummary
ORDER BY BusinessEntityID, QuotaDate

--	Part II
SELECT
	BusinessEntityID
	,QuotaYear =			YEAR (QuotaDate)
	,TotalQuota	=			SUM (SalesQuota)
	,TotalSales	=			SUM (ActualSales)
	,TotalPercToQuota =		CONVERT (DECIMAL (10,2), CONVERT (FLOAT, SUM (ActualSales)) / SUM (SalesQuota))
	,AvgQrtlyPercToQuota =	CONVERT (DECIMAL (10,2), AVG (PercToQuota))
FROM #SalesQuotaSummary
GROUP BY BusinessEntityID, YEAR (QuotaDate)
ORDER BY BusinessEntityID, YEAR (QuotaDate)