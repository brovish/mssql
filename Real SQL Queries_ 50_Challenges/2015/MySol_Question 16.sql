USE AdventureWorks2012;

SET STATISTICS IO ON;

--SELECT SH.TerritoryID, COUNT(SH.SalesOrderID) AS TOT 
--	,CAST(CAST(100.0*(SELECT COUNT(SH1.SalesOrderID) FROM Sales.SalesOrderHeader AS SH1 WHERE SH1.OnlineOrderFlag=1 AND SH1.TerritoryID=SH.TerritoryID  GROUP BY SH1.TerritoryID)/COUNT(SH.SalesOrderID) AS INT) AS NVARCHAR) + '%' AS ONLINEPERCENT
--	,CAST(CAST(100.0*(SELECT COUNT(SH1.SalesOrderID) FROM Sales.SalesOrderHeader AS SH1 WHERE SH1.OnlineOrderFlag=0 AND SH1.TerritoryID=SH.TerritoryID  GROUP BY SH1.TerritoryID)/COUNT(SH.SalesOrderID) AS INT) AS NVARCHAR) + '%' AS NOTONLINEPERCENT

--FROM Sales.SalesOrderHeader AS SH
--GROUP BY SH.TerritoryID
--ORDER BY TerritoryID

--THIS ABOVE SOLUTION IS VER INEFFICIENT AS WE ARE USING SUBQUERIES. SO WORK IS GETTING REPEATED. ALTERNATE SOLUTION IS
--TO USE CASE STATEMENT INSIDE AGGREGATE FUNCS FOR GROUPS ASSOCIATED WITH THE OUTER 'GROUP BY'. 
SELECT SH.TerritoryID, COUNT(SH.SalesOrderID) AS TOT 
	,CAST(CAST(100.0*(COUNT(CASE WHEN OnlineOrderFlag=1 THEN 1 ELSE 0 END))/COUNT(SH.SalesOrderID) AS INT) AS NVARCHAR) + '%' AS ONLINEPERCENT
	,CAST(CAST(100.0*(COUNT(CASE WHEN OnlineOrderFlag=0 THEN 1 ELSE 0 END))/COUNT(SH.SalesOrderID) AS INT) AS NVARCHAR) + '%' AS NOTONLINEPERCENT
FROM Sales.SalesOrderHeader AS SH
GROUP BY SH.TerritoryID
ORDER BY TerritoryID
