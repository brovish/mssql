
--Solution to Challenge Question 16: Online/Offline


SELECT
	TerritoryID
	,TotalOrders			= COUNT(*)
	,PercOnline				= CONVERT(VARCHAR(50),
								ROUND(
									(CONVERT(FLOAT,
										SUM(CASE WHEN OnlineOrderFlag = 1 THEN 1 ELSE 0 END)) 
										/COUNT(*))
										* 100
									,0)
								) + '%'
	,PercOffline			= CONVERT(VARCHAR(50),
								ROUND(
									(CONVERT(FLOAT,
										SUM(CASE WHEN OnlineOrderFlag = 0 THEN 1 ELSE 0 END)) 
										/COUNT(*))
										* 100
									,0)
								) + '%'
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
ORDER BY TerritoryID



