/*============================================================================
  File:     RestoreSalesDB.sql

  Summary:  Recreate the SalesDB and make sure that no connections exist.
  
  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Copyright (C) Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

SET NOCOUNT ON
go

USE [master];
go

IF DATABASEPROPERTYEX('SalesDB_RestorePointSnapshot', 'Collation') IS NOT NULL
	DROP DATABASE [SalesDB_RestorePointSnapshot];
go

IF DATABASEPROPERTYEX('SalesDB_Snapshot', 'Collation') IS NOT NULL
	DROP DATABASE [SalesDB_Snapshot];
go

IF DATABASEPROPERTYEX('SalesDB', 'Collation') IS NOT NULL
	ALTER DATABASE [SalesDB]
		SET RESTRICTED_USER 
		WITH ROLLBACK IMMEDIATE;
go

-- 2008 Backup so no changes for the restore (named instance: SQLDev01)
--RESTORE DATABASE SalesDB
--	FROM DISK = N'C:\SQLskills\SalesDBOriginal.bak'
--WITH STATS = 10, REPLACE
go

-- 2008R2 Restore (named instance: SQL2008R2Dev01)
--RESTORE DATABASE [SalesDB] 
--    FROM  DISK = N'D:\SQLskills\SalesDBOriginal.bak' 
--    WITH  FILE = 1,  MOVE N'SalesDBData' 
--                TO N'D:\Microsoft SQL Server\MSSQL11.SQL2012DEV01\MSSQL\DATA\SalesDBData.mdf'
--          ,  MOVE N'SalesDBLog' 
--                TO N'D:\Microsoft SQL Server\MSSQL11.SQL2012DEV01\MSSQL\DATA\SalesDBLog.ldf'
--    ,  NOUNLOAD,  STATS = 10, REPLACE
--GO

-- 2014 Restore (named instance: SQL2014)
--RESTORE DATABASE [SalesDB] 
--    FROM  DISK = N'D:\SQLskills\SalesDBOriginal.bak' 
--    WITH  FILE = 1,  MOVE N'SalesDBData' 
--                TO N'D:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\SalesDBData.mdf'
--          ,  MOVE N'SalesDBLog' 
--                TO N'D:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\SalesDBLog.ldf'
--    ,  NOUNLOAD,  STATS = 10, REPLACE
--GO

-- 2019 Restore (named instance: SQL2019Dev)
RESTORE DATABASE [SalesDB] 
    FROM  DISK = N'D:\SQLskills\SalesDBOriginal.bak' 
    WITH  FILE = 1,  MOVE N'SalesDBData' 
                TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019Dev\MSSQL\DATA\SalesDBData.mdf'
          ,  MOVE N'SalesDBLog' 
                TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019Dev\MSSQL\DATA\SalesDBLog.ldf'
    ,  NOUNLOAD,  STATS = 10, REPLACE;
go

------
-- Lots of considerations around restores, CE, Optimizer fixes, testing...
------

-- Finally, after restore - set your compat mode appropriately
-- the restored compat mode will match that of the compat mode 
-- when backed up (*usually* the version it's coming from but
-- it may have been set to an earlier version there so the 
-- restored compat mode will still be that earlier version).

-- Reminder, here are the valid values for Compatibility Level:
--  80	SQL Server 2000
--  90	SQL Server 2005
-- 100	SQL Server 2008 and SQL Server 2008 R2
-- 110	SQL Server 2012
-- 120	SQL Server 2014
-- 130	SQL Server 2016
-- 140	SQL Server 2017
-- 150	SQL Server 2019

ALTER DATABASE [SalesDB]
	SET COMPATIBILITY_LEVEL = 150;
go

-- For 2016+
ALTER DATABASE SCOPED CONFIGURATION 
		SET LEGACY_CARDINALITY_ESTIMATION = ON;
go
