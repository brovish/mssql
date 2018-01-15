-- Solution to Challenge Question 12: Product Inventory Updates

--DROP VIEW Production.Vw_Product_Inventory

CREATE VIEW Production.Vw_Product_Inventory

AS

SELECT
	LocationID =		CASE 
							WHEN GROUPING (LocationID) = 1 THEN CONVERT (VARCHAR (5), 'Total')
							ELSE CONVERT (VARCHAR (5), LocationID) 
						END

	,DistinctProducts = COUNT (DISTINCT ProductID)
	,Quantity =			SUM (Quantity)
FROM Production.ProductInventory
GROUP BY LocationID WITH ROLLUP


