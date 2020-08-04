-- AD211 Lab Solution

-- Exercise 1

USE WarehouseManagement;
GO

EXEC sp_estimate_data_compression_savings 'Sales', 'ShippedOrders', NULL, NULL, 'ROW';
GO
EXEC sp_estimate_data_compression_savings 'Sales', 'ShippedOrders', NULL, NULL, 'PAGE';
GO

-- Exercise 2

ALTER TABLE Sales.ShippedOrders REBUILD WITH (DATA_COMPRESSION = ROW);
GO

-- Exercise 3

ALTER TABLE Sales.ShippedOrders REBUILD WITH (DATA_COMPRESSION = PAGE);
GO

-- Exercise 4

SELECT * FROM Sales.ShippedOrders;

