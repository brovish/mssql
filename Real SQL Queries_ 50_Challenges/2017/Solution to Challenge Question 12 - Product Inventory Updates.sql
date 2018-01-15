
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

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


