USE AdventureWorks2012;

--Solution to Challenge Question 50: Reasons

WITH Reasons AS
	(SELECT
		N1.SalesOrderID
		,ReasonName =		N2.Name

		,ReasonInfluence =	CASE 
								WHEN COUNT (N3.SalesOrderID) >  1 
									THEN 'Contributing Reason'								
								WHEN COUNT (N3.SalesOrderID) = 1 
									THEN 'Exclusive Reason' END

		FROM Sales.SalesOrderHeaderSalesReason N1
		INNER JOIN Sales.SalesReason N2 ON N1.SalesReasonID = N2.SalesReasonID
		INNER JOIN Sales.SalesOrderHeaderSalesReason N3 ON N1.SalesOrderID = N3.SalesOrderID
		GROUP BY N1.SalesOrderID, N2.Name)

SELECT 
	ReasonName
	,ReasonInfluence
	,SalesOrderCount = COUNT (*)
FROM Reasons
GROUP BY ReasonName, ReasonInfluence
ORDER BY ReasonName, SalesOrderCount DESC









