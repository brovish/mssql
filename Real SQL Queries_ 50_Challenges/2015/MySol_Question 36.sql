USE AdventureWorks2012;

SELECT SOH.SalesOrderID, SOH.OrderDate, SUM (SOD.UnitPriceDiscount * SOD.UnitPrice * SOD.OrderQty) AS VOLDISC
INTO #T
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID = SOH.SalesOrderID
--INNER JOIN Sales.SpecialOfferProduct AS SPOP ON SPOP.ProductID = SOD.ProductID
INNER JOIN Sales.SpecialOffer AS SPO ON SPO.SpecialOfferID = SOD.SpecialOfferID
WHERE SPO.Type = 'Volume Discount'
GROUP BY SOH.SalesOrderID, SOH.OrderDate
ORDER BY SOH.SalesOrderID

SELECT YEAR(T.OrderDate), SUM(T.VOLDISC)
FROM #T AS T
GROUP BY YEAR(T.OrderDate)
ORDER BY YEAR(T.OrderDate)
