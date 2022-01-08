/*============================================================================
  File:     SQLskills_PlanCacheSummary.sql

  Summary:  This script summarizes the Plan Cache usage information for an
	    instance of SQL Server

  Date:     August 2011

  SQL Server Versions:
		10.0.2531.00 (SS2008 SP1)
		9.00.4035.00 (SS2005 SP3)
  Based on a script by Kimberly L. Tripp:
	http://www.sqlskills.com/BLOGS/KIMBERLY/post/Procedure-cache-and-optimizing-for-adhoc-workloads.aspx
------------------------------------------------------------------------------
  Adapted by Jonathan M. Kehayias, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/
:Setvar SQLCMDMAXVARTYPEWIDTH 0
:Setvar SQLCMDHEADERS 5000

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULL_DFLT_ON ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ANSI_NULLS ON

SELECT '-- SQLskills_PlanCacheSummary'

SELECT objtype AS [cache_type]
        , count_big(*) AS [total_plan_count]
        , sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [total_size_mbytes]
        , avg(usecounts) AS [avg_use_counts]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [single_use_size_mbytes]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [single_use_plan_count]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [single_use_size_mbytes] DESC