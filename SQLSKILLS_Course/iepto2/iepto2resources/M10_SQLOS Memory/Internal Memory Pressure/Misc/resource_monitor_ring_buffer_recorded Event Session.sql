--IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='Test')
--    DROP EVENT SESSION [Test] ON SERVER;
--CREATE EVENT SESSION [Test]
--ON SERVER
--ADD EVENT sqlos.resource_monitor_ring_buffer_recorded
--( ACTION (package0.callstack, package0.collect_system_time, package0.collect_cpu_cycle_time
--ADD TARGET package0.ring_buffer
--WITH (MAX_MEMORY = 4096KB, EVENT_RETENTION_MODE = NO_EVENT_LOSS, MAX_DISPATCH_LATENCY = 1 SECONDS, MAX_EVENT_SIZE = 4096KB, MEMORY_PARTITION_MODE = NONE, TRACK_CAUSALITY = ON, STARTUP_STATE = OFF)

--ALTER EVENT SESSION [Test] ON SERVER
--STATE = START;

--DBCC TRACEON (3656, -1)  



select * from sys.dm_xe_objects where object_type = 'action'
--SELECT CAST(target_data AS XML) 
--FROM sys.dm_xe_sessions AS s
--INNER JOIN sys.dm_xe_session_targets AS st 
--	ON s.address = st.event_session_address
--WHERE s.name = N'Test'
--  AND st.target_name = N'ring_buffer'


SELECT 
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    DATEADD(hh, 
        DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
        event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],
    event_data.value('(event/data[@name="id"]/value)[1]', 'int') AS [id], 
    event_data.value('(event/data[@name="timestamp"]/value)[1]', 'bigint') AS [data_timestamp],
    event_data.value('(event/data[@name="delta_time"]/value)[1]', 'int') AS [delta_time],
    event_data.value('(event/data[@name="memory_ratio"]/value)[1]', 'bigint') AS [memory_ratio],
    event_data.value('(event/data[@name="new_target"]/value)[1]', 'bigint') AS [new_target],
    event_data.value('(event/data[@name="overall"]/value)[1]', 'bigint') AS [overall],
    event_data.value('(event/data[@name="writes"]/value)[1]', 'bigint') AS [writes],
    event_data.value('(event/data[@name="rate"]/text)[1]', 'bigint') AS [rate],
    event_data.value('(event/data[@name="currently_predicated"]/value)[1]', 'bigint') AS [currently_predicated],
    event_data.value('(event/data[@name="currently_allocated"]/value)[1]', 'bigint') AS [currently_allocated],
    event_data.value('(event/data[@name="previously_allocated"]/value)[1]', 'bigint') AS [previously_allocated],
    event_data.value('(event/data[@name="broker"]/value)[1]', 'nvarchar(50)') AS [broker],
    ISNULL(NULLIF(event_data.value('(event/data[@name="notification"]/text)[1]', 'nvarchar(50)'),''),
			event_data.value('(event/data[@name="notification"]/value)[1]', 'nvarchar(50)')) AS [notification],

 event_data.value('(event/action[@name="callstack"]/value)[1]', 'nvarchar(4000)') AS [callstack],
 event_data.value('(event/data[@name="id"]/value)[1]', 'int') AS [id],
 event_data.value('(event/data[@name="timestamp"]/value)[1]', 'bigint') AS [timestamp],
 event_data.value('(event/data[@name="delta_time"]/value)[1]', 'int') AS [delta_time],
 event_data.value('(event/data[@name="memory_ratio"]/value)[1]', 'bigint') AS [memory_ratio],
 event_data.value('(event/data[@name="new_target"]/value)[1]', 'bigint') AS [new_target],
 event_data.value('(event/data[@name="overall"]/value)[1]', 'bigint') AS [overall],
 event_data.value('(event/data[@name="rate"]/value)[1]', 'bigint') AS [rate],
 event_data.value('(event/data[@name="currently_predicated"]/value)[1]', 'bigint') AS [currently_predicated],
 event_data.value('(event/data[@name="currently_allocated"]/value)[1]', 'bigint') AS [currently_allocated],
 event_data.value('(event/data[@name="previously_allocated"]/value)[1]', 'bigint') AS [previously_allocated],
 event_data.value('(event/data[@name="broker"]/value)[1]', 'nvarchar(4000)') AS [broker],
 event_data.value('(event/data[@name="notification"]/value)[1]', 'nvarchar(4000)') AS [notification],
 event_data.value('(event/data[@name="call_stack"]/value)[1]', 'nvarchar(4000)') AS [call_stack],
 event_data.value('(event/data[@name="opcode"]/text)[1]', 'nvarchar(4000)') AS [opcode],
 event_data.value('(event/data[@name="working_set"]/value)[1]', 'bigint') AS [working_set],
 event_data.value('(event/data[@name="commited"]/value)[1]', 'bigint') AS [commited],
 event_data.value('(event/data[@name="utilization"]/value)[1]', 'int') AS [utilization],
 event_data.value('(event/data[@name="effect"]/text)[1]', 'nvarchar(4000)') AS [effect],
 event_data.value('(event/data[@name="effect_duration"]/value)[1]', 'int') AS [effect_duration],
 event_data.value('(event/data[@name="effect_state"]/value)[1]', 'int') AS [effect_state],
 event_data.value('(event/data[@name="effect_reversed_indicator"]/value)[1]', 'nvarchar(4000)') AS [effect_reversed_indicator],
 event_data.value('(event/data[@name="memory_utilization_pct"]/value)[1]', 'int') AS [memory_utilization_pct],
 event_data.value('(event/data[@name="total_physical_memory_kb"]/value)[1]', 'bigint') AS [total_physical_memory_kb],
 event_data.value('(event/data[@name="available_physical_memory_kb"]/value)[1]', 'bigint') AS [available_physical_memory_kb],
 event_data.value('(event/data[@name="total_page_file_kb"]/value)[1]', 'bigint') AS [total_page_file_kb],
 event_data.value('(event/data[@name="available_page_file_kb"]/value)[1]', 'bigint') AS [available_page_file_kb],
 event_data.value('(event/data[@name="total_virtual_address_space_kb"]/value)[1]', 'bigint') AS [total_virtual_address_space_kb],
 event_data.value('(event/data[@name="available_virtual_address_space_kb"]/value)[1]', 'bigint') AS [available_virtual_address_space_kb],
 event_data.value('(event/data[@name="available_extended_virtual_address_space_kb"]/value)[1]', 'bigint') AS [available_extended_virtual_address_space_kb],
 event_data.value('(event/data[@name="memory_node_id"]/value)[1]', 'int') AS [memory_node_id],
 event_data.value('(event/data[@name="reserved_kb"]/value)[1]', 'bigint') AS [reserved_kb],
 event_data.value('(event/data[@name="committed_kb"]/value)[1]', 'bigint') AS [committed_kb],
 event_data.value('(event/data[@name="shared_committed_kb"]/value)[1]', 'bigint') AS [shared_committed_kb],
 event_data.value('(event/data[@name="awe_kb"]/value)[1]', 'bigint') AS [awe_kb],
 event_data.value('(event/data[@name="single_pages_kb"]/value)[1]', 'bigint') AS [single_pages_kb],
 event_data.value('(event/data[@name="multiple_pages_kb"]/value)[1]', 'bigint') AS [multiple_pages_kb],
 event_data.value('(event/data[@name="process_indicators"]/value)[1]', 'int') AS [process_indicators],
 event_data.value('(event/data[@name="system_indicators"]/value)[1]', 'int') AS [system_indicators],
 event_data.value('(event/data[@name="node_id"]/value)[1]', 'int') AS [node_id],
 event_data.value('(event/data[@name="apply_low_pm"]/text)[1]', 'nvarchar(4000)') AS [apply_low_pm],
 event_data.value('(event/data[@name="apply_high_pm"]/text)[1]', 'nvarchar(4000)') AS [apply_high_pm],
 event_data.value('(event/data[@name="revert_high_pm"]/text)[1]', 'nvarchar(4000)') AS [revert_high_pm],

    event_data.query('(event/action[@name="callstack"]/value)[1]') AS [call_stack],
	event_data,
    CAST(SUBSTRING(event_data.value('(event/action[@name="attach_activity_id"]/value)[1]', 'varchar(50)'), 1, 36) AS uniqueidentifier) as activity_id,
    CAST(SUBSTRING(event_data.value('(event/action[@name="attach_activity_id"]/value)[1]', 'varchar(50)'), 38, 10) AS int) as event_sequence
FROM 
(   SELECT XEvent.query('.') AS event_data 
    FROM 
    (    -- Cast the target_data to XML 
        SELECT CAST(target_data AS XML) AS TargetData 
        FROM sys.dm_xe_session_targets AS st 
        INNER JOIN sys.dm_xe_sessions AS s 
            ON s.address = st.event_session_address 
        WHERE name = N'Test' 
          AND target_name = N'ring_buffer'
    ) AS Data 
    -- Split out the Event Nodes 
    CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)   
) AS tab (event_data)
ORDER BY activity_id, event_sequence