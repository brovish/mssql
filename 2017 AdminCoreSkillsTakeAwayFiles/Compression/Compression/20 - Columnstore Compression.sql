USE Compression;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FactResellerSales')
  DROP TABLE dbo.FactResellerSales;
GO

SELECT * INTO dbo.FactResellerSales
FROM AdventureWorksDW.dbo.FactResellerSales;
GO

-- Note index size 8KB

EXEC sp_spaceused 'dbo.FactResellerSales',false;
GO

SELECT * FROM sys.indexes WHERE OBJECT_NAME(object_id) = 'FactResellerSales';
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CX_FactResellerSales
ON dbo.FactResellerSales 
( ProductKey, OrderDateKey, DueDateKey, ShipDateKey, ResellerKey, EmployeeKey, 
  PromotionKey, CurrencyKey, SalesTerritoryKey, SalesOrderNumber, SalesOrderLineNumber, 
  RevisionNumber, OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct, 
  DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, 
  CarrierTrackingNumber, CustomerPONumber);
GO

-- would fail in 2012 and 2014

UPDATE TOP(1) dbo.FactResellerSales SET OrderDateKey = '20120101';
GO

EXEC sp_spaceused 'dbo.FactResellerSales',false;
GO

SELECT FLOOR(SUM(OnDiskSizeKB)) AS TotalSizeKB
FROM ( ( SELECT SUM(css.on_disk_size) / 1024.0 AS OnDiskSizeKB    
         FROM sys.indexes AS i    
	     INNER JOIN sys.partitions AS p        
	     ON i.object_id = p.object_id     
	     INNER JOIN sys.column_store_segments AS css        
	     ON css.hobt_id = p.hobt_id    
	     WHERE i.object_id = OBJECT_ID('FactResellerSales')     
	     AND i.type_desc = 'NONCLUSTERED COLUMNSTORE')   
	   UNION ALL   
	   ( SELECT SUM(csd.on_disk_size) / 1024.0 AS OnDiskSizeKB    
	     FROM sys.indexes AS i    
		 INNER JOIN sys.partitions AS p        
		 ON i.object_id = p.object_id     
		 INNER JOIN sys.column_store_dictionaries AS csd        
		 ON csd.hobt_id = p.hobt_id    
		 WHERE i.object_id = OBJECT_ID('FactResellerSales')     
		 AND i.type_desc = 'NONCLUSTERED COLUMNSTORE') 
	) AS s;
GO

SELECT 1559 * 100 / 12032;
GO

USE tempdb;
GO

