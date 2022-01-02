/*============================================================================
  Summary: This script helps to determine how much of your cache is
	dedicated to plans that are only used once. The key is to 
	understanding if/when you need the new 2008 config option 
	"optimize for adhoc workloads." 
  
  SQL Server Version: analysis in SQL Server 2005+ but
	Optimize for adhoc workloads was added in SQL Server 2008
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- First, verify the state of your cache... 
-- is it filled with "USE Count 1" plans?
SELECT [objtype] AS [CacheType]
	, COUNT_BIG (*) AS [Total Plans]
	, SUM (CAST ([size_in_bytes] AS DECIMAL (18, 2)))
		/ 1024 / 1024 AS [Total MBs]
	, AVG ([usecounts]) AS [Avg Use Count]
	, SUM (CAST ((CASE WHEN [usecounts] = 1 
		THEN [size_in_bytes] ELSE 0 END) AS DECIMAL (12, 2)))
		/ 1024 / 1024 AS [Total MBs - USE Count 1]
	, SUM (CASE WHEN [usecounts] = 1 THEN 1 ELSE 0 END) 
		AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY [objtype]
ORDER BY [Total MBs - USE Count 1] DESC;
GO

-- Here's your top 100
SELECT TOP (100) [text], [cp].[size_in_bytes]
FROM sys.dm_Exec_cached_plans AS [cp]
    CROSS APPLY sys.dm_exec_sql_text ([plan_handle]) 
WHERE [cacheobjtype] = N'Compiled Plan' 
    AND [cp].[objtype] = N'Adhoc' 
    AND [cp].[usecounts] = 1
ORDER BY [cp].[size_in_bytes] DESC;
GO

-- Here's the statement text from the plans as grouped above
SELECT [cp].[objtype], [cp].*, [st].[text]
FROM sys.dm_exec_cached_plans AS [cp]
	CROSS APPLY sys.dm_exec_sql_text ([cp].[plan_handle]) AS [st]
ORDER BY [cp].[objtype];
GO

-- This will clear all "USE Count 1" plans but is manual
DBCC FREESYSTEMCACHE (N'SQL Plans'); -- 2005 and higher
GO

-- And, if you see this as a regular problem... 
-- in SQL Server 2008+
sp_configure N'optimize for ad hoc workloads', 1;
GO

RECONFIGURE
GO