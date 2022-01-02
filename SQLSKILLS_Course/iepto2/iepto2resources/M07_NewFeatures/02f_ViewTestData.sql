/*============================================================================
  File:     02f_ViewTestData.sql

  SQL Server Versions: 2016 onwards
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

SELECT *, DATEDIFF(MS,TestStartTime, TestEndTime) [TestDuration]
FROM [TestTracking].[dbo].[TrackTests]
ORDER BY [TestID];
GO

SELECT 
	[TestName], 
	AVG(DATEDIFF(MS,TestStartTime, TestEndTime)) [AvgTestDuration],
	SUM(DATEDIFF(MS,TestStartTime, TestEndTime)) [TotalTestDuration]
FROM [TestTracking].[dbo].[TrackTests]
GROUP BY [TestName]
ORDER BY [TestName];
GO



USE [InMemTesting];
GO

SELECT
	[qst].[query_text_id],
	[qsq].[query_id], 
	[qsp].[plan_id],
	OBJECT_NAME([qsq].[object_id]),
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qsp].[query_plan],
	[rs].[count_executions],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[avg_cpu_time]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] <> 0
ORDER BY [qst].[query_text_id] DESC;
GO
                               
									  
/*
	Clean up
*/          
USE [master];
GO

                          
DROP DATABASE IF EXISTS [InMemTesting];
GO                                 
DROP DATABASE IF EXISTS [TestTracking];
GO                                                                                                                                                                                                                                                                                        