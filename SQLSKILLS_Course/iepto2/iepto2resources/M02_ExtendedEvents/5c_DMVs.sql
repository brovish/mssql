/*============================================================================
  File:     5c_DMVs.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
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
	What packages exist, from what module are they loaded?
	Packages are top level containers of metadata for the other objects that exist inside of XE  
	contain a combination of events, actions, targets, maps, predicates and types
*/
SELECT 
	[p].[name], 
	[p].[description], 
	[m].[name]
FROM [sys].[dm_xe_packages] [p]
JOIN [sys].[dm_os_loaded_modules] [m] 
	ON [p].[module_address] = [m].[base_address];



/*
	What events can I use?
	An event corresponds to a specific point in code where something 
	of interest occurs inside the Database Engine
*/
SELECT 
	[name], 
	[object_type], 
	[description], 
	[object_type], 
	[description] 
FROM [sys].[dm_xe_objects]
WHERE [object_type] = N'event'
ORDER BY [name];
GO


/*
	List the package associated with the event
*/
SELECT 
	[xo].[name], 
	[xo].[description], 
	[xp].[name] AS [package]
FROM [sys].[dm_xe_objects] [xo]
JOIN [sys].[dm_xe_packages] [xp]
	ON [xo].[package_guid] = [xp].[guid]
WHERE [xo].[object_type] = N'event'
and [xo].[name] like '%plan%'
ORDER BY [xo].[name];
GO


/*
	List the channel for the event
*/
SELECT 
	[o].[name] AS [Event], 
	CASE	
		WHEN [oc].[column_value] = 1 THEN 'Admin'
		WHEN [oc].[column_value] = 2 THEN 'Analytic'
		WHEN [oc].[column_value] = 3 THEN 'Debug'
		WHEN [oc].[column_value] = 4 THEN 'Operational'
	END AS [Channel], 
	[o].[description] AS [EventDesc]
FROM [sys].[dm_xe_objects] [o]
JOIN [sys].[dm_xe_object_columns] [oc] ON [o].[package_guid] = [oc].[object_package_guid] AND [o].[name] = [oc].[object_name]
WHERE [o].[object_type] = N'event'
AND [oc].[name] = 'Channel'



/*
	If we want to capture the sp_statement_completed event,
	what elements are part of the default payload?
	Note that in some cases, an element is optional (capabilities_desc)
*/
SELECT 
	[object_name], 
	[name], 
	[column_id], 
	[type_name], 
	[column_type], 
	[capabilities_desc], 
	[description]
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = N'sp_statement_completed'
AND [column_type] <> 'readonly';
GO


/*
	what actions can I add?
*/
SELECT 
	[xp].[name] AS [Package],
	[xo].[name] AS [Action],
	[xo].[description] AS [Description]
FROM [sys].[dm_xe_packages] AS [xp]
JOIN [sys].[dm_xe_objects] AS [xo]
	ON [xp].[guid] = [xo].package_guid
WHERE ([xp].[capabilities] IS NULL OR [xp].[capabilities] & 1 = 0)
	AND ([xo].[capabilities] IS NULL OR [xo].[capabilities] & 1 = 0)
	AND [xo].[object_type] = 'action'
ORDER BY [xo].[name];


/*
	What global predicates are available?
*/
SELECT 
    [p].[name] AS [package_name],
    [o].[name] AS [predicate_name],
    [o].[description]
FROM [sys].[dm_xe_packages] AS [p]
INNER JOIN [sys].[dm_xe_objects] AS [o]
    ON [p].[guid] = [o].[package_guid]
WHERE ([p].[capabilities] IS NULL OR [p].[capabilities] & 1 = 0)
  AND [o].[object_type] = 'pred_source'


/*
	what targets exist?
*/
SELECT 
	[name], 
	[object_type], 
	[description], 
	[capabilities_desc]
FROM [sys].[dm_xe_objects]
WHERE [object_type] = N'target'
AND ([capabilities_desc] NOT LIKE 'private%' OR [capabilities_desc] IS NULL)
ORDER BY [name];
GO


/*
	If we want to capture the lock_escalation event,
	what elements are part of the default payload?
	Note that lock_mode is part of the default payload.
	What are the different lock_mode values?
*/
SELECT 
	[object_name], 
	[name], 
	[column_id], 
	[type_name], 
	[column_type], 
	[capabilities_desc], 
	[description]
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = N'lock_escalation'
AND [column_type] <> 'readonly';
GO

/*
	What are the 'lock_mode' maps?
*/
SELECT 
	[xmv].[name], 
	[xmv].[map_key], 
	[xmv].[map_value]
FROM sys.dm_xe_map_values [xmv]
JOIN sys.dm_xe_packages [xp]
		ON [xmv].[object_package_guid] = [xp].[guid]
WHERE [xmv].[name] = N'lock_mode';
GO


/*
	what sessions exist?
*/
SELECT  [address],
        [name],
        [pending_buffers],
        [total_regular_buffers],
        [regular_buffer_size],
        [total_large_buffers],
        [large_buffer_size],
        [total_buffer_size],
        [buffer_policy_flags],
        [buffer_policy_desc],
        [flags],
        [flag_desc],
        [dropped_event_count],
        [dropped_buffer_count],
        [blocked_event_fire_time],
        [create_time],
        [largest_event_dropped_size]
FROM sys.[dm_xe_sessions];

/*
	what targets are currently being used?
*/
SELECT  [event_session_address],
        [target_name],
        [target_package_guid],
        [execution_count],
        [execution_duration_ms],
        [target_data]		
FROM sys.[dm_xe_session_targets];


/*
	what events exist for a session?
*/
SELECT 
   es.name AS session_name,
   e.package AS event_package,
   e.name AS event_name,
   e.predicate AS event_predicate
FROM sys.server_event_sessions AS es
INNER JOIN sys.server_event_session_events AS e
    ON es.event_session_id = e.event_session_id
ORDER BY es.name, e.name;


/*
	Get events, predicates, and actions
*/ 
SELECT 
   es.name AS session_name,
   e.package AS event_package,
   e.name AS event_name,
   e.predicate AS event_predicate,
   a.package AS action_package,
   a.name AS action_name
FROM sys.server_event_sessions AS es
INNER JOIN sys.server_event_session_events AS e
    ON es.event_session_id = e.event_session_id
INNER JOIN sys.server_event_session_actions AS a
     ON es.event_session_id = a.event_session_id
    AND e.event_id = a.event_id
ORDER BY es.name, e.name;




