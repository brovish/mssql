--Solution to Challenge Question 9: Product Combinations

-- Temp table to be utilzied throughout all parts of the solution

--DROP TABLE #ProductSales

SELECT
	N1.CustomerID
	,N1.SalesOrderID
	,ProductType =		N5.Name
	,N3.ProductLine
	,N3.ProductID
INTO #ProductSales
FROM Sales.SalesOrderHeader N1
INNER JOIN Sales.SalesOrderDetail N2 ON N1.SalesOrderID = N2.SalesOrderID
INNER JOIN Production.Product N3 ON N2.ProductID = N3.ProductID
INNER JOIN Production.ProductSubcategory N4 ON N3.ProductSubcategoryID = N4.ProductSubcategoryID  
INNER JOIN Production.ProductCategory N5 ON N4.ProductCategoryID = N5.ProductCategoryID

-- Part I
DECLARE @TotalOrders FLOAT = (SELECT COUNT (DISTINCT SalesOrderID) FROM #ProductSales)

DECLARE @BikeAccessoryOrders FLOAT 
= (SELECT COUNT (DISTINCT N1.SalesOrderID)
   FROM #ProductSales N1
   INNER JOIN #ProductSales N2 ON N1.SalesOrderID = N2.SalesOrderID
   WHERE N1.ProductType = 'Bikes' 
		AND N2.ProductType = 'Accessories')

SELECT BikeAndAccessory 
	= CONVERT (VARCHAR(10), 
			CONVERT (DECIMAL (5,2), 
				(@BikeAccessoryOrders / @TotalOrders) * 100)) + ' %'

DECLARE @BikeClothingOrders FLOAT
	= (SELECT COUNT (*)
		FROM (SELECT SalesOrderID
				FROM #ProductSales
				GROUP BY SalesOrderID
				HAVING SUM (CASE WHEN ProductType = 'Bikes' THEN 1 ELSE 0 END) > = 1
				AND SUM (CASE WHEN ProductType = 'Clothing' THEN 1 ELSE 0 END) > = 2)                              
		X1)

SELECT BikeAndClothing = CONVERT (VARCHAR(10), 
							CONVERT (DECIMAL (5,2), 
								(@BikeClothingOrders / @TotalOrders) * 100)) + ' %'


-- Part II

--DROP TABLE #Pivot

SELECT *
INTO #Pivot
FROM (SELECT DISTINCT SalesOrderID, ProductType, Cnt = 1
		FROM #ProductSales) N1
PIVOT (COUNT (Cnt)
		FOR ProductType IN ([Bikes], [Accessories], [Clothing], [Components])                                
		) X1

SELECT Bikes, Accessories, Clothing, Components, Orders = COUNT(*)
FROM #Pivot
GROUP BY Bikes, Accessories, Clothing, Components
ORDER BY Bikes, Accessories, Clothing, Components
	
-- Part III

--DROP TABLE #Pivot2

SELECT *
INTO #Pivot2
FROM (SELECT DISTINCT CustomerID, ProductLine, Cnt = 1                                             
		FROM #ProductSales) N1
PIVOT (COUNT (Cnt)
		FOR ProductLine IN ([M],[S],[T],[R])
		) X1

SELECT M, S, T, R, Customers = COUNT (*)
FROM #Pivot2
GROUP BY M, S, T, R
ORDER BY M, S, T, R



	





