SELECT  [database_id],
        DB_NAME([database_id]) AS [database_nm],
        [file_id],
        [num_of_reads],
        [num_of_bytes_read],
        [io_stall_read_ms],
        [num_of_writes],
        [num_of_bytes_written],
        [io_stall_write_ms],
        [io_stall],
        [size_on_disk_bytes]
FROM    sys.[dm_io_virtual_file_stats](NULL, NULL)
ORDER BY [io_stall] DESC;
GO