USE AdventureWorks2012;

;WITH CTE AS
(SELECT S.BusinessEntityID
	FROM Sales.SalesPersonQuotaHistory AS S
	WHERE S.QuotaDate >= '20120101' AND S.QuotaDate < '20140101'
	GROUP BY S.BusinessEntityID
	HAVING COUNT(S.QuotaDate) = 8
	)

, CTE2 AS (SELECT SPQH.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota
		, ROW_NUMBER() OVER(PARTITION BY SPQH.BusinessEntityID ORDER BY SPQH.QuotaDate) AS RN
		,PR.LastName
FROM Sales.SalesPersonQuotaHistory AS SPQH
INNER JOIN Person.Person AS PR ON PR.BusinessEntityID = SPQH.BusinessEntityID
INNER JOIN CTE ON CTE.BusinessEntityID = SPQH.BusinessEntityID
WHERE SPQH.QuotaDate >= '20120101' AND SPQH.QuotaDate < '20140101'
)
SELECT C1.BusinessEntityID, C1.LastName, C1.SalesQuota AS [2012STARTQUOTA]
		, C2.SalesQuota AS [2013ENDQUOTA]
		, (C2.SalesQuota - C1.SalesQuota) / C1.SalesQuota
FROM CTE2 AS C1
INNER JOIN CTE2 AS C2 ON C2.RN = 8 AND C1.RN =1 AND C1.BusinessEntityID = C2.BusinessEntityID
