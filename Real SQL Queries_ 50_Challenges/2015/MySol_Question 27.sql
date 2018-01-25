USE AdventureWorks2012;

SELECT WO.ProductID, COUNT(WO.WorkOrderID) AS TOTWO
FROM Production.WorkOrder AS WO
GROUP BY WO.ProductID
ORDER BY TOTWO DESC

SELECT PR.Name, COUNT(WO.WorkOrderID) AS TOTWO
FROM Production.WorkOrder AS WO
INNER JOIN Production.Product AS PR ON PR.ProductID = WO.ProductID
GROUP BY PR.Name
ORDER BY TOTWO DESC

