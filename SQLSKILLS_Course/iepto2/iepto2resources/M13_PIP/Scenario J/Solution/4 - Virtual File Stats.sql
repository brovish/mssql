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

select DB_NAME(database_id) database_name, file_id
	,io_stall_read_ms
	,num_of_reads
	,cast(io_stall_read_ms/(1.0+num_of_reads) as numeric(10,1)) as 'avg_read_stall_ms'
	,io_stall_write_ms
	,num_of_writes
	,cast(io_stall_write_ms/(1.0+num_of_writes) as numeric(10,1)) as 'avg_write_stall_ms'
	,io_stall_read_ms + io_stall_write_ms as io_stalls
	,num_of_reads + num_of_writes as total_io
	,cast((io_stall_read_ms+io_stall_write_ms)/(1.0+num_of_reads + num_of_writes) as numeric(10,1)) as 'avg_io_stall_ms'
from sys.dm_io_virtual_file_stats(null,null)
order by avg_io_stall_ms desc

USE Credit2;
GO

EXEC sp_helpfile 
GO
