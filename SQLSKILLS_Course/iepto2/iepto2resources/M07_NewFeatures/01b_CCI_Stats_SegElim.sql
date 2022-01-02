/*============================================================================
  File:     01b_CCI_SegElim.sql

  SQL Server Versions: 2016 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

SET STATISTICS TIME, IO ON;
GO

USE ContosoRetailDW;
GO

/*
	check stats for the CCI
*/
DBCC SHOW_STATISTICS ('dbo.FactSales', PK_FactSales_SalesKey);
GO

/*
	check stats for the CCI
*/
DBCC SHOW_STATISTICS ('dbo.FactSales_CCI', CX_FactSales_CCI);
GO


/*
	update stats, just in case (?)
*/
UPDATE STATISTICS dbo.FactSales_CCI WITH FULLSCAN;
GO

/*
	check stats again
*/
DBCC SHOW_STATISTICS ('dbo.FactSales_CCI', CX_FactSales_CCI);
GO

DBCC SHOW_STATISTICS ('dbo.FactSales_CCISorted', CX_FactSales_CCISorted);
GO

/*
	run a point query
*/
SELECT 
	StoreKey, 
	ProductKey, 
	TotalCost
FROM dbo.FactSales_CCI 
WHERE DateKey = '2007-01-01';
GO

/*
	check stats now
*/
SELECT  [sch].[name] + '.' + [so].[name] AS [TableName] ,
        [si].[index_id] AS [Index ID] ,
        [ss].[name] AS [Statistic] ,
        STUFF(( SELECT  ', ' + [c].[name]
                FROM    [sys].[stats_columns] [sc]
                        JOIN [sys].[columns] [c] ON [c].[column_id] = [sc].[column_id]
                                                    AND [c].[object_id] = [sc].[OBJECT_ID]
                WHERE   [sc].[object_id] = [ss].[object_id]
                        AND [sc].[stats_id] = [ss].[stats_id]
                ORDER BY [sc].[stats_column_id]
              FOR
                XML PATH('')
              ), 1, 2, '') AS [ColumnsInStatistic] ,
        [ss].[auto_Created] AS [WasAutoCreated] ,
        [ss].[user_created] AS [WasUserCreated] ,
        [ss].[has_filter] AS [IsFiltered] ,
        [ss].[filter_definition] AS [FilterDefinition] ,
        [ss].[is_temporary] AS [IsTemporary]
FROM    [sys].[stats] [ss]
JOIN [sys].[objects] AS [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] AS [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] AS [si] 
	ON [so].[object_id] = [si].[object_id]
    AND [ss].[name] = [si].[name]
WHERE   [so].[object_id] = OBJECT_ID(N'dbo.FactSales_CCI')
ORDER BY [ss].[user_created] ,
        [ss].[auto_created] ,
        [ss].[has_filter];
GO

/*
	check the stat created automatically
*/
DBCC SHOW_STATISTICS ('dbo.FactSales_CCI', _WA_Sys_00000002_15DA3E5D)
GO


/*
	Rowgroup information for CX_FactSales_CCI
*/
SELECT 
	OBJECT_NAME(rg.object_id) [Table], 
	i.name [Index], 
	rg.partition_number,
	rg.row_group_id, 
	rg.total_rows, 
	rg.size_in_bytes
FROM sys.column_store_row_groups rg
JOIN sys.indexes i 
	ON rg.object_id = i.object_id
	AND rg.index_id = i.index_id
WHERE i.name LIKE 'CX_FactSales_CCI'
ORDER BY  OBJECT_NAME(rg.object_id), i.name, rg.row_group_id;
GO

/*
	Segement information for CX_FactSales_CCI
*/
SELECT 
	(i.object_id) [Table], 
	i.name [Index], 
	i.index_id, 
	i.type, 
	i.type_desc,
	s.column_id, 
	c.name, 
	s.segment_id, 
	s.row_count, 
	s.has_nulls,
	s.min_data_id, 
	s.max_data_id, 
	s.on_disk_size [OnDiskSize_Bytes]
FROM sys.column_store_segments s
JOIN sys.partitions p
	ON s.hobt_id = p.hobt_id
JOIN sys.indexes i
	ON p.object_id = i.object_id
LEFT OUTER JOIN sys.index_columns ic
	ON s.column_id = ic.index_column_id
	AND i.object_id = ic.object_id
	and i.index_id = ic.index_id
LEFT OUTER JOIN sys.columns c
	ON ic.object_id = c.object_id
	AND ic.column_id = c.column_id
WHERE i.name = 'CX_FactSales_CCI';
GO



/*
	Run the same query against all 3 tables, together
*/
SELECT SUM(TotalCost)
FROM [dbo].[FactSales]
WHERE DateKey = '2007-01-01';
GO

SELECT SUM(TotalCost)
FROM [dbo].[FactSales_CCI]
WHERE DateKey = '2007-01-01';
GO

SELECT SUM(TotalCost)
FROM [dbo].[FactSales_CCISorted]
WHERE DateKey = '2007-01-01';
GO


/*
	Rowgroup information for FactSales_CCISorted
*/
SELECT 
	OBJECT_NAME(rg.object_id) [Table], 
	i.name [Index], 
	rg.partition_number,
	rg.row_group_id, 
	rg.total_rows, 
	rg.size_in_bytes
FROM sys.column_store_row_groups rg
JOIN sys.indexes i 
	ON rg.object_id = i.object_id
	AND rg.index_id = i.index_id
WHERE i.name LIKE 'CX_FactSales_CCISorted'
ORDER BY  OBJECT_NAME(rg.object_id), i.name, rg.row_group_id;
GO

/*
	Segement information (all columns) for FactSales_CCISorted
*/
SELECT 
	(i.object_id) [Table], 
	i.name [Index], 
	i.index_id, 
	i.type, 
	i.type_desc,
	s.column_id, 
	c.name, 
	s.segment_id, 
	s.row_count, 
	s.has_nulls,
	s.min_data_id, 
	s.max_data_id, 
	s.on_disk_size [OnDiskSize_Bytes]
FROM sys.column_store_segments s
JOIN sys.partitions p
	ON s.hobt_id = p.hobt_id
JOIN sys.indexes i
	ON p.object_id = i.object_id
LEFT OUTER JOIN sys.index_columns ic
	ON s.column_id = ic.index_column_id
	AND i.object_id = ic.object_id
	and i.index_id = ic.index_id
LEFT OUTER JOIN sys.columns c
	ON ic.object_id = c.object_id
	AND ic.column_id = c.column_id
WHERE i.name = 'CX_FactSales_CCISorted';
GO

/*
	Segement information just for DateKey for 
	FactSales_CCISorted AND CX_FactSales_CCI
*/

SELECT 
	(i.object_id) [Table], 
	i.name [Index], 
	i.index_id, 
	i.type, 
	i.type_desc,
	s.column_id, 
	c.name, 
	s.segment_id, 
	s.row_count, 
	s.has_nulls,
	s.min_data_id, 
	s.max_data_id, 
	s.on_disk_size [OnDiskSize_Bytes]
FROM sys.column_store_segments s
JOIN sys.partitions p
	ON s.hobt_id = p.hobt_id
JOIN sys.indexes i
	ON p.object_id = i.object_id
LEFT OUTER JOIN sys.index_columns ic
	ON s.column_id = ic.index_column_id
	AND i.object_id = ic.object_id
	and i.index_id = ic.index_id
LEFT OUTER JOIN sys.columns c
	ON ic.object_id = c.object_id
	AND ic.column_id = c.column_id
WHERE (i.name = 'CX_FactSales_CCISorted'
OR i.name = 'CX_FactSales_CCI')
AND c.name = 'DateKey';
GO
