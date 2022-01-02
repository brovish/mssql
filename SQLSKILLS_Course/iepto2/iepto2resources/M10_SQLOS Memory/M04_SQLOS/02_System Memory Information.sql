/*****************************************************************************
*   Presentation: Module 11 - DMV's
*   FileName:  System Memory Information.sql
*
*   Summary: Demonstrates how to find information about memory availability
*			 and utilization in SQL.
*
*   Date: March 14, 2011 
*
*   SQL Server Versions:
*         2008, 2008 R2
*         
******************************************************************************
*   Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlskills.com/blogs/jonathan
*
*   You may alter this code for your own *non-commercial* purposes. You may
*   republish altered code as long as you include this copyright and give 
*	due credit. 
*
*
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
*   PARTICULAR PURPOSE. 
*
******************************************************************************/



-- System Memory
SELECT 
	total_physical_memory_kb, 
	available_physical_memory_kb,
	total_page_file_kb, 
	available_page_file_kb,
	system_memory_state_desc
FROM sys.dm_os_sys_memory;
GO

-- Process Memory
SELECT 
	physical_memory_in_use_kb,
	locked_page_allocations_kb,
	page_fault_count, 
	memory_utilization_percentage,
	available_commit_limit_kb, 
	process_physical_memory_low,
	process_virtual_memory_low
FROM sys.dm_os_process_memory;
GO

-- Performance Counters
SELECT *,
	cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = N'SQLServer:Buffer Manager';
GO

-- Memory Nodes (all memory in SMP, or per node in NUMA)
SELECT * 
FROM sys.dm_os_memory_nodes;
GO

-- Track Cross Node memory access stats (Requires TF 842)
DBCC TRACEON(842, -1);
GO
SELECT * 
FROM sys.dm_os_memory_node_access_stats;
GO
DBCC TRACEOFF(842, -1);
GO

-- Memory heaps used by components
SELECT 
	memory_node_id, 
	type, 
	pages_allocated_count, 
	page_size_in_bytes, 
	max_pages_allocated_count
FROM sys.dm_os_memory_objects;
GO

-- Memory allocations from objects
-- Requires TF 3654 to view data
DBCC TRACEON(3654, -1);
GO
SELECT mo.type, ma.creation_time, ma.size_in_bytes
FROM sys.dm_os_memory_allocations AS ma
JOIN sys.dm_os_memory_objects AS mo
	ON mo.memory_object_address = ma.memory_object_address;
GO
	
-- Memory Pool Information
SELECT 
	pool_id,
	type,
	name,
	max_free_entries_count,
	free_entries_count,
	removed_in_all_rounds_count
FROM sys.dm_os_memory_pools;
GO

-- Cache clock hands and last sweep info.
SELECT DISTINCT
	ch.clock_hand,
	ch.clock_status,
	cc.name,  
	cc.type, 
	cc.single_pages_kb + cc.multi_pages_kb as total_kb,  
	cc.single_pages_in_use_kb + cc.multi_pages_in_use_kb 
	as total_in_use_kb,  
	cc.entries_count,  
	cc.entries_in_use_count,
	ch.rounds_count,
	ch.removed_all_rounds_count, 
	DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [round_start_time])/1000), GETDATE()) AS last_round_time, 
	ch.removed_last_round_count
FROM sys.dm_os_memory_cache_counters AS cc  
JOIN sys.dm_os_memory_cache_clock_hands AS ch 
	ON cc.cache_address =ch.cache_address
CROSS JOIN sys.dm_os_sys_info
WHERE ch.removed_all_rounds_count > 0 
ORDER BY 
	DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [round_start_time])/1000), GETDATE()) DESC;
GO

-- Cache Entries
SELECT 
	pool_id,
	name, 
	type, 
	pages_allocated_count,
	in_use_count, 
	is_dirty, 
	original_cost, 
	current_cost, 
	entry_data
FROM sys.dm_os_memory_cache_entries
WHERE pages_allocated_count > 0;
GO