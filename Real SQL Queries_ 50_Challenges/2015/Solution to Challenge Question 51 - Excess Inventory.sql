USE AdventureWorks2012;
--Solution to Challenge Question 51: Excess Inventory


-- Part I
SELECT
	SpecialOfferID
	,DiscountType =		[Type]
	,DiscountDescr	=	[Description]
	,Category
	,StartDate
	,EndDate
	,DiscountPct
FROM Sales.SpecialOffer
WHERE [Type] = 'Excess Inventory' 


-- Part II
SELECT
	N1.SpecialOfferID
	,DiscountType =		[Type]
	,DiscountDescr	=	[Description]
	,N1.Category
	,N1.StartDate
	,N1.EndDate
	,N1.DiscountPct
	,SalesOrders =		(SELECT COUNT (DISTINCT X1.SalesOrderID)
						 FROM Sales.SalesOrderDetail X1
						 WHERE N1.SpecialOfferID = X1.SpecialOfferID)
FROM Sales.SpecialOffer N1
WHERE N1.[Type] = 'Excess Inventory'










