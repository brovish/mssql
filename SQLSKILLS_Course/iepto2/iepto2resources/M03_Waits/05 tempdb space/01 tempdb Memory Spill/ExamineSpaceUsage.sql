/*============================================================================
  File:     ExamineSpaceUsage.sql

  Summary:  Examine tempdb space usage

  SQL Server Versions: 2005 onwards
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

-- What tasks are taking up space right now?
--
-- This is code I've used on customer sites for automated tempdb tracking
-- Internal: worktables (cursor, spool) , workfiles (hash joins), sort
-- User: everything else
--
SELECT 
	GETDATE () AS [Date],
	[tsu].[session_id] AS [SessionID],
	[tsu].[exec_context_id] AS [ExecContextID],
	([tsu].[user_objects_alloc_page_count] - [tsu].[user_objects_dealloc_page_count]) AS [UserPages],
	ROUND (CONVERT (FLOAT, ([tsu].[user_objects_alloc_page_count] -
		[tsu].[user_objects_dealloc_page_count]) * 8) / 1024.0, 2) AS [UserMB],
	([tsu].[internal_objects_alloc_page_count] - [tsu].[internal_objects_dealloc_page_count]) AS [InternalPages],
	ROUND (CONVERT (FLOAT, ([tsu].[internal_objects_alloc_page_count] -
		[tsu].[internal_objects_dealloc_page_count]) * 8) / 1024.0, 2) AS [InternalMB],
	[er].[plan_handle] AS [Plan],
	[est].[text] AS [Text]
FROM
	sys.dm_db_task_space_usage [tsu]
	JOIN sys.dm_exec_requests [er]
		ON [er].[session_id] = [tsu].[session_id]
	CROSS APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
/*
WHERE
	-- Look for anything using 128MB or more
	(([user_objects_alloc_page_count] - [user_objects_dealloc_page_count]) +
		([internal_objects_alloc_page_count] - [internal_objects_dealloc_page_count])) >= 16384
*/
ORDER BY
	(([user_objects_alloc_page_count] - [user_objects_dealloc_page_count]) +
		([internal_objects_alloc_page_count] - [internal_objects_dealloc_page_count])) DESC;
GO



