/*============================================================================
  File:     ImplicitConversions.sql

  Summary:  This script finds implicit conversions in the cache and 
            produces information about the query and the columns that 
            didn't match.
  
  SQL Server Versions: 2005/2008
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

CREATE INDEX LName ON member(lastname)
go

UPDATE member
    SET lastname = 'Tripp'
    WHERE member_no = 1234
go

SET STATISTICS IO ON
go

-- Reminder: Run twice if optimize for adhoc workloads is turned on

-- Turn on showplan and run these two
SELECT * FROM member WHERE lastname = 'Tripp'
go

SELECT * FROM member WHERE lastname = N'Tripp'
go

-- Now - check for these within the cache
-- This code comes from Jon's blog post: Finding Implicit Column Conversions in the Plan Cache
-- http://sqlblog.com/blogs/jonathan_kehayias/archive/2010/01/08/finding-implicit-column-conversions-in-the-plan-cache.aspx
    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

DECLARE @dbname SYSNAME 
SET @dbname = QUOTENAME(DB_NAME()); 

WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT 
   stmt.value('(@StatementText)[1]', 'varchar(max)'), 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)'), 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)'), 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)'), 
   ic.DATA_TYPE AS ConvertFrom, 
   ic.CHARACTER_MAXIMUM_LENGTH AS ConvertFromLength, 
   t.value('(@DataType)[1]', 'varchar(128)') AS ConvertTo, 
   t.value('(@Length)[1]', 'int') AS ConvertToLength, 
   query_plan 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t) 
JOIN INFORMATION_SCHEMA.COLUMNS AS ic 
   ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)') 
   AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)') 
   AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') 
WHERE t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1 
OPTION (MAXDOP 1)
go

-- The same thing can happen with probe residual but it's a bit less
-- obvious here (doesn't show as implicit conversion)

SELECT CONVERT(DECIMAL(12, 0), [member_no]) AS [member_no]
      ,[lastname]
      ,[firstname]
      ,[middleinitial]
      ,[street]
      ,[city]
      ,[state_prov]
      ,[country]
      ,[mail_code]
      ,[phone_no]
      ,[photograph]
      ,[issue_dt]
      ,[expr_dt]
      ,[region_no]
      ,[corp_no]
      ,[prev_balance]
      ,[curr_balance]
      ,[member_code]
INTO [dbo].[member3]
FROM [dbo].[member];
GO

CREATE UNIQUE CLUSTERED INDEX Member3CL ON Member3 (member_no);
GO

SET STATISTICS PROFILE OFF
go

SET STATISTICS TIME ON
go

SELECT m.member_no, m.lastname, c.charge_amt
FROM dbo.member AS m
    JOIN dbo.charge AS c
        ON m.member_no = c.member_no
OPTION (MAXDOP 1)        
go

SELECT m.member_no, m.lastname, c.charge_amt
FROM dbo.member3 AS m
    JOIN dbo.charge AS c
	    ON m.member_no = c.member_no
--        ON convert(int, m.member_no) = c.member_no
OPTION (MAXDOP 1)
go

-- Now - check for these within the cache
-- This code is modified from Jon's above.

SET STATISTICS PROFILE OFF
go
    
DECLARE @dbname SYSNAME = QUOTENAME(DB_NAME());

WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT query_plan,
   BuildSchema,
   BuildTable,
   BuildColumn,
   ic.DATA_TYPE AS BuildColumnType, 
   ISNULL(CAST(ic.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR), 
        (CAST(ic.NUMERIC_PRECISION AS NVARCHAR)
            + ',' +CAST(ic.NUMERIC_SCALE AS NVARCHAR))) AS  BuildColumnLength,
   ProbeSchema,
   ProbeTable,
   ProbeColumn,
   ic2.DATA_TYPE AS ProbeColumnType, 
   ISNULL(CAST(ic2.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR), 
        (CAST(ic2.NUMERIC_PRECISION AS NVARCHAR)
            + ',' + CAST(ic2.NUMERIC_SCALE AS NVARCHAR))) AS ProbeColumnLength
FROM
(
SELECT 
   query_plan,
   t.value('(../HashKeysBuild/ColumnReference/@Schema)[1]', 'nvarchar(128)') AS BuildSchema,
   t.value('(../HashKeysBuild/ColumnReference/@Table)[1]', 'nvarchar(128)') AS BuildTable,
   t.value('(../HashKeysBuild/ColumnReference/@Column)[1]', 'nvarchar(128)') AS BuildColumn,
   t.value('(../HashKeysProbe/ColumnReference/@Schema)[1]', 'nvarchar(128)') AS ProbeSchema,
   t.value('(../HashKeysProbe/ColumnReference/@Table)[1]', 'nvarchar(128)') AS ProbeTable,
   t.value('(../HashKeysProbe/ColumnReference/@Column)[1]', 'nvarchar(128)') AS ProbeColumn
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//Hash/ProbeResidual') AS n(t) 
WHERE t.exist('../HashKeysProbe/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1 
) AS Probes
LEFT JOIN INFORMATION_SCHEMA.COLUMNS AS ic 
   ON QUOTENAME(ic.TABLE_SCHEMA) = Probes.BuildSchema
   AND QUOTENAME(ic.TABLE_NAME) = Probes.BuildTable
   AND ic.COLUMN_NAME = Probes.BuildColumn
LEFT JOIN INFORMATION_SCHEMA.COLUMNS AS ic2
   ON QUOTENAME(ic2.TABLE_SCHEMA) = Probes.ProbeSchema
   AND QUOTENAME(ic2.TABLE_NAME) = Probes.ProbeTable
   AND ic2.COLUMN_NAME = Probes.ProbeColumn
WHERE ic.DATA_TYPE <> ic2.DATA_TYPE
    OR (
        ic.DATA_TYPE = ic2.DATA_TYPE 
        AND ISNULL(CAST(ic.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR), 
                (CAST(ic.NUMERIC_PRECISION AS NVARCHAR)
                + ',' +CAST(ic.NUMERIC_SCALE AS NVARCHAR))) 
            <> ISNULL(CAST(ic2.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR), 
                (CAST(ic2.NUMERIC_PRECISION AS NVARCHAR)
                + ',' + CAST(ic2.NUMERIC_SCALE AS NVARCHAR)))
        )
OPTION (MAXDOP 1);
go


--- Other non-seekable expressions
SELECT * FROM MEMBER 
    WHERE DATEADD(yy, 21, birthday) <= 'party date'

SELECT * FROM MEMBER 
    WHERE birthday <= DATEADD(yy, -21, 'party date')
