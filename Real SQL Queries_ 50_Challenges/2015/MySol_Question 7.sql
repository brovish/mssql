USE AdventureWorks2012;

SELECT  EMP.LoginID, ST.Name, SUM(SH.SubTotal)
FROM Sales.SalesPerson AS SP INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID = SP.TerritoryID  INNER JOIN Sales.SalesOrderHeader AS SH ON SH.SalesPersonID = SP.BusinessEntityID INNER JOIN
HumanResources.Employee AS EMP ON EMP.BusinessEntityID = SP.BusinessEntityID
WHERE SH.OrderDate >= '20110101' AND SH.OrderDate < '20120101' 
GROUP BY EMP.LoginID, ST.Name
HAVING ST.Name IN ('NorthWest','Southwest', 'Canada')

DROP TABLE #TOPSALESPERSON
--with salary
SELECT  PR.BusinessEntityID,PR.FirstName,PR.LastName, ST.Name, SUM(SH.SubTotal) AS TOTALSALES
INTO #TOPSALESPERSON
FROM Sales.SalesPerson AS SP INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID = SP.TerritoryID  INNER JOIN Sales.SalesOrderHeader AS SH ON SH.SalesPersonID = SP.BusinessEntityID INNER JOIN
Person.Person AS PR ON PR.BusinessEntityID = SP.BusinessEntityID
WHERE SH.OrderDate >= '20110101' AND SH.OrderDate < '20120101' 
GROUP BY PR.BusinessEntityID, PR.FirstName, PR.LastName, ST.Name
HAVING ST.Name IN ('NorthWest','Southwest', 'Canada')

ALTER TABLE #TOPSALESPERSON
	ADD SALARY MONEY
	
UPDATE #TOPSALESPERSON
	SET SALARY = CASE WHEN LastName = 'CAMPBELL' THEN 79500 WHEN LastName = 'Vargas' THEN 60000
						WHEN LastName = 'Saraiva' THEN 59500  WHEN LastName = 'Mitchell' THEN 56000 
						WHEN LastName = 'Ansman-Wolfe' THEN 680000  WHEN LastName = 'Ito' THEN 80000 END


;WITH CTE AS
(SELECT T1.LastName AS T1LASTNAME, T1.Name AS T1TERRITORYNAME, T1.TOTALSALES AS T1SALES, T2.LastName AS T2LASTNAME, T2.Name AS T2TERRITORYNAME, T2.TOTALSALES AS T2SALES, T3.LastName AS T3LASTNAME, T3.Name AS T3TERRITORYNAME, T3.TOTALSALES AS T3SALES, 
	(T1.TOTALSALES + T2.TOTALSALES + T3.TOTALSALES) AS TOTALSALES, (T1.SALARY + T2.SALARY + T3.SALARY) AS TOTALSALARY
--FROM #TOPSALESPERSON AS T1 CROSS JOIN #TOPSALESPERSON AS T2 CROSS JOIN #TOPSALESPERSON AS T3
FROM #TOPSALESPERSON AS T1 INNER JOIN #TOPSALESPERSON AS T2 ON T1.LastName <= T2.LastName INNER JOIN #TOPSALESPERSON AS T3 ON T2.LastName <= T3.LastName
WHERE T1.BusinessEntityID != T2.BusinessEntityID AND T2.BusinessEntityID != T3.BusinessEntityID AND T1.BusinessEntityID != T3.BusinessEntityID 
	AND T1.Name != T2.Name AND T1.Name != T3.Name AND T3.Name != T2.Name
)
SELECT distinct * 
FROM CTE
WHERE CTE.TOTALSALARY <210000
ORDER BY TOTALSALES DESC


--;WITH CTE AS
--(SELECT T1.LastName AS T1LASTNAME, T2.LastName AS T2LASTNAME, T3.LastName AS T3LASTNAME,
--	(T1.TOTALSALES + T2.TOTALSALES + T3.TOTALSALES) AS TOTALSALES, (T1.SALARY + T2.SALARY + T3.SALARY) AS TOTALSALARY
--FROM #TOPSALESPERSON AS T1 CROSS JOIN #TOPSALESPERSON AS T2 CROSS JOIN #TOPSALESPERSON AS T3
--WHERE T1.BusinessEntityID != T2.BusinessEntityID AND T2.BusinessEntityID != T3.BusinessEntityID AND T1.BusinessEntityID != T3.BusinessEntityID 
--	AND T1.Name != T2.Name AND T1.Name != T3.Name AND T3.Name != T2.Name
--)
--SELECT distinct * 
--FROM CTE
--WHERE CTE.TOTALSALARY <210000
--ORDER BY TOTALSALES DESC

--;WITH CTE AS
--(SELECT T1.LastName AS T1LASTNAME, T2.LastName AS T2LASTNAME, T3.LastName AS T3LASTNAME,
--	(T1.TOTALSALES + T2.TOTALSALES + T3.TOTALSALES) AS TOTALSALES, (T1.SALARY + T2.SALARY + T3.SALARY) AS TOTALSALARY
--FROM #TOPSALESPERSON AS T1 INNER JOIN #TOPSALESPERSON AS T2 ON T1.BusinessEntityID <= T2.BusinessEntityID INNER JOIN #TOPSALESPERSON AS T3 ON T2.BusinessEntityID <= T3.BusinessEntityID
--WHERE T1.BusinessEntityID != T2.BusinessEntityID AND T2.BusinessEntityID != T3.BusinessEntityID AND T1.BusinessEntityID != T3.BusinessEntityID 
--	AND T1.Name != T2.Name AND T1.Name != T3.Name AND T3.Name != T2.Name
--)
--SELECT distinct * 
--FROM CTE
--WHERE CTE.TOTALSALARY <210000
--ORDER BY TOTALSALES DESC

--;WITH CTE AS
--(SELECT T1.LastName AS T1LASTNAME, T2.LastName AS T2LASTNAME, T3.LastName AS T3LASTNAME,
--	(T1.TOTALSALES + T2.TOTALSALES + T3.TOTALSALES) AS TOTALSALES, (T1.SALARY + T2.SALARY + T3.SALARY) AS TOTALSALARY
--FROM #TOPSALESPERSON AS T1 INNER JOIN #TOPSALESPERSON AS T2 ON T1.LastName <= T2.LastName INNER JOIN #TOPSALESPERSON AS T3 ON T2.LastName <= T3.LastName
--WHERE T1.BusinessEntityID != T2.BusinessEntityID AND T2.BusinessEntityID != T3.BusinessEntityID AND T1.BusinessEntityID != T3.BusinessEntityID 
--	AND T1.Name != T2.Name AND T1.Name != T3.Name AND T3.Name != T2.Name
--)
--SELECT distinct * 
--FROM CTE
--WHERE CTE.TOTALSALARY <210000
--ORDER BY TOTALSALES DESC





