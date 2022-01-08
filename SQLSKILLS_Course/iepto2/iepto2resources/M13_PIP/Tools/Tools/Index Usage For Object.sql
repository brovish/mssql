/*============================================================================
  File:     SQLskills_IndexUsageForObject.sql

  Summary:  This script shows index usage.
			Must be run in the database being investigated.
			Filtering by object ID in the WHERE clause.

  Date:     May 2010

  SQL Server Versions:
		10.0.2531.00 (SS2008 SP1)
		9.00.4035.00 (SS2005 SP3)
------------------------------------------------------------------------------
  Written by Jonathan M.Kehayias, Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
--============================================================================*/
--:Setvar SQLCMDMAXVARTYPEWIDTH 0
--:Setvar SQLCMDHEADERS 5000

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULL_DFLT_ON ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ANSI_NULLS ON

CREATE TABLE #IndexUsage
(	[DatabaseName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL,
	[IndexName] [sysname] NULL,
	[index_id] [int] NOT NULL,
	[index_type] [int] NOT NULL,
	[is_primary_key] [bit] NULL,
	[is_unique_constraint] [bit] NULL,
	[last_user_seek] [datetime] NULL,
	[user_seeks] [bigint] NOT NULL,
	[SeekPercentage] [numeric](38, 13) NULL,
	[last_user_scan] [datetime] NULL,
	[user_scans] [bigint] NOT NULL,
	[ScanPercentage] [numeric](38, 13) NULL,
	[last_user_lookup] [datetime] NULL,
	[user_lookups] [bigint] NOT NULL,
	[last_user_update] [datetime] NULL,
	[user_updates] [bigint] NOT NULL,
	[last_system_seek] [datetime] NULL,
	[last_system_scan] [datetime] NULL,
	[last_system_lookup] [datetime] NULL,
	[last_system_update] [datetime] NULL
)

-- Cursor based on sp_foreachdb by Aaron Bertrand
-- http://www.mssqltips.com/sqlservertip/2201/making-a-more-reliable-and-flexible-spmsforeachdb/

DECLARE @command NVARCHAR(MAX),
        @replace_character NCHAR(1),
        @db NVARCHAR(300),
        @sql NVARCHAR(MAX);

SET @replace_character = N'?';
SET @command = N'USE [?];
INSERT INTO #IndexUsage
SELECT 
	DatabaseName=DB_NAME(),
	TableName = OBJECT_NAME(s.[OBJECT_ID]), 
	IndexName = i.name, 
	s.index_id,
	i.type,
	i.is_primary_key,
	i.is_unique_constraint,
	s.last_user_seek, 
	s.user_seeks, 
	CASE s.user_seeks WHEN 0 THEN 0 
	ELSE s.user_seeks*1.0 /(s.user_scans + s.user_seeks) * 100.0 END AS SeekPercentage, 
	s.last_user_scan, 
	s.user_scans, 
	CASE s.user_scans WHEN 0 THEN 0 
	ELSE s.user_scans*1.0 /(s.user_scans + s.user_seeks) * 100.0 END AS ScanPercentage, 
	s.last_user_lookup, 
	s.user_lookups, 
	s.last_user_update, 
	s.user_updates, 
	s.last_system_seek, 
	s.last_system_scan, 
	s.last_system_lookup, 
	s.last_system_update
FROM sys.dm_db_index_usage_stats s 
	INNER JOIN sys.indexes i 
ON 
	s.[OBJECT_ID] = i.[OBJECT_ID] 
	AND s.index_id = i.index_id 
WHERE 
	s.database_id = DB_ID() 
	AND OBJECTPROPERTY(s.[OBJECT_ID], ''IsMsShipped'') = 0 
ORDER BY s.user_seeks DESC';

CREATE TABLE #x(db NVARCHAR(300));

INSERT #x
SELECT name
FROM sys.databases 
WHERE database_id NOT IN (1,2,3,4)
	AND state_desc = 'ONLINE'
        AND [name] != 'pubs'
        AND [name] != 'Northwind'
        AND [name] != 'distribution'
        AND [name] NOT LIKE 'ReportServer%'
        AND [name] NOT LIKE 'Adventure%'
ORDER BY database_id;

DECLARE c CURSOR 
	LOCAL FORWARD_ONLY STATIC READ_ONLY FOR 

	SELECT db
	FROM #x;

OPEN c;

FETCH NEXT FROM c INTO @db;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = REPLACE(@command, @replace_character, @db);

    EXEC sp_executesql @sql;

    FETCH NEXT FROM c INTO @db;
END

CLOSE c;
DEALLOCATE c;

DROP TABLE #x;
GO

SELECT '-- SQLskills_IndexUsageForObject'

SELECT *
FROM #IndexUsage
ORDER BY is_primary_key, 
         user_scans+user_seeks+user_lookups/ISNULL(NULLIF(user_updates, 0), 1) ASC, 
         user_updates DESC

DROP TABLE #IndexUsage