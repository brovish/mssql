----------------------------------------------------------------------
-- Summarize segment structure for clustered columnstore indexes
-- Dr Greg Low v1.0
-- March 2015

USE Compression;
GO
 
WITH ClusteredColumnstoreIndexes
AS
( SELECT t.object_id AS ObjectID,
         SCHEMA_NAME(t.schema_id) AS SchemaName,
         t.name AS TableName,
         i.name AS IndexName
  FROM sys.indexes AS i
  INNER JOIN sys.tables AS t
  ON i.object_id = t.object_id
  WHERE i.type = 5
),
RowGroups
AS
( SELECT csrg.object_id AS ObjectID,
         csrg.partition_number AS PartitionNumber,
         csrg.total_rows AS TotalRows,
         csrg.deleted_rows AS DeletedRows,
         csrg.deleted_rows * 100.0 / csrg.total_rows AS DeletedPercentage,
         CASE WHEN csrg.total_rows = csrg.deleted_rows
              THEN 1 ELSE 0
         END AS IsEmptySegment
  FROM sys.column_store_row_groups AS csrg
  WHERE csrg.state = 3 -- Compressed (Ignoring: 0 - Hidden, 1 - Open, 2 - Closed, 4 - Tombstone)
),
IndexStats
AS
( SELECT cci.SchemaName,
         cci.TableName,
         cci.IndexName,
         rg.PartitionNumber,
         SUM(CAST(rg.TotalRows AS decimal(18,0))) AS TotalRows,
         SUM(CAST(rg.DeletedRows AS decimal(18,0))) AS DeletedRows,
         SUM(CAST(rg.DeletedRows AS decimal(18,0))) * 100.0
           / SUM(CAST(rg.TotalRows AS decimal(18,0)))
           AS DeletedPercentage,
         SUM(rg.IsEmptySegment) aS EmptySegments,
         COUNT(rg.TotalRows) AS TotalSegments,
         AVG(rg.TotalRows) AS AverageTotalRowsPerSegment,
         AVG(rg.TotalRows - rg.DeletedRows) AS AverageActiveRowsPerSegment
  FROM ClusteredColumnstoreIndexes AS cci
  INNER JOIN RowGroups AS rg
  ON cci.ObjectID = rg.ObjectID
  GROUP BY cci.ObjectID, cci.SchemaName, cci.TableName, cci.IndexName, rg.PartitionNumber
)
SELECT * FROM IndexStats;
GO

USE tempdb;
GO
