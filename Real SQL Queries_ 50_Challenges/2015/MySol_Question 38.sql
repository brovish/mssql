USE AdventureWorks2012;

SELECT  PR.ProductModelID, PM.Name, ROUND((PR.ListPrice - PR.StandardCost) / PR.StandardCost,2,1) AS PROFIT
FROM Production.Product AS PR
INNER JOIN Production.ProductModel AS PM ON PM.ProductModelID = PR.ProductModelID
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON PC.ProductCategoryID = PSC.ProductCategoryID
WHERE PC.Name = 'BIKES' AND PR.SellEndDate IS NULL
GROUP BY 
	PR.ProductModelID
	,PM.Name
	,ROUND((PR.ListPrice - PR.StandardCost) / PR.StandardCost,2,1) 
ORDER BY PROFIT DESC