USE AdventureWorks2012;

SELECT DATEPART(WEEKDAY,SH.OrderDate),SUM(SH.SubTotal), COUNT(*),SUM(SH.SubTotal)/ COUNT(*)
FROM Sales.SalesOrderHeader AS SH
WHERE YEAR(SH.OrderDate)=2011 AND SH.OnlineOrderFlag = 0
GROUP BY DATEPART(WEEKDAY,SH.OrderDate)
ORDER BY SUM(SH.SubTotal)/ COUNT(*) DESC

SELECT DATENAME(WEEKDAY,SH.OrderDate),SUM(SH.SubTotal), COUNT(*),SUM(SH.SubTotal)/ COUNT(*)
FROM Sales.SalesOrderHeader AS SH
WHERE YEAR(SH.OrderDate)=2011 AND SH.OnlineOrderFlag = 0
GROUP BY DATENAME(WEEKDAY,SH.OrderDate)
ORDER BY SUM(SH.SubTotal)/ COUNT(*) DESC