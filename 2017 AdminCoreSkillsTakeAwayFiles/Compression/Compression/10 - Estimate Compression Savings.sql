USE AdventureWorksDW;
GO

EXEC sp_estimate_data_compression_savings 
  @schema_name = 'dbo',
  @object_name = 'FactResellerSales',
  @index_id = 1,
  @partition_number = NULL,
  @data_compression = 'ROW';
GO

SELECT 6336 * 100 / 12032;
GO

EXEC sp_estimate_data_compression_savings 
  @schema_name = 'dbo',
  @object_name = 'FactResellerSales',
  @index_id = 1,
  @partition_number = NULL,
  @data_compression = 'PAGE';
GO

SELECT 2856 * 100 / 12032;
GO

USE tempdb;
GO
