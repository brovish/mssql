-- Demo Trace Flag 1222 output from ErrorLog
EXECUTE xp_readerrorlog;

USE [msdb];
GO
-- Process the Event Notification Queue
DECLARE @deadlock XML;

-- Handle one message at a time		
RECEIVE TOP(1) 
	@deadlock = CAST([message_body] AS XML).query('/EVENT_INSTANCE/TextData/*')
FROM [DeadlockGraphQueue];
	
SELECT @deadlock;

-- Retrieve from Extended Events
SELECT 
    CAST(XEvent.value('(data[@name="xml_report"]/value)[1]', 'varchar(max)') AS XML)AS XEvent
FROM    (SELECT CAST([target_data] AS XML) AS TargetData
         FROM sys.dm_xe_session_targets AS st
         INNER JOIN sys.dm_xe_sessions AS s 
            ON [s].[address] = [st].[event_session_address]
         WHERE [s].[name] = N'system_health'
           AND [st].[target_name] = N'ring_buffer') AS Data
CROSS APPLY TargetData.nodes ('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData (XEvent);