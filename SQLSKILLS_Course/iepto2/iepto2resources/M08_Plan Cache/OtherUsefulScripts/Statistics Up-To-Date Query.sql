/*============================================================================
  File:     Statistics Up-to-date QUery.sql

  Summary:  Using sys.stats to review the current state of your statistics.
  
  SQL Server Version: SQL Server 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHA NTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- To see ALL of your statistics (index stats, user stats, auto stats, hypothetical
-- indexes [stats]) then query sys.stats. If you only want to see statistics on 
-- indexes, use the 2nd query against sys.indexes instead of sys.stats.

-- This is just the statistics on indexes
SELECT 
	CASE 
		WHEN OBJECTPROPERTY( [si].[object_id], 'IsUserTable') = 1 THEN 'T'
		WHEN OBJECTPROPERTY( [si].[object_id], 'IsView') = 1 THEN 'V'
	END			AS [Type]
	, OBJECT_NAME([si].[object_id]) 	AS [ObjectName]
	, CASE 
		WHEN [si].[index_id] = 0 THEN 'Heap'
		WHEN [si].[index_id] = 1 THEN 'CL'
		WHEN [si].[index_id] BETWEEN 2 AND 31005 
            THEN 'NC ' 
                + RIGHT('0000' + CONVERT(varchar, [si].[index_id]), 5)
		ELSE ''
	  END 							AS [IndexType]
	, [si].[name] 					AS [IndexName]
	, [si].[index_id]				AS [IndexID]
	, CASE
		WHEN [si].[index_id] BETWEEN 1 AND 31005 
                AND STATS_DATE (si.[object_id], si.[index_id]) 
                    < DATEADD(m, -1, GETDATE()) 
			THEN '! More than a month OLD !'
		WHEN [si].[index_id] BETWEEN 1 AND 31005 
                AND STATS_DATE (si.[object_id], si.[index_id]) 
                    < DATEADD(wk, -1, getdate()) 
			THEN '! Within the past month !'
		WHEN [si].[index_id] BETWEEN 1 AND 31005 
            THEN 'Stats recent'
		ELSE ''
	  END
        AS [Warning]
	, STATS_DATE ([si].[object_id], [si].[index_id]) 	
        AS [Last Stats Update]
FROM [sys].[indexes] AS [si]
WHERE (OBJECTPROPERTY([si].[object_id], 'IsUserTable') = 1 OR OBJECTPROPERTY([si].[object_id], 'IsView') = 1)
ORDER BY [ObjectName], [si].[index_id];
GO

---------------------------------------------------------------------------
------------------------------- MUCH BETTER ------------------------------- 
---------------------------------------------------------------------------
-- Or, how about ALL statistics (even those created on a col not an index)
---------------------------------------------------------------------------
SELECT 
	CASE 
		WHEN OBJECTPROPERTY( [s].[object_id], 'IsUserTable') = 1 THEN 'T'
		WHEN OBJECTPROPERTY( [s].[object_id], 'IsView') = 1 THEN 'V'
	END			AS [Type]
	, OBJECT_NAME([s].[object_id]) 	AS [ObjectName]
	, CASE 
		WHEN [s].[stats_id] = 0 then 'Heap'
		WHEN [s].[stats_id] = 1 then 'CL'
		WHEN INDEXPROPERTY ( [s].[object_id], [s].[name], 'IsAutoStatistics') = 1 THEN 'Stats-Auto'
		WHEN INDEXPROPERTY ( [s].[object_id], [s].[name], 'IsHypothetical') = 1 THEN 'Stats-HIND'
		WHEN INDEXPROPERTY ( [s].[object_id], [s].[name], 'IsStatistics') = 1 THEN 'Stats-User'
		WHEN [s].[stats_id] BETWEEN 2 AND 31005 -- and, it's not a statistic
			THEN 'NC ' + RIGHT('0000' + convert(varchar, [s].[stats_id]), 5)
		ELSE 'Text/Image'
	  END 			AS [IndexType]
	, [s].[name] 		AS [IndexName]
	, [s].[stats_id]		AS [IndexID]
	, CASE
		WHEN STATS_DATE ([s].[object_id], [s].[stats_id]) < DATEADD(m, -1, getdate()) 
			THEN '!! More than a month OLD !!'
		WHEN STATS_DATE ([s].[object_id], [s].[stats_id]) < DATEADD(wk, -1, getdate()) 
			THEN '! Within the past month !'
		ELSE 'Stats recent'
	  END 			AS [Warning]
	, STATS_DATE ([s].[object_id], [s].[stats_id]) 	AS [Last Stats Update]
	, CASE 
		WHEN no_recompute = 0 THEN 'YES'
		ELSE 'NO'
	  END AS 'AutoUpdate'
FROM [sys].[stats] AS [s]
WHERE (OBJECTPROPERTY([s].[object_id], 'IsUserTable') = 1 OR OBJECTPROPERTY([s].[object_id], 'IsView') = 1)
--	AND (INDEXPROPERTY ( si.[object_id], si.[name], 'IsAutoStatistics') = 1 
--			OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsHypothetical') = 1 
--			OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsStatistics') = 1)
--ORDER BY [Last Stats Update] DESC
ORDER BY [ObjectName], [s].[stats_id];

-- For automation and to motify Ola's scripts - use the following DMV
-- (added originally in 2008R2 SP2+ or 2012 SP1+)
SELECT * 
FROM [sys].[dm_db_stats_properties] (object_id('dbo.member'), 4);
GO

-- For a good post on the DMV and what it shows:
-- https://www.sqlskills.com/blogs/erin/sqlskills-sql101-updating-sql-server-statistics-part-ii-scheduled-updates/
-- And more details here: https://www.red-gate.com/simple-talk/sql/performance/managing-sql-server-statistics/

-- Finally, here's Ola's site - this is what you should use as a base and 
-- modify as desired: http://ola.hallengren.com/