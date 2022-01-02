/*============================================================================
  File:     LookupsFromPlanCache.sql

  Summary:  This script queries the plan cache for plans containing Key/RID 
	    Lookups and outputs information about the missing columns from
            the non-clustered index and the estimated number of rows/loops
            the plan would perform for the operation.

  Date:     July 2011

  SQL Server Versions:
		10.0.2531.00 (SS2008 SP1)
		9.00.4035.00 (SS2005 SP3)
------------------------------------------------------------------------------
  Written by Jonathan M. Kehayias, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/




;WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')   
SELECT DISTINCT 
	NestedLoopsOp.value('(NestedLoops/RelOp[1]/@EstimateRows)[1]', 'float') AS EstimatedRows,
    SQL_Text, 
    DatabaseName,
    SchemaName,
    TableName,
    tbl.spc.value('(@Index)[1]', 'varchar(128)') AS NonClusteredIndexName,
    STUFF((    SELECT DISTINCT ',' + cg.value('(@Column)[1]', 'VARCHAR(128)')
            FROM ClusteredIndex.nodes('IndexScan/DefinedValues/DefinedValue/ColumnReference') AS t(cg)
            FOR  XML PATH('') 
        ), 1,1,'') AS OutputColumns
FROM
(  
    SELECT 
            stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text,
            obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName,
            obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName,
            obj.value('(@Table)[1]', 'varchar(128)') AS TableName,
            obj.value('(@Index)[1]', 'varchar(128)') AS IndexName,
            obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind,
            obj.query('../../..') AS NestedLoopsOp,
            obj.query('..') AS ClusteredIndex
    FROM sys.dm_exec_cached_plans
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
    CROSS APPLY query_plan.nodes('/ShowPlanXML[1]/BatchSequence[1]/Batch[1]/Statements[1]/StmtSimple') AS batch(stmt)
    CROSS APPLY stmt.nodes('.//IndexScan[@Lookup=1]/Object[@Schema!="[sys]"]') AS idx(obj)
    WHERE query_plan.exist('//IndexScan/@Lookup[.=1]') = 1
      AND obj.exist('../IndexScan/DefinedValues/DefinedValue/ColumnReference') = 1
) AS tab
CROSS APPLY NestedLoopsOp.nodes('//IndexScan[1]/Object[@Database=sql:column("DatabaseName")][@Table=sql:column("TableName")][@Index!=sql:column("IndexName")]') AS tbl(spc)
ORDER BY EstimatedRows DESC;