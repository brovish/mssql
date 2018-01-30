USE AdventureWorks2012;

SELECT SO.SpecialOfferID, SO.Type, SO.Description, SO.Category, SO.StartDate, SO.EndDate, SO.DiscountPct
FROM Sales.SpecialOffer AS SO
WHERE SO.Type = 'Excess Inventory'


SELECT SO.SpecialOfferID, SO.Type, SO.Description, SO.Category, SO.StartDate, SO.EndDate, SO.DiscountPct, COUNT(DISTINCT SOD.SalesOrderID)
FROM Sales.SpecialOffer AS SO
--INNER JOIN Sales.SpecialOfferProduct AS SOP ON SOP.SpecialOfferID = SO.SpecialOfferID
LEFT OUTER JOIN Sales.SalesOrderDetail AS SOD ON SOD.SpecialOfferID = SO.SpecialOfferID
WHERE SO.Type = 'Excess Inventory'
GROUP BY SO.SpecialOfferID, SO.Type, SO.Description, SO.Category, SO.StartDate, SO.EndDate, SO.DiscountPct