
--Solution to Challenge Question 38: Margins

SELECT
	N1.ProductModelID
	,ProductName =		N4.Name
	,ProfitMargin =		CONVERT (DECIMAL(10,2), 
							CONVERT (FLOAT, (N1.ListPrice - N1.StandardCost)) / N1.StandardCost)
FROM Production.Product N1
INNER JOIN Production.ProductSubcategory N2 ON N1.ProductSubcategoryID = N2.ProductSubcategoryID
INNER JOIN Production.ProductCategory N3 ON N2.ProductCategoryID = N3.ProductCategoryID
INNER JOIN Production.ProductModel N4 ON N1.ProductModelID = N4.ProductModelID
WHERE N3.Name = 'Bikes' AND N1.SellEndDate IS NULL
GROUP BY 
	N1.ProductModelID
	,N4.Name
	,CONVERT (DECIMAL (10,2) 
	,CONVERT (FLOAT, (N1.ListPrice - N1.StandardCost)) / N1.StandardCost)
ORDER BY ProfitMargin DESC














