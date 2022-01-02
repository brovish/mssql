/***************************************************************************** 
* 
*   Summary: Demonstrates how to parse the contents of sys.dm_os_ring_buffers for 
*                    Low memory notifications by the OS. 
*         
*   Date: June 4, 2012 
* 
*   SQL Server Versions: 
*         2008, 2008 R2, 2012 
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
*    due credit. 
* 
* 
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A 
*   PARTICULAR PURPOSE. 
* 
******************************************************************************/ 

-- Get SQLServer:Memory Manager performance counters
SELECT 
	CURRENT_TIMESTAMP AS [CollectTime],
	[Connection Memory (KB)],
	[Granted Workspace Memory (KB)],
	[Lock Memory (KB)],
	[Maximum Workspace Memory (KB)],
	[Memory Grants Outstanding],
	[Memory Grants Pending],
	[Optimizer Memory (KB)],
	[SQL Cache Memory (KB)],
	[Target Server Memory (KB)],
	[Total Server Memory (KB)]
FROM (	
		SELECT RTRIM(LTRIM(counter_name)) AS counter_name, cntr_value
		FROM sys.dm_os_performance_counters
		WHERE object_name = 'SQLServer:Memory Manager'
) AS tab
PIVOT
(	MAX(cntr_value)
	FOR counter_name IN (	[Connection Memory (KB)],
							[Granted Workspace Memory (KB)],
							[Lock Memory (KB)],
							[Maximum Workspace Memory (KB)],
							[Memory Grants Outstanding],
							[Memory Grants Pending],
							[Optimizer Memory (KB)],
							[SQL Cache Memory (KB)],
							[Target Server Memory (KB)],
							[Total Server Memory (KB)])
) as pvt


-- Get SQLServer:Buffer Node performance counters
SELECT 
	CURRENT_TIMESTAMP AS [CollectTime],
	[node_id], 
	[Free pages],
	[Total pages],
	[Foreign pages],
	[Database pages],
	[Stolen pages],
	[Target pages],
	[Page life expectancy]
FROM (
		SELECT RTRIM(LTRIM(counter_name)) AS counter_name, CAST(instance_name AS INT) AS node_id, cntr_value
		FROM sys.dm_os_performance_counters
		WHERE object_name = 'SQLServer:Buffer Node'
) AS tab
PIVOT
(	MAX(cntr_value)
	FOR counter_name IN (	[Free pages],
							[Total pages],
							[Foreign pages],
							[Database pages],
							[Stolen pages],
							[Target pages],
							[Page life expectancy])
) AS pvt


--System Memory Usage 
SELECT  
    record.value('(/Record/@id)[1]', 'int') as [ID], 
    tab.timestamp,
    EventTime, 
    record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type], 
    record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') as [IndicatorsProcess], 
    record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') as [IndicatorsSystem],
    record.value('(/Record/ResourceMonitor/NodeId)[1]', 'int') as [NodeId],
    record.value('(/Record/MemoryNode/CommittedMemory)[1]', 'bigint') as [SQL_CommittedMemoryKB],
    record.value('(/Record/MemoryNode/SinglePagesMemory)[1]', 'bigint') as [SinglePagesMemory],
    record.value('(/Record/MemoryNode/MultiplePagesMemory)[1]', 'bigint') as [MultiplePagesMemory],
    record.value('(/Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilization%], 
    record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [AvailablePhysicalMemoryKB], 
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"]/@state)[1]', 'nvarchar(50)') as [APPLY_LOWPM_State],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"]/@reversed)[1]', 'bit') as [APPLY_LOWPM_Reversed],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"])[1]', 'bigint') as [APPLY_LOWPM_Time],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"]/@state)[1]', 'nvarchar(50)') as [APPLY_HIGHPM_State],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"]/@reversed)[1]', 'bit') as [APPLY_HIGHPM_Reversed],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"])[1]', 'bigint') as [APPLY_HIGHPM_Time],
    record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"]/@state)[1]', 'nvarchar(50)') as [REVERT_HIGHPM_State],
    record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"]/@reversed)[1]', 'bit') as [REVERT_HIGHPM_Reversed],
    record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"])[1]', 'bigint') as [REVERT_HIGHPM_Time],
    record.value('(/Record/MemoryNode/ReservedMemory)[1]', 'bigint') as [SQL_ReservedMemoryKB],
    record.value('(/Record/MemoryNode/SharedMemory)[1]', 'bigint') as [SQL_SharedMemoryKB],
    record.value('(/Record/MemoryNode/AWEMemory)[1]', 'bigint') as [SQL_AWEMemoryKB],    
    record.value('(/Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS [TotalPhysicalMemoryKB],
    record.value('(/Record/MemoryRecord/TotalPageFile)[1]', 'bigint') AS [TotalPageFileKB], 
    record.value('(/Record/MemoryRecord/AvailablePageFile)[1]', 'bigint') AS [AvailablePageFileKB],
    record.value('(/Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS [TotalVirtualAddressSpaceKB], 
    record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [AvailableVirtualAddressSpaceKB],
    record.value('(/Record/MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]', 'bigint') AS [AvailableExtendedVirtualAddressSpaceKB]
FROM ( 
    SELECT 
		[timestamp],
        DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
        CONVERT (xml, record) AS record 
    FROM sys.dm_os_ring_buffers 
    CROSS JOIN sys.dm_os_sys_info 
    WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab 
ORDER BY ID DESC;

-- Get Memory Broker notifications
SELECT 
    EventTime,
    n.value('(Pool)[1]', 'int') AS [Pool],
    n.value('(Broker)[1]', 'varchar(40)') AS [Broker],
    n.value('(Notification)[1]', 'varchar(40)') AS [Notification],
    n.value('(MemoryRatio)[1]', 'int') AS [MemoryRatio], 
    n.value('(NewTarget)[1]', 'int') AS [NewTarget],
    n.value('(Overall)[1]', 'int') AS [Overall],
    n.value('(Rate)[1]', 'int') AS [Rate],
    n.value('(CurrentlyPredicted)[1]', 'int') AS [CurrentlyPredicted],
    n.value('(CurrentlyAllocated)[1]', 'int') AS [CurrentlyAllocated]
FROM (
	SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER') AS t
CROSS APPLY record.nodes('/Record/MemoryBroker') AS x(n)
ORDER BY EventTime DESC;
--</Record>