/*============================================================================
  File:     YieldDebug.sql

  Summary:  Debug SOS_SCHEDULER_YIELD waits

  SQL Server Versions: 2008 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

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

-- Look at CPUs - all 100%

-- Explain: why no waiting tasks?

-- Look at wait stats

-- Look at spinlock stats

-- Looks like the LOCK_HASH spinlock could be contributing, but is it?
-- Prove that SOS_SCHEDULER_YIELD is not a spinlock issue...
-- Use XEvents to capture call stacks when SOS_SCHEDULER_YIELD occurs

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

-- Check what wait type value to use
SELECT * FROM sys.dm_xe_map_values WHERE [map_value] = 'SOS_SCHEDULER_YIELD';
GO

-- Create the event session
-- Make sure to set the wait_type for the build you're using
-- On SQL 2012/2014 the target name is 'histogram' but the old
-- name still works.
CREATE EVENT SESSION [MonitorWaits] ON SERVER
ADD EVENT [sqlos].[wait_info]
	(ACTION ([package0].[callstack])
	WHERE [wait_type] = 99 -- SOS_SCHEDULER_YIELD only
	AND  [opcode] = 1) -- Just the end-of-wait events
ADD TARGET [package0].[asynchronous_bucketizer] (
    SET filtering_event_name = N'sqlos.wait_info',
    source_type = 1, -- source_type = 1 is an action
    source = N'package0.callstack') -- bucketize on the callstack
WITH (MAX_MEMORY = 50MB, max_dispatch_latency = 5 seconds)
GO

-- Start the session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = START;
GO

-- TF to allow call stack resolution
-- Note that 2019 also requires trace flag 2592
DBCC TRACEON (3656, -1);
DBCC TRACEON (2592, -1);
GO

-- Get the callstacks from the bucketizer target
-- Are they showing calls into the lock manager?
SELECT
	[event_session_address],
	[target_name],
	[execution_count],
	CAST ([target_data] AS XML)
FROM sys.dm_xe_session_targets [xst]
INNER JOIN sys.dm_xe_sessions [xs]
	ON ([xst].[event_session_address] = [xs].[address])
WHERE [xs].[name] = N'MonitorWaits';
GO

-- Now stop the workload by double-clicking the
-- file StopTest.cmd

-- Stop the event session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = STOP;
GO

-- And clean up
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

USE [master];
GO

IF DATABASEPROPERTYEX (N'YieldTest', N'Version') > 0
BEGIN
	ALTER DATABASE [YieldTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [YieldTest];
END
GO