/*============================================================================
  File:     2a_tempdb_DMV.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Jonathan Kehayias, SQLskills.com
	Modified by Erin Stellato, SQLskills.com
  
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
	Query DMV to look at contention
	Challenges compared to XE?
*/
SELECT 
   session_id,
   wait_type,
   wait_duration_ms,
   blocking_session_id,
   resource_description,
   ResourceType = CASE
   WHEN PageID = 1 OR PageID % 8088 = 0 THEN 'Is PFS Page'
   WHEN PageID = 2 OR PageID % 511232 = 0 THEN 'Is GAM Page'
   WHEN PageID = 3 OR (PageID - 1) % 511232 = 0 THEN 'Is SGAM Page'
       ELSE 'Is Not PFS, GAM, or SGAM page'
   END
FROM (  SELECT  
           session_id,
           wait_type,
           wait_duration_ms,
           blocking_session_id,
           resource_description,
           CAST(RIGHT(resource_description, LEN(resource_description)
           - CHARINDEX(':', resource_description, 3)) AS INT) AS PageID
       FROM sys.dm_os_waiting_tasks
       WHERE wait_type LIKE 'PAGE%LATCH_%'
         AND resource_description LIKE '2:%'
) AS tab;