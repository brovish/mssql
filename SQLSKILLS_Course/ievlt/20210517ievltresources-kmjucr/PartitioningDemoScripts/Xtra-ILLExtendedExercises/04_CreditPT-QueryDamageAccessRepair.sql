/*============================================================================
  File:     CreditPT-QueryDamageAccessRepair.sql

  Summary:  This script will show you how to recover a partially damaged 
			database using online piecemeal restore. Please review the 
			CreditPT-Setup.sql script first in order to setup and 
			configure for this scenario.

 SQL Server Version: 2008+ (script updated for SQL 2014)
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com
  All rights reserved.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills.com  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [CreditPT];
GO

----------------------------------------------------------------------------------------------
------------------------------ Access Data - Query -------------------------------------------
----------------------------------------------------------------------------------------------
-- Show data access...
-- June 2020
SELECT TOP 100 * 
FROM [dbo].[ChargesPT] 
WHERE [Charge_dt] >= '20200601'
go

-- July 2014
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200701'
go
-- Aug 2014
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200801'
go
-- Sep 2014
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200901'
go

--SELECT * FROM ChargesPT
--WHERE [Charge_dt] >= '20200914 10:50:02' AND [Charge_dt] < '20200915 10:50:05' 
-- 13424 rows

----------------------------------------------------------------------------------------------
------------------------------ Damage and Access Data ----------------------------------------
----------------------------------------------------------------------------------------------
-- Now - damage the harddrive......
-- First, I'll remove the USB Key

-- June 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200601'
go
-- July 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200701'
go
-- Aug 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200801'
go
-- Sep 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200901'
go

-- Why aren't my queries failing? 
-- Remember, SQL Server **ALWAYS** goes to MEMORY first.
-- If it finds the data necessary, then it returns that data from memory. What will 
-- cause us to be aware of the problem? A write to that portion of the database?
-- Right?

UPDATE [ChargesPT]
	SET [provider_no] = 123 
        , [category_no] = 7
	WHERE [charge_no] = 202324
go










-- NOPE, even that hasn't failed.....
-- Hmmmm, what's going on????















CHECKPOINT

-- OK, CHECKPOINT generates:
-- Msg 823, Level 24, State 3, Line 1
-- The operating system has reported I/O error 1006(The volume for a file 
-- has been externally altered so that the opened file is no longer valid.) 
-- to the SQL Server process during a write at offset 0x0000000000c000 in 
-- file 'DRIVE\LOCATION'. Additional messages in 
-- the SQL Server error log and system event log may provide more detail. 
-- This is a severe system-level error condition that threatens database 
-- integrity and must be corrected immediately. Complete a full database 
-- consistency check (DBCC CHECKDB). This error can be caused by many 
-- factors; for more information, see SQL Server Books Online.

----------------------------------------------------------------------------
-- Ironically (or is it?) queries STILL work!
-- July 2020
SELECT TOP 100 * 
FROM [dbo].[ChargesPT] 
WHERE [Charge_dt] >= '20200701'
go
-- Notice that the provider_no for charge_no 611015 is correct at 111!!!!

----------------------------------------------------------------------------------------------
------------------------------ Repair Database -----------------------------------------------
----------------------------------------------------------------------------------------------

-- So, the database seems somewhat unaffected except for checkpoint (to that portion
-- of the database, etc.). But we definitely need to recover. Turns out that a full 
-- database backup was done at the end of the setup script (and the assumption is that
-- you would have a regular backup strategy in place.....?). So how about we recovery
-- and restore the damaged file from our backup(s)!

-- Reviewing system tables to see filenames, paths, etc.
USE [CreditPT]
go

SELECT * FROM [sys].[filegroups];
SELECT * FROM [sys].[database_files]; -- looking for STATE
go

-- Since this file is only showing more of a "soft error" rather 
-- then a hard error, we need to investigate further. BUT - we 
-- already know this is damaged and now we need to take the file 
-- officially offline.

-- Let's check state first:
SELECT [file_id], [name], [physical_name], [state_desc]
FROM [sys].[database_files];
go

ALTER DATABASE [CreditPT]
	MODIFY FILE (NAME = N'CreditPTFG2File1', OFFLINE);
GO

----------------------------------------------------------------------------------------------
------------------------------ Access Data - Query -------------------------------------------
----------------------------------------------------------------------------------------------
-- June 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200601'
go
-- July 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200701'
-- Msg 667, Level 16, State 1, Line 2
-- Index 'ChargesPTPK' for table 'ChargesPT' (RowsetId ....) 
-- resides on a filegroup that cannot be accessed because it is offline, 
-- restoring, or defunct.
go
-- Aug 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200801'
go
-- Sep 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200901'
go

----------------------------------------------------------------------------------------------
------------------------------ Restore Damaged FILE from Backup ------------------------------
----------------------------------------------------------------------------------------------
USE Master
GO

RESTORE DATABASE [CreditPT]
	FILE = N'CreditPTFG2File1'
FROM DISK = N'D:\SQLskills\Demos\CreditPT.bak' 
WITH FILE = 1, 
	MOVE N'CreditPTFG2File1' TO N'D:\SQLskills\Demos\NEWCreditPTFG2File1.ndf', 
	NORECOVERY
go

----------------------------------------------------------------------------------------------
------------------------------ Backup the Tail -----------------------------------------------
----------------------------------------------------------------------------------------------
-- You must backup the tail of the log AFTER the file has been taken offline
-- otherwise the sync lsn will not match and you won't be able to bring the file
-- back online!

BACKUP LOG [CreditPT]
	TO DISK = N'D:\SQLskills\Demos\CreditPTLOG.bak' 
	WITH INIT, NO_TRUNCATE
GO

-- Now restore the tail
USE master
go

RESTORE LOG [CreditPT]
FROM DISK = N'D:\SQLskills\Demos\CreditPTLOG.bak' 
	WITH FILE = 1, RECOVERY
go


----------------------------------------------------------------------------------------------
------------------------------ Access Data - Query -------------------------------------------
----------------------------------------------------------------------------------------------
USE [CreditPT];
go

-- June 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200601';
go
-- July 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200701';
go
-- Aug 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200801';
go
-- Sep 2020
SELECT TOP 100 * 
    FROM [dbo].[ChargesPT] 
	WHERE [Charge_dt] >= '20200901';
go