/*============================================================================
	File: SQLskills_RingBufferInfo.sql 

	Summary: Parses the output of the sys.dm_os_ring_buffers DMV. 

	Date: May, 5 2015 

	SQL Server Versions:
		2012, 2014
------------------------------------------------------------------------------
	Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
	All rights reserved. 

	For more scripts and sample code, check out
		http://www.sqlskills.com/ 

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit. 

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/ 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 


--System Memory Usage 
SELECT  
    record.value('(/Record/@id)[1]', 'bigint') as [ID], 
    tab.timestamp,
    EventTime, 
    record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type], 
    record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'bigint') as [IndicatorsProcess], 
    record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'bigint') as [IndicatorsSystem],
    record.value('(/Record/ResourceMonitor/NodeId)[1]', 'bigint') as [NodeId],
    record.value('(/Record/MemoryNode/TargetMemory)[1]', 'bigint') as [SQL_TargetMemoryKB],
    record.value('(/Record/MemoryNode/ReservedMemory)[1]', 'bigint') as [SQL_ReservedMemoryKB],
    record.value('(/Record/MemoryNode/AWEMemory)[1]', 'bigint') as [SQL_AWEMemoryKB],
    record.value('(/Record/MemoryNode/PagesMemory)[1]', 'bigint') as [SQL_PagesMemoryKB],
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


-- Get CPU Utilization
SELECT 
    EventTime,
    n.value('(SystemIdle)[1]', 'bigint') AS idle_cpu,
    100-(n.value('(SystemIdle)[1]', 'bigint') +
			n.value('(ProcessUtilization)[1]', 'bigint')) AS nonsql_cpu,
    n.value('(ProcessUtilization)[1]', 'bigint') AS ProcessUtilization,
	n.value('(SystemIdle)[1]', 'bigint') AS SystemIdle,
	n.value('(UserModeTime)[1]', 'bigint') AS UserModeTime,
	n.value('(KernelModeTime)[1]', 'bigint') AS KernelModeTime,
	n.value('(PageFaults)[1]', 'bigint') AS PageFaults,
	n.value('(WorkingSetDelta)[1]', 'bigint') AS WorkingSetDelta,
	n.value('(MemoryUtilization)[1]', 'bigint') AS MemoryUtilization
FROM (
	SELECT
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR') AS t
CROSS APPLY record.nodes('/Record/SchedulerMonitorEvent/SystemHealth') AS x(n)
ORDER BY EventTime DESC;


-- Error Exceptions
SELECT 
	COUNT(*) AS [count],
	'RING_BUFFER_EXCEPTION' AS [Type],
	tab1.[error],
	m.text AS [Error_Message]
FROM (	SELECT RingBuffer.Record.value('Error[1]', 'int') as error
		FROM (SELECT CAST(Record AS XML) AS TargetData 
			  FROM sys.dm_os_ring_buffers
			  WHERE ring_buffer_type = 'RING_BUFFER_EXCEPTION') AS Data
	CROSS APPLY TargetData.nodes('/Record/Exception') AS RingBuffer(Record)) tab1
LEFT JOIN sys.messages m
	ON tab1.[error] = m.message_id 
		AND m.[language_id] = SERVERPROPERTY('LCID')
GROUP BY m.text, tab1.[error];



-- Connectivity Login Timers 
SELECT 
	record.value('(Record/@id)[1]', 'int') as id,
	record.value('(Record/@type)[1]', 'varchar(50)') as type,
	n.value('(RecordType)[1]', 'varchar(50)') as RecordType,
	n.value('(Spid)[1]', 'int') as Spid,
	n.value('(SniConnId)[1]', 'varchar(50)') as SniConnectionid,
	n.value('(ClientConnectionId)[1]', 'varchar(50)') as ClientConnectionId,
	n.value('(SniConsumerError)[1]', 'int') as SniConsumerError,
	n.value('(SniProvider)[1]', 'int') as SniProvider,
	n.value('(State)[1]', 'int') as State,
	n.value('(RemoteHost)[1]', 'varchar(50)') as RemoteHost,
	n.value('(RemotePort)[1]', 'varchar(50)') as RemotePort,
	n.value('(LocalHost)[1]', 'varchar(50)') as LocalHost,
	n.value('(LocalPort)[1]', 'varchar(50)') as LocalPort,
	n.value('(RecordTime)[1]', 'datetime') as RecordTime,
	n.value('(TdsBufInfo/InputBufError)[1]', 'int') as TdsInputBufferError,
	n.value('(TdsBufInfo/OutputBufError)[1]', 'int') as TdsOutputBufferError,
	n.value('(TdsBufInfo/InputBufBytes)[1]', 'int') as TdsInputBufferBytes,
	n.value('(LoginTimersInMilliseconds/TotalTime)[1]', 'bigint') as TotalLoginTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/EnqueueTime)[1]', 'bigint') as LoginTaskEnqueuedInMilliseconds,
	n.value('(LoginTimersInMilliseconds/NetWritesTime)[1]', 'bigint') as NetworkWritesInMilliseconds,
	n.value('(LoginTimersInMilliseconds/NetReadsTime)[1]', 'bigint') as NetworkReadsInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Ssl/TotalTime)[1]', 'bigint') as SslTotalTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Ssl/NetReadsTime)[1]', 'bigint') as SslNetReadsTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Ssl/NetWritesTime)[1]', 'bigint') as SslNetWritesTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Ssl/SecAPITime)[1]', 'bigint') as SslSecAPITimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Ssl/EnqueueTime)[1]', 'bigint') as SslEnqueueTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Sspi/TotalTime)[1]', 'bigint') as SspiTotalTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Sspi/NetReadsTime)[1]', 'bigint') as SspiNetReadsTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Sspi/NetWritesTime)[1]', 'bigint') as SspiNetWritesTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Sspi/SecAPITime)[1]', 'bigint') as SspiSecAPITimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/Sspi/EnqueueTime)[1]', 'bigint') as SspiEnqueueTimeInMilliseconds,
	n.value('(LoginTimersInMilliseconds/TriggerAndResGovTime)[1]', 'bigint') as LoginTriggerAndResourceGovernorProcessingInMilliseconds
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') as tab
CROSS APPLY record.nodes('/Record/ConnectivityTraceRecord[RecordType="LoginTimers"]') AS x(n);


-- Connectivity Errors
SELECT 
	record.value('(Record/@id)[1]', 'int') as id,
	record.value('(Record/@type)[1]', 'varchar(50)') as type,
	n.value('(RecordType)[1]', 'varchar(50)') as RecordType,
	n.value('(RecordSource)[1]', 'varchar(50)') as RecordSource,
	n.value('(Spid)[1]', 'int') as Spid,
	n.value('(SniConnectionId)[1]', 'varchar(50)') as SniConnectionid,
	n.value('(ClientConnectionId)[1]', 'varchar(50)') as ClientConnectionId,
	n.value('(OSError)[1]', 'int') as OSError,
	n.value('(SniConsumerError)[1]', 'int') as SniConsumerError,
	n.value('(SniProvider)[1]', 'int') as SniProvider,
	n.value('(State)[1]', 'int') as State,
	n.value('(RemoteHost)[1]', 'varchar(50)') as RemoteHost,
	n.value('(RemotePort)[1]', 'varchar(50)') as RemotePort,
	n.value('(LocalHost)[1]', 'varchar(50)') as LocalHost,
	n.value('(LocalPort)[1]', 'varchar(50)') as LocalPort,
	n.value('(RecordTime)[1]', 'datetime') as RecordTime,
	n.value('(TdsBuffersInformation/TdsInputBufferError)[1]', 'int') as TdsInputBufferError,
	n.value('(TdsBuffersInformation/TdsOutputBufferError)[1]', 'int') as TdsOutputBufferError,
	n.value('(TdsBuffersInformation/TdsInputBufferBytes)[1]', 'int') as TdsInputBufferBytes,
	n.value('(TdsDisconnectFlags/PhysicalConnectionIsKilled)[1]', 'int') as PhysicalConnectionIsKilled,
	n.value('(TdsDisconnectFlags/DisconnectDueToReadError)[1]', 'int') as DisconnectDueToReadError,
	n.value('(TdsDisconnectFlags/NetworkErrorFoundInInputStream)[1]', 'int') as NetworkErrorFoundInInputStream,
	n.value('(TdsDisconnectFlags/ErrorFoundBeforeLogin)[1]', 'int') as ErrorFoundBeforeLogin,
	n.value('(TdsDisconnectFlags/SessionIsKilled)[1]', 'int') as SessionIsKilled,
	n.value('(TdsDisconnectFlags/NormalDisconnect)[1]', 'int') as NormalDisconnect
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') as tab
CROSS APPLY record.nodes('/Record/ConnectivityTraceRecord[RecordType="Error"]') AS x(n);

-- Connectivity ConnectionClose
SELECT 
	record.value('(Record/@id)[1]', 'int') as id,
	record.value('(Record/@type)[1]', 'varchar(50)') as type,
	n.value('(RecordType)[1]', 'varchar(50)') as RecordType,
	n.value('(RecordSource)[1]', 'varchar(50)') as RecordSource,
	n.value('(Spid)[1]', 'int') as Spid,
	n.value('(SniConnectionId)[1]', 'varchar(50)') as SniConnectionId,
	n.value('(ClientConnectionId)[1]', 'varchar(50)') as ClientConnectionId,
	n.value('(SniProvider)[1]', 'int') as SniProvider,
	n.value('(RemoteHost)[1]', 'varchar(50)') as RemoteHost,
	n.value('(RemotePort)[1]', 'varchar(50)') as RemotePort,
	n.value('(LocalHost)[1]', 'varchar(50)') as LocalHost,
	n.value('(LocalPort)[1]', 'varchar(50)') as LocalPort,
	n.value('(RecordTime)[1]', 'datetime') as RecordTime,
	n.value('(TdsBuffersInformation/TdsInputBufferError)[1]', 'int') as TdsInputBufferError,
	n.value('(TdsBuffersInformation/TdsOutputBufferError)[1]', 'int') as TdsOutputBufferError,
	n.value('(TdsBuffersInformation/TdsInputBufferBytes)[1]', 'int') as TdsInputBufferBytes,
	n.value('(TdsDisconnectFlags/PhysicalConnectionIsKilled)[1]', 'int') as PhysicalConnectionIsKilled,
	n.value('(TdsDisconnectFlags/DisconnectDueToReadError)[1]', 'int') as DisconnectDueToReadError,
	n.value('(TdsDisconnectFlags/NetworkErrorFoundInInputStream)[1]', 'int') as NetworkErrorFoundInInputStream,
	n.value('(TdsDisconnectFlags/ErrorFoundBeforeLogin)[1]', 'int') as ErrorFoundBeforeLogin,
	n.value('(TdsDisconnectFlags/SessionIsKilled)[1]', 'int') as SessionIsKilled,
	n.value('(TdsDisconnectFlags/NormalDisconnect)[1]', 'int') as NormalDisconnect,
	n.value('(TdsDisconnectFlags/NormalLogout)[1]', 'int') as NormalLogout
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') as tab
CROSS APPLY record.nodes('/Record/ConnectivityTraceRecord[RecordType="ConnectionClose"]') AS x(n);




-- Get Memory Broker Utilization
SELECT 
    EventTime,
    n.value('(Pool)[1]', 'int') AS [Pool],
    n.value('(Broker)[1]', 'varchar(40)') AS [Broker],
    n.value('(Notification)[1]', 'varchar(40)') AS [Notification],
    n.value('(MemoryRatio)[1]', 'bigint') AS [MemoryRatio], 
    n.value('(NewTarget)[1]', 'bigint') AS [NewTarget],
    n.value('(Overall)[1]', 'bigint') AS [Overall],
    n.value('(Rate)[1]', 'bigint') AS [Rate],
    n.value('(CurrentlyPredicted)[1]', 'bigint') AS [CurrentlyPredicted],
    n.value('(CurrentlyAllocated)[1]', 'bigint') AS [CurrentlyAllocated],
	n.value('(PreviouslyAllocated)[1]', 'bigint') AS [PreviouslyAllocated]
FROM (
	SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER') AS t
CROSS APPLY record.nodes('/Record/MemoryBroker') AS x(n)
ORDER BY EventTime DESC;


-- Out of Memory Notifications
SELECT 
	EventTime,
	n.value('(OOM/Action)[1]', 'varchar(50)') as Action,
	n.value('(OOM/Resources)[1]', 'int') as Resources,
	n.value('(OOM/Task)[1]', 'varchar(20)') as Task,
	n.value('(OOM/Pool)[1]', 'int') as PoolID,
	n.value('(MemoryRecord/MemoryUtilization)[1]', 'bigint') as MemoryUtilization,
	n.value('(MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') as AvailablePhysicalMemory,
	n.value('(MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') as AvailableVirtualAddressSpace
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_OOM') as tab
CROSS APPLY record.nodes('/Record') AS x(n);


-- Memory Broker Clerks
SELECT 
	EventTime,
	n.value('(Name)[1]', 'varchar(50)') as Name,
	n.value('(TotalPages)[1]', 'bigint') as TotalPages,
	n.value('(SimulatedPages)[1]', 'bigint') as SimulatedPages,
	n.value('(SimulationBenefit)[1]', 'decimal(12,10)') as SimulationBenefit,
	n.value('(InternalBenefit)[1]', 'decimal(12,10)') as InternalBenefit,
	n.value('(ExternalBenefit)[1]', 'decimal(12,10)') as ExternalBenefit,
	n.value('(ValueOfMemory)[1]', 'decimal(12,10)') as ValueOfMemory,
	n.value('(PeriodicFreedPages)[1]', 'bigint') as PeriodicFreedPages,
	n.value('(InternalFreedPages)[1]', 'bigint') as InternalFreedPages
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER_CLERKS') as tab
CROSS APPLY record.nodes('/Record/MemoryBrokerClerk') AS x(n);


-- Event Session memory buffer usage
SELECT 
	EventTime,
	xes.name,
	n.value('(@id)[1]', 'int') as Id,
	n.value('xs:hexBinary((@address)[1])', 'varbinary(max)') as bufferaddress,
	n.value('xs:hexBinary((SessionHandle)[1])', 'varbinary(max)') as SessionHandle,
	n.value('xs:hexBinary((BufferMgr)[1])', 'varbinary(max)') as BufferMgr,
	n.value('(OldState)[1]', 'varchar(50)') as OldState,
	n.value('(NewState)[1]', 'varchar(50)') as NewState
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_XE_BUFFER_STATE') as tab
CROSS APPLY record.nodes('/Record/XE_BufferStateRecord') AS x(n)
INNER JOIN sys.dm_xe_sessions AS xes
ON xes.address = n.value('xs:hexBinary((SessionHandle)[1])', 'varbinary(max)')
ORDER BY EventTime, name, Id
