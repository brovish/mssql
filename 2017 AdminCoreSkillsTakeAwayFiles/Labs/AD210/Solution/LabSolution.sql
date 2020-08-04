-- AD210 Lab Solution

-- Exercise 1
USE WarehouseManagement;
GO

CREATE PARTITION FUNCTION OrderDateKey_PF (int)
AS RANGE RIGHT FOR VALUES (20120101, 20130101, 20140101);
GO

SELECT $partition.OrderDateKey_PF (20110401);
GO
SELECT $partition.OrderDateKey_PF (20120101);
GO
SELECT $partition.OrderDateKey_PF (20130501);
GO
SELECT $partition.OrderDateKey_PF (20140901);
GO
SELECT $partition.OrderDateKey_PF (20150201);
GO

-- Exercise 2

CREATE PARTITION SCHEME OrderDateKey_PS 
AS PARTITION OrderDateKey_PF TO (ARCHIVEDATA, ARCHIVEDATA, USERDATA, USERDATA);
GO

-- Exercise 3

CREATE TABLE Sales.ShippedOrder
(
	CustomerOrderID int NOT NULL,
	OrderDateKey int NOT NULL,
	DeliveryDateKey int NOT NULL,
	CinemaKey int NOT NULL,
	ProductKey int NOT NULL,
	ShippedUnits decimal(18, 3) NOT NULL,
	PricePerUnit decimal(18, 2) NOT NULL,
	ShippedOuters decimal(18, 3) NOT NULL,
	PricePerOuter decimal(18, 2) NOT NULL,
	UnitsPerOuter int NOT NULL
) ON OrderDateKey_PS(OrderDateKey);
GO

INSERT Sales.ShippedOrder (CustomerOrderID, OrderDateKey, DeliveryDateKey, CinemaKey, ProductKey,
                           ShippedUnits, PricePerUnit, ShippedOuters, PricePerOuter, UnitsPerOuter)
SELECT CustomerOrderID, OrderDateKey, DeliveryDateKey, CinemaKey, ProductKey,
       ShippedUnits, PricePerUnit, ShippedOuters, PricePerOuter, UnitsPerOuter
FROM PopkornKrazeDW.Fact.ShippedOrder;
GO
