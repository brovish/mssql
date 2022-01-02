USE tempdb;
GO

SELECT  SUM([dm_db_file_space_usage].[user_object_reserved_page_count]) * 8 AS [user_object_reserved_kb],
        SUM([dm_db_file_space_usage].[internal_object_reserved_page_count]) * 8 AS [internal_object_reserved_kb],
        SUM([dm_db_file_space_usage].[version_store_reserved_page_count]) * 8 AS [version_store_kb]
FROM    [sys].[dm_db_file_space_usage];
GO
