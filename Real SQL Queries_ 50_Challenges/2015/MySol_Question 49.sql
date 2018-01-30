USE AdventureWorks2012;
GO

CREATE VIEW VWNAME 
AS

WITH CTE AS
(SELECT TOP(10) PERCENT WO.WorkOrderID, WO.DueDate, SR.Name, WO.ScrappedQty, WO.OrderQty, (100.0 * WO.ScrappedQty) / WO.OrderQty AS PCTSCRAP
FROM Production.WorkOrder AS WO
INNER JOIN Production.ScrapReason AS SR ON SR.ScrapReasonID = WO.ScrapReasonID
WHERE (100.0 * WO.ScrappedQty) / WO.OrderQty  > 3
ORDER BY PCTSCRAP DESC
)
SELECT TOP(100)PERCENT * 
FROM CTE
ORDER BY DueDate DESC
