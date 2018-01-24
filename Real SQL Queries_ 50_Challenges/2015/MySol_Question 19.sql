USE AdventureWorks2012;

;WITH CTE AS
(
SELECT WO.ProductID, PR.Name, COUNT(WO.WorkOrderID) AS ORCNT, SR.Name AS REASON
	,ROW_NUMBER() OVER(PARTITION BY WO.ProductID ORDER BY COUNT(WO.WorkOrderID) DESC) AS RN
FROM Production.ScrapReason AS SR 
INNER JOIN Production.WorkOrder AS WO ON WO.ScrapReasonID = SR.ScrapReasonID
INNER JOIN Production.Product AS PR ON PR.ProductID = WO.ProductID
GROUP BY WO.ProductID, PR.Name, SR.Name
--ORDER BY WO.ProductID, PR.Name, SR.Name
--SUM(WO.WorkOrderID),
)
SELECT *
FROM CTE 
WHERE RN = 1
ORDER BY ProductID, RN