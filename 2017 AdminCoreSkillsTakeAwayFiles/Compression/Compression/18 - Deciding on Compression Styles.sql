USE AdventureWorks;
GO

DECLARE @ScanCutoff int = 70;
DECLARE @UpdateCutoff int = 15;

WITH PartitionStatistics
AS
(
    SELECT t.name AS TableName,
           i.name AS IndexName,
           i.index_id AS IndexID,
           ios.partition_number AS PartitionNumber,
           FLOOR(ios.leaf_update_count * 100.0 /
                 ( ios.range_scan_count + ios.leaf_insert_count
                   + ios.leaf_delete_count + ios.leaf_update_count
                   + ios.leaf_page_merge_count + ios.singleton_lookup_count
                 )) AS UpdatePercentage,
           FLOOR(ios.range_scan_count * 100.0 /
                 ( ios.range_scan_count + ios.leaf_insert_count
                   + ios.leaf_delete_count + ios.leaf_update_count
                   + ios.leaf_page_merge_count + ios.singleton_lookup_count
                 )) AS ScanPercentage
    FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ios
    INNER JOIN sys.objects AS o
    ON o.object_id = ios.object_id
    INNER JOIN sys.tables AS t
    ON t.object_id = o.object_id
    INNER JOIN sys.indexes AS i
    ON i.object_id = o.object_id
    AND i.index_id = ios.index_id
    WHERE ( ios.range_scan_count + ios.leaf_insert_count
            + ios.leaf_delete_count + leaf_update_count
            + ios.leaf_page_merge_count + ios.singleton_lookup_count) <> 0
    AND t.is_ms_shipped = 0
)
SELECT TableName, IndexName, IndexID, PartitionNumber, 
       UpdatePercentage, ScanPercentage,
       CASE WHEN UpdatePercentage <= @UpdateCutoff
            AND ScanPercentage >= @ScanCutoff
            THEN 'PAGE'
            ELSE 'ROW'
       END AS Recommendation
FROM PartitionStatistics
ORDER BY TableName, IndexName, PartitionNumber;
GO

-- Keep in mind DMV based data only -> not persisted
-- Are INSERTs actually UPDATEs ?

USE tempdb;
GO
