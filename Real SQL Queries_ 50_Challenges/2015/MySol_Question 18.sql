USE AdventureWorks2012;

SELECT PH.ProductID, P.Name, PS.Name, MIN(PH.StandardCost), MAX(PH.StandardCost), MAX(PH.StandardCost) - MIN(PH.StandardCost) AS DIFF, DENSE_RANK() OVER(ORDER BY MAX(PH.StandardCost) - MIN(PH.StandardCost)  DESC)AS RNK
FROM Production.ProductCostHistory AS PH
INNER JOIN Production.Product AS P ON P.ProductID = PH.ProductID
INNER JOIN Production.ProductSubcategory AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
GROUP BY PH.ProductID, P.Name, PS.Name
ORDER BY RNK