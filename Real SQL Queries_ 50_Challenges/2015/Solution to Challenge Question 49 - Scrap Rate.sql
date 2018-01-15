
--Solution to Challenge Question 49: Scrap Rate

--DROP VIEW Production.Vw_ScrapRates

CREATE VIEW Production.Vw_ScrapRates

AS

SELECT TOP 10 PERCENT
	N1.WorkOrderID
	,DueDate =			CAST (N1.DueDate AS DATE)
	,ProdName =			N3.Name
	,ScrapReason =		N2.Name
	,N1.ScrappedQty
	,N1.OrderQty
	,[PercScrapped] =	ROUND (N1.ScrappedQty / CONVERT (FLOAT, N1.OrderQty)* 100, 2)
FROM Production.WorkOrder N1
INNER JOIN Production.ScrapReason N2 ON N1.ScrapReasonID = N2.ScrapReasonID
INNER JOIN Production.Product N3 ON N1.ProductID = N3.ProductID
WHERE N1.ScrappedQty / CONVERT (FLOAT, N1.OrderQty) >  0.03
ORDER BY N1.DueDate DESC


