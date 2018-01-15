USE AdventureWorks2012;

SELECT P.ProductID, P.Name, P.Color, P.ListPrice, PQ.Quantity
FROM Production.Product AS P INNER JOIN (SELECT ProductID, SUM(Quantity) AS Quantity FROM Production.ProductInventory GROUP BY ProductID) AS PQ ON PQ.ProductID = P.ProductID
WHERE P.FinishedGoodsFlag = 1 AND P.ListPrice >= 1500 AND PQ.Quantity >= 150 AND P.SellEndDate IS NULL


--SELECT *
--FROM Production.ProductInventory