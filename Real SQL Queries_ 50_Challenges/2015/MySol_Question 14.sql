USE AdventureWorks2012;

SELECT POD.ProductID, PR.Name, PH.OrderDate, SUM(POD.OrderQty) AS QTY
FROM Purchasing.PurchaseOrderHeader AS PH INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POD.PurchaseOrderID = PH.PurchaseOrderID
INNER JOIN Production.Product AS PR ON PR.ProductID = POD.ProductID
WHERE PH.OrderDate >= '20100101' AND PH.OrderDate < '20120101' 
GROUP BY POD.ProductID, PR.Name, PH.OrderDate
ORDER BY QTY DESC

