USE AdventureWorks2012;


;WITH CTE AS
(SELECT SPQH.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota
		,ROW_NUMBER() OVER(PARTITION BY SPQH.BusinessEntityID ORDER BY SPQH.QuotaDate) AS RN
FROM Sales.SalesPersonQuotaHistory AS SPQH
)
SELECT SP.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota, SUM(SOH.SubTotal) AS ACTSALES, SUM(SOH.SubTotal) / SPQH.SalesQuota AS PCT
INTO #T1
FROM CTE AS SPQH
INNER JOIN Sales.SalesPerson AS SP ON SP.BusinessEntityID = SPQH.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesPersonID = SP.BusinessEntityID 
		AND SOH.OrderDate >= SPQH.QuotaDate AND SOH.OrderDate < ISNULL((SELECT T.QuotaDate FROM CTE AS T WHERE T.RN  = SPQH.RN + 1
																	AND T.BusinessEntityID = SPQH.BusinessEntityID)
																	--,(SELECT T.QuotaDate FROM CTE AS T WHERE T.RN -1  = SPQH.RN 
																	--AND T.BusinessEntityID = SPQH.BusinessEntityID)
																	,DATEFROMPARTS(9999,1,1))
																	 
GROUP BY SP.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota
ORDER BY SP.BusinessEntityID, SPQH.QuotaDate

SELECT *
FROM #T1
ORDER BY BusinessEntityID, QuotaDate


--PART2
SELECT BusinessEntityID, YEAR(F.QuotaDate), SUM(SalesQuota) AS TOTQ, SUM(F.ACTSALES) AS TOTS
		,SUM(F.ACTSALES) / SUM(SalesQuota) AS PCTQUOTAA
		,AVG(F.PCT) AS AVGQRTLYPCT
FROM #T1 AS F
GROUP BY BusinessEntityID, YEAR(F.QuotaDate)
ORDER BY BusinessEntityID, YEAR(F.QuotaDate)


--DEBUGGING
--SELECT S.SalesPersonID, SUM(S.SubTotal)
--FROM Sales.SalesOrderHeader AS S
--WHERE S.SalesPersonID = 274 AND S.OrderDate>= '2011-12-01' AND S.OrderDate < '2012-02-29'
--GROUP BY S.SalesPersonID