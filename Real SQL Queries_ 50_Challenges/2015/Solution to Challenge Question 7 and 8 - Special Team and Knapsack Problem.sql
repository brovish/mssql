USE AdventureWorks2012;

--Solution to Challenge Questions 7: Special Team

--DROP TABLE #2008RevbySalesPerson

SELECT
	SalesPersonID
	,[2008Sales] =	SUM (Subtotal)
INTO #2008RevbySalesPerson
FROM Sales.SalesOrderHeader N1
--WHERE YEAR (N1.OrderDate) = 2008
WHERE N1.OrderDate >= '20110101' AND N1.OrderDate < '20120101' 
GROUP BY SalesPersonID

--DROP TABLE #TerritoriesAndSales

SELECT
	N1.BusinessEntityID
	,N3.LastName
	,Territory = N2.Name
	,N4.[2008Sales]	
INTO #TerritoriesAndSales
FROM Sales.SalesTerritoryHistory N1
INNER JOIN Sales.SalesTerritory N2 ON N1.TerritoryID = N2.TerritoryID
INNER JOIN Person.Person N3 ON N1.BusinessEntityID = N3.BusinessEntityID
INNER JOIN #2008RevbySalesPerson N4 ON N1.BusinessEntityID = N4.SalesPersonID
WHERE 1 = 1
	AND N1.EndDate IS NULL
	AND N2.Name IN ('Northwest', 'Southwest', 'Canada')

SELECT * FROM #TerritoriesAndSales 
ORDER BY Territory, LastName

-- Solution to Challenge Question 8: Knapsack Problem

ALTER TABLE #TerritoriesAndSales
ADD Salary MONEY

UPDATE N1
SET Salary = CASE WHEN LastName = 'CAMPBELL' THEN 79500 WHEN LastName = 'Vargas' THEN 60000
						WHEN LastName = 'Saraiva' THEN 59500  WHEN LastName = 'Mitchell' THEN 56000 
						WHEN LastName = 'Ansman-Wolfe' THEN 680000  WHEN LastName = 'Ito' THEN 80000 END
			--CASE 
			--	WHEN LastName = 'Pak'	THEN 79500
			--	WHEN LastName = 'Vargas' THEN  60000
			--	WHEN LastName = 'Campbell' THEN 59500
			--	WHEN LastName = 'Mensa-Annan' THEN 56000
			--	WHEN LastName = 'Ito' THEN 68000
			--	WHEN LastName = 'Mitchell' THEN 80000 END
FROM #TerritoriesAndSales N1

--	SELECT * FROM #TerritoriesAndSales ORDER BY Territory, LastName

--DROP TABLE #Canada
--DROP TABLE #Northwest
--DROP TABLE #Southwest

SELECT * INTO #Canada		FROM #TerritoriesAndSales WHERE Territory = 'Canada'
SELECT * INTO #Northwest	FROM #TerritoriesAndSales WHERE Territory = 'Northwest'
SELECT * INTO #Southwest	FROM #TerritoriesAndSales WHERE Territory = 'Southwest'

--	SELECT * FROM #Canada SELECT * FROM #Northwest SELECT * FROM #Southwest

--DROP TABLE #final

SELECT
	AggregateSalary =			N1.Salary + N2.Salary + N3.Salary
	,AggregateSales =			N1.[2008Sales] + N2.[2008Sales] + N3.[2008Sales]
	,[1stTerritory] =			N1.Territory
	,[1stSalesPerson] =			N1.LastName
	,[1stSalesPersonSales] =	N1.[2008Sales]
	,[1stSalary] =				N1.Salary
	,[2ndTerritory] =			N2.Territory
	,[2ndSalesPerson] =			N2.LastName
	,[2ndSalesPersonSales] =	N2.[2008Sales]
	,[2ndSalary] =				N2.Salary
	,[3rdTerritory] =			N3.Territory
	,[3rdSalesPerson] =			N3.LastName
	,[3rdSalesPersonSales] =	N3.[2008Sales]
	,[3rdSalary] =				N3.Salary
INTO #final
FROM #Canada N1
CROSS JOIN #Northwest N2
CROSS JOIN #Southwest N3

--	SELECT * FROM #final ORDER BY AggregateSales DESC
SELECT * 
FROM #final 
WHERE AggregateSalary < 210000
ORDER BY AggregateSales DESC

SELECT TOP 1 * 
FROM #final 
WHERE AggregateSalary < 210000
ORDER BY AggregateSales DESC