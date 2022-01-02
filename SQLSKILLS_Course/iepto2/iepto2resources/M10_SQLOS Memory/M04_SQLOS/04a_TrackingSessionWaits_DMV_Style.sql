
CREATE EVENT SESSION [TrackResourceWaits] ON SERVER 
ADD EVENT  sqlos.wait_info
(    -- Capture the database_id, session_id, plan_handle, and sql_text
    ACTION(sqlserver.database_id,sqlserver.session_id,sqlserver.sql_text,sqlserver.plan_handle,
		  sqlos.task_address, sqlos.worker_address, sqlos.scheduler_id
		)
    WHERE
        (opcode = 1 --End Events Only
            AND (wait_type = 187) -- CXPACKET waits
		)            
)
ADD TARGET package0.ring_buffer(SET max_memory=4096)
WITH (EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
      MAX_DISPATCH_LATENCY=5 SECONDS)
GO

ALTER EVENT SESSION [TrackResourceWaits] ON SERVER 
STATE=START

-- Start DMV based waiting task tracking


-- Run the workload and 

USE AdventureWorks2008R2
GO
SELECT * FROM Sales.SalesOrderDetail sod INNER JOIN Production.Product p ON sod.ProductID = p.ProductID ORDER BY Style

-- Wait for dispatch of events to complete
WAITFOR DELAY '00:00:05'

ALTER EVENT SESSION [TrackResourceWaits] ON SERVER 
DROP EVENT  sqlos.wait_info

-- Extract the Event information from the Event Session 
SELECT 
    DATEADD(hh, 
        DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
        event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],
    event_data.value('(event/action[@name="session_id"]/value)[1]', 'int') AS [session_id],
    event_data.value('(event/data[@name="wait_type"]/text)[1]', 'nvarchar(4000)') AS [wait_type],
    event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') AS [duration],
    event_data.value('(event/action[@name="worker_address"]/value)[1]', 'nvarchar(4000)') AS [worker_address],
    event_data.value('(event/action[@name="scheduler_id"]/value)[1]', 'nvarchar(4000)') AS [scheduler_id],
    event_data.value('(event/action[@name="plan_handle"]/value)[1]', 'nvarchar(4000)') AS [plan_handle],
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(4000)') AS [sql_text]
FROM 
(    SELECT XEvent.query('.') AS event_data 
    FROM 
    (    -- Cast the target_data to XML 
        SELECT CAST(target_data AS XML) AS TargetData 
        FROM sys.dm_xe_session_targets st 
        JOIN sys.dm_xe_sessions s 
            ON s.address = st.event_session_address 
        WHERE name = 'TrackResourceWaits' 
          AND target_name = 'ring_buffer'
    ) AS Data 
    -- Split out the Event Nodes 
    CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)   
) AS tab (event_data)
ORDER BY worker_address