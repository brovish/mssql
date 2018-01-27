USE AdventureWorks2012;


SELECT SPQH.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota
		,ROW_NUMBER() OVER(PARTITION BY SPQH.BusinessEntityID ORDER BY SPQH.QuotaDate)
FROM Sales.SalesPersonQuotaHistory AS SPQH


SELECT SP.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota, SUM(SOH.SubTotal)
FROM Sales.SalesPersonQuotaHistory AS SPQH
INNER JOIN Sales.SalesPerson AS SP ON SP.BusinessEntityID = SPQH.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesPersonID = SP.BusinessEntityID AND SOH.OrderDate >= SPQH.QuotaDate
GROUP BY SP.BusinessEntityID, SPQH.QuotaDate, SPQH.SalesQuota
ORDER BY SP.BusinessEntityID, SPQH.QuotaDate