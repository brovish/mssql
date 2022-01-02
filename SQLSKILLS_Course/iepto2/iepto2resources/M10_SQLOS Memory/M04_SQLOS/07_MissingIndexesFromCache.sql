/*============================================================================
  File:     MissingIndexesFromCache.sql

  Summary:  Gathers Missing Index information from the plan cache and ties
	    the details back to the procedure and/or statement that generated
	    the details.  Also includes output from sys.dm_exec_query_stats
	    to determine the relative impact overall to the system 
	    realistically.

  Date:     March 2011

  SQL Server Version: 10.0.2531.0 (SQL Server 2008 SP1)
------------------------------------------------------------------------------
	Written by Jonathan M. Kehayias, SQLskills.com
	
  (c) 2011, SQLskills.com. All rights reserved.

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

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH XMLNAMESPACES  
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT 
	MissingIndexNode.value('(MissingIndexGroup/@Impact)[1]', 'float') AS impact, 
	OBJECT_NAME(sub.objectid, sub.dbid) AS calling_object_name,
	MissingIndexNode.value('(MissingIndexGroup/MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + 
	   MissingIndexNode.value('(MissingIndexGroup/MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + 
	   MissingIndexNode.value('(MissingIndexGroup/MissingIndex/@Table)[1]', 'VARCHAR(128)') AS table_name, 
	STUFF((	SELECT  ','+c.value('(@Name)[1]', 'VARCHAR(128)')
			FROM MissingIndexNode.nodes('MissingIndexGroup/MissingIndex/ColumnGroup[@Usage="EQUALITY"]/Column') AS t(c) 
			FOR XML PATH('') 
		),1,1,'') AS equality_columns, 
	STUFF((	SELECT ','+c.value('(@Name)[1]', 'VARCHAR(128)')
			FROM MissingIndexNode.nodes('MissingIndexGroup/MissingIndex/ColumnGroup[@Usage="INEQUALITY"]/Column') AS t(c) 
			FOR XML PATH('') 
		),1,1,'') AS inequality_columns, 
	STUFF((	SELECT ','+c.value('(@Name)[1]', 'VARCHAR(128)')
			FROM MissingIndexNode.nodes('MissingIndexGroup/MissingIndex/ColumnGroup[@Usage="INCLUDE"]/Column') AS t(c) 
			FOR XML PATH('') 
		),1,1,'') AS include_columns,
	sub.usecounts AS qp_usecounts,
	sub.refcounts AS qp_refcounts,
	qs.execution_count as qs_execution_count,
	qs.last_execution_time AS qs_last_exec_time,
	qs.total_logical_reads AS qs_total_logical_reads,
	qs.total_elapsed_time AS qs_total_elapsed_time,
	qs.total_physical_reads AS qs_total_physical_reads,
	qs.total_worker_time AS qs_total_worker_time,
	StmtPlanStub.value('(StmtSimple/@StatementText)[1]', 'varchar(8000)') AS statement_text
FROM (	SELECT 
			ROW_NUMBER() OVER(PARTITION BY qs.plan_handle ORDER BY qs.statement_start_offset) AS StatementID,
			qs.*
		FROM sys.dm_exec_query_stats qs
	 ) AS qs
JOIN (	SELECT x.query('../../..') as StmtPlanStub,
			x.query('.') as MissingIndexNode,
			x.value('(../../../@StatementId)[1]', 'int') as StatementID,
			cp.*, 
			qp.*
		FROM sys.dm_exec_cached_plans AS cp
		CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
		CROSS APPLY qp.query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup') mi(x)
	 ) AS sub 
	ON qs.plan_handle = sub.plan_handle and qs.StatementID = sub.StatementID
