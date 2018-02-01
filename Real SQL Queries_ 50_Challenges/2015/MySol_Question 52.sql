USE AdventureWorks2012;

;WITH CTE AS
(SELECT EPH.BusinessEntityID, EPH.Rate, ROW_NUMBER() OVER (PARTITION BY EPH.BusinessEntityID ORDER BY EPH.RATECHANGEDATE DESC) AS RN
FROM HumanResources.EmployeePayHistory AS EPH
)
SELECT BusinessEntityID, [2] AS 'PREVRATE', [1] AS 'RATENOW', ROUND(100 * ([1] - [2]) / [2], 2, 1) AS PCTCHANGE
FROM 
	(SELECT * FROM CTE) AS C
PIVOT
	(
		SUM(C.Rate) FOR C.RN IN ([1],[2])
	) AS PVT;


--SELECT C.BusinessEntityID,  CASE WHEN C.RN = 2 THEN C.Rate ELSE NULL END AS PREVRATE
--FROM CTE AS C
--GROUP BY C.BusinessEntityID