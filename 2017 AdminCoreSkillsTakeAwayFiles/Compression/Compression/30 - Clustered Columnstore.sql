USE Compression;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FactResellerSales')
  DROP TABLE dbo.FactResellerSales;
GO

SELECT * INTO dbo.FactResellerSales
FROM AdventureWorksDW.dbo.FactResellerSales;
GO

EXEC sp_spaceused 'dbo.FactResellerSales',false;
GO

CREATE CLUSTERED COLUMNSTORE INDEX PK_FactResellerSales
ON dbo.FactResellerSales
WITH (DATA_COMPRESSION = COLUMNSTORE);
GO

EXEC sp_spaceused 'dbo.FactResellerSales',false;
GO

SELECT 1704 * 100 / 12032;
GO

-- Updatable but with additional NC indexes in 2014 table still read-only
UPDATE TOP(1) dbo.FactResellerSales SET OrderDateKey = '20120101';
GO

USE tempdb;
GO

