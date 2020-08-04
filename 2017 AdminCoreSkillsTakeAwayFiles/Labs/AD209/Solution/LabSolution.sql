-- AD209 Solution

SELECT t.name AS TableName, i.name AS IndexName, i.type_desc AS IndexType, i.index_id AS IndexID
FROM sys.indexes AS i
INNER JOIN sys.tables AS t
ON i.object_id = t.object_id
ORDER BY t.name, i.index_id;
GO

SELECT CustomerOrderID, OrderDate, DeliveryDate, CinemaName 
FROM Sales.ShippedOrders 
WHERE OrderDate >= DATEADD(year,-2,SYSDATETIME())
ORDER BY OrderDate, CustomerOrderID;
GO

SELECT CinemaName, SUM(ShippedUnits) AS TotalUnits, SUM(ShippedUnits * PricePerUnit) AS TotalPrice 
FROM Sales.ShippedOrders 
WHERE OrderDate >= DATEADD(year, -2, SYSDATETIME())
GROUP BY CinemaName 
HAVING SUM(ShippedUnits) > 0
ORDER BY CinemaName;
GO

SELECT CinemaName, OrderDate, SUM(ShippedUnits * PricePerUnit) * 100.0 / SUM(ShippedUnits) AS AvgPricePerUnit
FROM Sales.ShippedOrders 
GROUP BY CinemaName, OrderDate 
ORDER BY CinemaName, OrderDate;
GO

SELECT DISTINCT CinemaName 
FROM Sales.ShippedOrders 
WHERE ShippedOuters <> ShippedUnits 
ORDER BY CinemaName DESC;
GO
