/*============================================================================
  File:     DropTableAndRecoverToPointInTime.sql

  Summary:  How do you recover from a dropped database?
  
  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by SQLskills.com

  (c) SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE msdb
go

EXEC sp_delete_database_backuphistory 'SalesDB'
go

USE master
go

BACKUP DATABASE SalesDB 
	TO DISK = N'C:\SQLskills\SalesDBBackup.bak'
	WITH NAME = N'Full Database Backup', DESCRIPTION = 'Starting point for recovery',
		INIT, STATS = 10
go

USE SalesDB
go

SELECT count(*) 
FROM Sales -- 6719482
go

--------- Run the damaging batch --------- 
SELECT getdate() -- 2007-06-06 15:42:44.670
go

WAITFOR DELAY '00:00:02'
go

DROP TABLE Sales
go
--------- Run the damaging batch --------- 

sp_helpfile
go

-- First - Contain the problem... Since the database has ONLY a single mdf and single ldf, 
-- you have only one option - set the database to restricted user mode (effectively taking 
-- the DB offline BUT, don't take it completely offline as you won't be able to access the
-- log, etc.).

USE master
go

ALTER DATABASE SalesDB
	SET RESTRICTED_USER
	WITH ROLLBACK IMMEDIATE 
go

-- This terminates all connections (as expected)... 
-- Now that we're effectively down - what can we do?

BACKUP LOG SalesDB 
	TO DISK = N'C:\SQLskills\SalesDBBackup.bak'
	WITH NAME = N'Transaction Log Backup'
	, DESCRIPTION = 'Getting everything to current point in time.', 
		STATS = 10
go

-- What do we have?

RESTORE HEADERONLY 
FROM DISK = N'C:\SQLskills\SalesDBBackup.bak'
go

USE master
go

RESTORE DATABASE SalesDB
FROM DISK = N'C:\SQLskills\SalesDBBackup.bak'
WITH NORECOVERY, RESTRICTED_USER
go

RESTORE LOG SalesDB
FROM DISK = N'C:\SQLskills\SalesDBBackup.bak'
WITH FILE = 2, RESTRICTED_USER, 
STOPAT = '2007-11-15 10:59:32.153', RECOVERY
-- use a "known good" point in time
go

-- Have we lost data... probably. We don't really know the EXACT 
-- point in time when the DROP occurred v. the VERY LAST insert.
-- As a result, we're CLOSE but close doesn't really cut it!
USE SalesDB
go

SELECT max(SalesID) 
FROM Sales -- 6739419  --there could be more but we don't know it!
go

-- You might start wondering how many more?? 
-- And, there's no way to really know!

-- Create a snapshot of the restored point:
sp_helpfile
go

CREATE DATABASE SalesDB_RestorePointSnapshot
ON
( NAME = N'SalesDBData', 
  FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\SalesDBData_RestorePontSnapshot.mdf_snap')
AS SNAPSHOT OF [SalesDB]

-- BUT - downtime is really VERY critical here... 
-- So, let's set a gap and then let users back in.

DBCC CHECKIDENT ('Sales')  -- the number of rows we have...
GO

-- Create a gap so that we can let users back in...
DBCC CHECKIDENT ('Sales', RESEED, 6800000)
go

USE master
go

ALTER DATABASE SalesDB
	SET MULTI_USER
--	WITH ROLLBACK IMMEDIATE 
go

-- So, we did have data loss because we didn't know for sure what the time of the disaster was?
-- could we have gotten any closer? If you know RELATIVELY close to the time of the disaster you
-- can restore with standby and investigate the state of the database as you restore only seconds
-- at a time. This is a bit tedious... but it is free AND currently, there are no transaction log
-- readers for SQL Server 2005. So, for 2005 the third party tools have not yet caught up (give em
-- time).

-- Could restore to an alternate location and then investigate through
-- STANDBY and STOPAT options.

-- Can start with a range from the start of the prior backup to
-- the end of the tail backup. Get this from MSDB.

SELECT 	[Name],
	Backup_Start_Date, 
	Backup_Finish_Date, 
	[Description],
	First_LSN, 
	Last_LSN, 
	* -- get all of the columns
FROM msdb.dbo.backupset AS s
    JOIN msdb.dbo.backupmediafamily AS m
        ON s.media_set_id = m.media_set_id
WHERE database_name = 'SalesDB'
ORDER BY 1 ASC
go

-- Start Date of (prior) Backup: what's the time?
-- End Date of last transaction log: what's the time?

USE master
go

RESTORE DATABASE [SalesDB_Investigate] 
FROM DISK = N'C:\SQLskills\SalesDBBackup.bak' 
WITH FILE = 1,  
	MOVE N'SalesDBData' TO N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\SalesDBData_Investigate.mdf',  
	MOVE N'SalesDBLog' TO N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\SalesDBLog_Investigate.ldf',  
	STANDBY = N'C:\SQLskills\SalesDB_UNDO.bak',
	STOPAT = '2007-11-15 10:59:32.153', STATS
GO

-- Get details on the transaction log before you restore?
RESTORE LOG [SalesDB_Investigate] 
FROM DISK = N'C:\SQLskills\SalesDBBackup.bak' 
WITH FILE = 2,
	STANDBY = N'C:\SQLskills\SalesDB_UNDO.bak',
	STOPAT = '2007-11-15 10:59:32.153', STATS
GO

USE [SalesDB_Investigate]
go

SELECT max(SalesID) 
FROM Sales  -- 6739419  -- matches the restored database...
go

USE master
go

-- Now, inch forward to see what rows there are... move VERY slowly because
-- if you go to far, you'll have to start over.
RESTORE LOG [SalesDB_Investigate] 
FROM DISK = N'C:\SQLskills\SalesDBBackup.bak' 
WITH FILE = 2,
	STANDBY = N'C:\SQLskills\SalesDB_UNDO.bak',
	STOPAT = '2007-11-15 10:59:33.153', STATS
GO

SELECT max(SalesID) 
FROM SalesDB_Investigate.dbo.Sales  -- 6739461  -- and now we know... we did miss a few rows.
go

SELECT max(SalesID) 
FROM SalesDB_RestorePointSnapshot.dbo.Sales  -- 6739419  --and now we know... we did miss a few rows.
go

-- Keep iterating through the sets of data and then to recover your
-- "LOST" data, you can INSERT/SELECT the date over from the 
-- "investigate" to the actual db...

-- What does the gap look like in the "current and active" database

SELECT *
	FROM [SalesDB_investigate].dbo.Sales AS R
WHERE R.SalesID > 6739419 -- the highest value before the gap in SalesDB

-- How can we recover the few rows that we do have?
SET IDENTITY_INSERT SalesDB.dbo.Sales ON
go

INSERT SalesDB.dbo.Sales
		( SalesID
		, SalesPersonID
		, CustomerID
		, ProductID
		, Quantity)
SELECT *
	FROM [SalesDB_Investigate].dbo.Sales AS R
WHERE R.SalesID > 6739419
go

-- For more complex comparisons (inserts/updates/deletes) consider using the snapshot
-- created of the production database at the restore point and then use tablediff
-- to compare the production database with the database that you're slowly rolling
-- forward.

!!"C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver (local)\sqldev01 -sourcedatabase SalesDB_Investigate -sourcetable Sales -destinationserver (local)\sqldev01 -destinationdatabase SalesDB_RestorePointSnapshot -destinationtable Sales -c -o c:\SQLskills\SalesDiffOverview.sql -f c:\SQLskills\SalesDiffScript.sql

-- next - open the .sql script to review an "overview of the differences" AND to 
-- find out the name of the diff file (the -f parameter).
-- Then, modify it for whatever you're interested in (or not!)...
-- and now you have all inserts/updates and deletes for this table!

------------------------------------------------------------------------------
-- Create a temp table to store the commands to execute

-- NOTE: Be sure to modify the dynamic string for the type of command you
-- want to generate!
------------------------------------------------------------------------------

USE JunkDB --don't forget to modify the string in line:289
go
CREATE TABLE ExecuteDifferences
(
	DiffID		int				identity,
	DiffExec	nvarchar(4000)
)
go

------------------------------------------------------------------------------
-- Create SQLCMD variables to help simplify the command build
------------------------------------------------------------------------------
:SETVAR SourceServer (local)\SQLDev01
:SETVAR SourceDatabase SalesDB_Investigate

:SETVAR DestinationServer (local)\SQLDev01
:SETVAR DestinationDatabase SalesDB_RestorePointSnapshot

DECLARE @CurrentName sysname, @ExecStr nvarchar(4000)
SELECT @CurrentName = (SELECT min(name) FROM sys.tables WHERE name NOT IN ('sysdiagrams', 'ExecuteDifferences'))

WHILE @CurrentName <= (SELECT max(name) FROM sys.tables WHERE name NOT IN ('sysdiagrams', 'ExecuteDifferences')) 
BEGIN
	SELECT @ExecStr = 'INSERT JunkDB.dbo.ExecuteDifferences (DiffExec) VALUES (''!!"c:\program files\microsoft sql server\90\com\tablediff.exe" -sourceserver $(SourceServer) -sourcedatabase $(SourceDatabase) -sourcetable ' + @CurrentName + ' -destinationserver $(DestinationServer) -destinationdatabase $(DestinationDatabase) -destinationtable ' + @CurrentName + ' -c -dt ' + @CurrentName + '_Diffs -f c:\SQLskills\' + @CurrentName + '_Diffs.sql'')'
	--SELECT @ExecStr
	EXEC (@ExecStr)
	SELECT @CurrentName = (SELECT min(name) FROM sys.tables WHERE name NOT IN ('sysdiagrams', 'ExecuteDifferences') AND name > @CurrentName)
END
go

SELECT * FROM JunkDB.dbo.ExecuteDifferences
go