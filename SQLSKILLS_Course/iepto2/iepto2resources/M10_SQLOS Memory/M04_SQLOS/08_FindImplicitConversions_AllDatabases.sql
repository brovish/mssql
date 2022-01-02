/*****************************************************************************
*   FileName:  08_FindImplicitConversions_AllDatabases.sql
*
*   Summary: Queries the plan cache for plans containing implicit column
*			 conversions resulting in a index scan instead of a seek.
*
*   Date: March 21, 2011 
*
*   SQL Server Versions:
*         2005, 2008, 2008 R2
*         
******************************************************************************
*   Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlskills.com/blogs/jonathan
*
*   You may alter this code for your own *non-commercial* purposes. You may
*   republish altered code as long as you include this copyright and give 
*	due credit. 
*
*
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
*   PARTICULAR PURPOSE. 
*
******************************************************************************/

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

IF OBJECT_ID('tempdb..#AllTableColumns') IS NOT NULL
	DROP TABLE #AllTableColumns;

CREATE TABLE #AllTableColumns
(RowID INT IDENTITY PRIMARY KEY,
 DatabaseName SYSNAME, 
 SchemaName SYSNAME,
 TableName SYSNAME,
 ColumnName SYSNAME,
 DataType SYSNAME,
 ColumnLength INT);

EXECUTE sp_MSforeachdb 'INSERT INTO #AllTableColumns
(DatabaseName, SchemaName, TableName, ColumnName, DataType, ColumnLength)
SELECT 
	TABLE_CATALOG, 
	TABLE_SCHEMA, 
	TABLE_NAME, 
	COLUMN_NAME, 
	DATA_TYPE, 
	CHARACTER_MAXIMUM_LENGTH 
FROM [?].INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')';

CREATE NONCLUSTERED INDEX #IX_#AllTableColumns 
ON #AllTableColumns (DatabaseName, SchemaName, TableName, ColumnName);

;WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT 
   objectid,
   usecounts,
   objtype, 
   cacheobjtype, 
   size_in_bytes,
   stmt_node.value('(StmtSimple/@StatementText)[1]', 'varchar(max)') AS StatementText, 
   t.value('(@Database)[1]', 'varchar(128)') AS DatabaseName,
   t.value('(@Schema)[1]', 'varchar(128)') AS SchemaName, 
   t.value('(@Table)[1]', 'varchar(128)') AS TableName, 
   t.value('(@Column)[1]', 'varchar(128)') AS ColumnName, 
   ic.DataType AS ConvertFrom, 
   ic.ColumnLength AS ConvertFromLength, 
   t.value('(../../../@DataType)[1]', 'varchar(128)') AS ConvertTo, 
   t.value('(../../../@Length)[1]', 'int') AS ConvertToLength,
   query_plan
FROM (
	SELECT 
		cp.plan_handle,
		qp.query_plan,
		qp.objectid,
		cp.usecounts, 
		cp.objtype, 
		cp.cacheobjtype, 
		cp.size_in_bytes,
		stmt.query('.') as stmt_node
	FROM sys.dm_exec_cached_plans AS cp 
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
	CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
	WHERE stmt.exist('//IndexScan//Convert[@Implicit="1"]/ScalarOperator/Identifier/ColumnReference') = 1
) as q
CROSS APPLY stmt_node.nodes('//IndexScan//Convert[@Implicit="1"]/ScalarOperator/Identifier/ColumnReference') as n(t)
JOIN #AllTableColumns AS ic 
   ON QUOTENAME(ic.DatabaseName) = t.value('(@Database)[1]', 'varchar(128)') 
   AND QUOTENAME(ic.SchemaName) = t.value('(@Schema)[1]', 'varchar(128)') 
   AND QUOTENAME(ic.TableName) = t.value('(@Table)[1]', 'varchar(128)') 
   AND ic.ColumnName = t.value('(@Column)[1]', 'varchar(128)') 

-- Perform Cleanup
IF OBJECT_ID('tempdb..#AllTableColumns') IS NOT NULL
	DROP TABLE #AllTableColumns;