USE AdventureWorks2012;

--Solution to Challenge Question 48: Sales Quota Changes

SELECT DISTINCT
	N1.BusinessEntityID
	,SalesRepLastName =		N4.LastName
	,Yr2006StartQuota =		N2.SalesQuota
	,Yr2007EndQuota =		N3.SalesQuota
	,[%ChangeQuota] =		(N3.SalesQuota - N2.SalesQuota) / N2.SalesQuota * 100
FROM Sales.SalesPersonQuotaHistory N1
INNER JOIN Sales.SalesPersonQuotaHistory N2 ON
	N1.BusinessEntityID = N2.BusinessEntityID 
	AND N2.QuotaDate = (SELECT MIN (QuotaDate) 
						FROM Sales.SalesPersonQuotaHistory 
						WHERE YEAR (QuotaDate) = 2012)
INNER JOIN Sales.SalesPersonQuotaHistory N3 ON
	N1.BusinessEntityID = N3.BusinessEntityID
	AND N3.QuotaDate = (SELECT MAX (QuotaDate) 
						FROM Sales.SalesPersonQuotaHistory 
						WHERE YEAR (QuotaDate) = 2013)
INNER JOIN Person.Person AS N4 ON N1.BusinessEntityID = N4.BusinessEntityID
