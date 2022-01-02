/*============================================================================
  File:     3b_tsql_stack_research.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Jonathan Kehayias, SQLskills.com
	Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/
/*
	Note for this demo if you're running SQL 2019:
		compat mode needs to be < 150 OR 
		if compat mode = 150, disable TSQL_SCALAR_UDF_INLINING

		USE [master]
		GO
		ALTER DATABASE [AdventureWorks2019] SET COMPATIBILITY_LEVEL = 150
		GO

		USE [AdventureWorks2019]
		GO
		ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF
		GO
*/
USE [AdventureWorks2019];
GO

/*
	First get the object_id of the function
	*add in event session definition
*/
SELECT OBJECT_ID(N'ReturnsTrue');
GO

/*
	If the event session exists drop it
*/
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = 'tsql_stack')
	DROP EVENT SESSION [tsql_stack] ON SERVER;
GO

/*
	Create the Event Session 
	known as sp_starting in trace
	(fires for function, trigger, and SP starting execution)
*/
CREATE EVENT SESSION [tsql_stack] 
	ON SERVER 
ADD EVENT sqlserver.module_start(
		ACTION(
			sqlserver.tsql_stack
			)
    WHERE (
		object_id = 1655676946
		)
	) 
ADD TARGET package0.ring_buffer;
GO

/*
	Start the event session
*/
ALTER EVENT SESSION [tsql_stack]
	ON SERVER
	STATE=START;
GO

/*
	Open live data viewer
	Execute the test procedure
*/
EXECUTE dbo.CalledFirst;
GO



/*
	Check live data first...

	Extract the Event information from the Event Session
*/
SELECT 
	ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
	XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS [tsql_stack]
FROM 
(    -- Cast the target_data to XML 
    SELECT CAST(target_data AS XML) AS TargetData 
    FROM sys.dm_xe_session_targets st 
    JOIN sys.dm_xe_sessions s 
        ON s.address = st.event_session_address 
    WHERE name = N'tsql_stack' 
        AND target_name = N'ring_buffer'
) AS Data 
-- Split out the Event Nodes 
CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent);

/*
	Let's break down the tsql_stack
*/
SELECT 
	event_id,
	frame.value('(@level)[1]', 'int') AS [level],
	frame.value('xs:hexBinary(substring((@handle)[1], 3))', 'varbinary(max)') AS [handle],
	frame.value('(@line)[1]', 'int') AS [line],
	frame.value('(@offsetStart)[1]', 'int') AS [offset_start],
	frame.value('(@offsetEnd)[1]', 'int') AS [offset_end]
FROM
(
	SELECT 
		ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
		XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS [tsql_stack]
	FROM 
	(    -- Cast the target_data to XML 
		SELECT CAST(target_data AS XML) AS TargetData 
		FROM sys.dm_xe_session_targets st 
		JOIN sys.dm_xe_sessions s 
			ON s.address = st.event_session_address 
		WHERE name = N'tsql_stack' 
			AND target_name = N'ring_buffer'
	) AS Data 
	-- Split out the Event Nodes 
	CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)
) AS tab (event_id, tsql_stack)
CROSS APPLY tsql_stack.nodes ('(frames/frame)') AS stack(frame);


/*
	What's executing the function?
*/
SELECT
	event_id,
	level,
	handle,
	line,
	offset_start,
	offset_end,
	st.dbid,
	st.objectid,
	OBJECT_NAME(st.objectid, st.dbid) AS ObjectName,
    SUBSTRING(st.text, (offset_start/2)+1, 
        ((CASE offset_end
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE offset_end
         END - offset_start)/2) + 1) AS stmt

FROM
(
	SELECT 
		event_id,
		frame.value('(@level)[1]', 'int') AS [level],
		frame.value('xs:hexBinary(substring((@handle)[1], 3))', 'varbinary(max)') AS [handle],
		frame.value('(@line)[1]', 'int') AS [line],
		frame.value('(@offsetStart)[1]', 'int') AS [offset_start],
		frame.value('(@offsetEnd)[1]', 'int') AS [offset_end]
	FROM
	(
		SELECT 
			ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
			XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS [tsql_stack]
		FROM 
		(    -- Cast the target_data to XML 
			SELECT CAST(target_data AS XML) AS TargetData 
			FROM sys.dm_xe_session_targets st 
			JOIN sys.dm_xe_sessions s 
				ON s.address = st.event_session_address 
			WHERE name = N'tsql_stack' 
				AND target_name = N'ring_buffer'
		) AS Data 
		-- Split out the Event Nodes 
		CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)
	) AS tab 
	CROSS APPLY tsql_stack.nodes ('(frames/frame)') AS stack(frame)
) AS tab2
CROSS APPLY sys.dm_exec_sql_text(handle) AS st;


/*
	Call third SP directly and look at output
*/
EXECUTE dbo.CalledThird 100;
GO

/*
	Call the other SP
*/
EXECUTE dbo.OtherProcedure;
GO


/*
	Stop event session
*/
ALTER EVENT SESSION [tsql_stack]
ON SERVER
STATE=STOP;
GO


/*
	Clean up
*/
DROP EVENT SESSION [tsql_stack] 
	ON SERVER;
GO