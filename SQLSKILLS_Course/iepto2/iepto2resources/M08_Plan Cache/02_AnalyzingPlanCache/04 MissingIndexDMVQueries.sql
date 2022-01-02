/*============================================================================
  File:     MissingIndexDMVQueries.sql

  Summary:  This script gives you the queries that need the indexes
            defined by the missing index DMVs.

  SQL Server Versions: 2008
------------------------------------------------------------------------------
  Written by Jonathan M. Kehayias (mostly!!!) 
    and a little bit of Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 back and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE Credit
go


SELECT m.lastname, m.firstname, m.middleinitial
FROM dbo.member AS m
WHERE m.firstname = 'Kimberly'
go

-- This comes from the following blog post from Jonathan Kehayias:
-- http://sqlblog.com/blogs/jonathan_kehayias/archive/2009/07/27/digging-into-the-sql-plan-cache-finding-missing-indexes.aspx


WITH XMLNAMESPACES  
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
    
SELECT query_plan, 
       n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text, 
       n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact, 
       DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'),'[',''),']','')) AS database_id, 
       OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + 
           n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + 
           n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) AS OBJECT_ID, 
       n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + 
           n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + 
           n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')  
       AS statement, 
       (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', ' 
           FROM n.nodes('//ColumnGroup') AS t(cg) 
           CROSS APPLY cg.nodes('Column') AS r(c) 
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY' 
           FOR  XML PATH('') 
       ) AS equality_columns, 
        (  SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', ' 
           FROM n.nodes('//ColumnGroup') AS t(cg) 
           CROSS APPLY cg.nodes('Column') AS r(c) 
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY' 
           FOR  XML PATH('') 
       ) AS inequality_columns, 
       (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', ' 
           FROM n.nodes('//ColumnGroup') AS t(cg) 
           CROSS APPLY cg.nodes('Column') AS r(c) 
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE' 
           FOR  XML PATH('') 
       ) AS include_columns 
INTO #MissingIndexInfo 
FROM  
( 
   SELECT query_plan 
   FROM (    
           SELECT DISTINCT plan_handle 
           FROM sys.dm_exec_query_stats WITH(NOLOCK)  
         ) AS qs 
       OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp     
   WHERE tp.query_plan.exist('//MissingIndex')=1 
) AS tab (query_plan) 
CROSS APPLY query_plan.nodes('//StmtSimple') AS q(n) 
WHERE n.exist('QueryPlan/MissingIndexes') = 1 

-- Trim trailing comma from lists 
UPDATE #MissingIndexInfo 
SET equality_columns = LEFT(equality_columns,LEN(equality_columns)-1), 
   inequality_columns = LEFT(inequality_columns,LEN(inequality_columns)-1), 
   include_columns = LEFT(include_columns,LEN(include_columns)-1) 
    
SELECT * 
FROM #MissingIndexInfo 

DROP TABLE #MissingIndexInfo 
go
