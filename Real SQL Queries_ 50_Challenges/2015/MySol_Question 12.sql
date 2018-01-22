USE AdventureWorks2012;
GO

CREATE VIEW PRODUPDATES
AS

	SELECT CASE WHEN GROUPING(LC.LocationID)=1 THEN 'TOTAL' ELSE CAST(LC.LocationID AS varchar(8)) END AS LocationID, COUNT(DISTINCT PIV.ProductID) AS DISTPROD, SUM(PIV.Quantity) AS TOTALPROD FROM Production.ProductInventory AS PIV 
	INNER JOIN Production.Location AS LC ON LC.LocationID = PIV.LocationID
	GROUP BY  ROLLUP(LC.LocationID)
	--GROUP BY  ROLLUP(LC.LocationID, PIV.ProductID, PIV.Quantity)
	




