/*============================================================================
  File:     SalesDB-QueryDamageAccessRepair.sql

  Summary:  Accessing databases that are partially damaged and repairing them
			ONLINE!

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

USE [SalesDB];
GO

----------------------------------------------------------------------------------------------
------------------------------ Access Data - Query -------------------------------------------
----------------------------------------------------------------------------------------------
-- Show data access...
-- Partition1
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] < 2000000;
GO

-- Partition2
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 2000000 
        AND [s].[SalesID] < 4000000;
GO

-- Partition3
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 4000000 
        AND [s].[SalesID] < 6000000;
GO

-- Partition4
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 6000000 
        AND [s].[SalesID] < 8000000;
GO

----------------------------------------------------------------------------------------------
------------------------------ Damage and Access Data ----------------------------------------
----------------------------------------------------------------------------------------------
-- Now - damage the harddrive by removing the USB Key

-- Partition1
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] < 2000000;
GO

-- Partition2
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 2000000 
        AND [s].[SalesID] < 4000000;
GO

-- Partition3
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 4000000 
        AND [s].[SalesID] < 6000000;
GO

-- Partition4
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 6000000 
        AND [s].[SalesID] < 8000000;
GO

-- Why aren't my queries failing? 
-- Remember, SQL Server **ALWAYS** goes to MEMORY first.
-- If it finds the data necessary, then it returns that data from memory. What will 
-- cause us to be aware of the problem? A write to that portion of the database?
-- Right?

UPDATE [dbo].[Sales]
	SET   [SalesPersonID]	= 2
		, [CustomerID]	    = 2
		, [ProductID]		= 2
		, [Quantity]		= 2
	WHERE SalesID = 2000004;
GO










-- NOPE, even that hasn't failed.....
-- Hmmmm, what's going on????















CHECKPOINT

-- OK, CHECKPOINT generates:
-- Msg 823, Level 24, State 3, Line 1
-- The operating system returned error 1006(The volume 
-- for a file has been externally altered so that 
-- the opened file is no longer valid.) to SQL Server 
-- during a write at offset 0x00000000026000 in file 
-- 'F:\SalesDBSalesDataPartition2.ndf'. Additional 
-- messages in the SQL Server error log and system event 
-- log may provide more detail. This is a severe 
-- system-level error condition that threatens database 
-- integrity and must be corrected immediately. Complete 
-- a full database consistency check (DBCC CHECKDB). 
-- This error can be caused by many factors; for more 
-- information, see SQL Server Books Online.

----------------------------------------------------------------------------
-- Ironically (or is it?) queries STILL work!
-- Partition2
USE [SalesDB];
GO

SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 2000000 
        AND [s].[SalesID] < 4000000;
GO

-- Notice that the information is correct for SalesID 2,000,002

-- And, we could still update other records (as long as they are in cache)

UPDATE [dbo].[Sales]
	SET   [SalesPersonID]	= 6
		, [CustomerID]	    = 6
		, [ProductID]		= 6
		, [Quantity]		= 6
	WHERE SalesID = 2000006;
GO

-- What happens if we lose the cache?
DBCC DROPCLEANBUFFERS;
GO

-- Partition1
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] < 2000000;
GO

-- Partition2
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 2000000 
        AND [s].[SalesID] < 4000000;
GO

-- Partition3
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 4000000 
        AND [s].[SalesID] < 6000000;
GO

-- Partition4
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 6000000 
        AND [s].[SalesID] < 8000000;
GO

----------------------------------------------------------------------------------------------
------------------------------ Repair Database -----------------------------------------------
----------------------------------------------------------------------------------------------

-- So, unless you clear the cache, the database seems somewhat unaffected except for 
-- checkpoint (to that portion of the database, etc.). But we definitely need to recover. 
-- Turns out that a full database backup was done at the end of the setup script (and 
-- the assumption is that you would have a regular backup strategy in place.....?). 
-- So how about we recovery and restore the damaged file from our backup(s)!

USE [master];
GO

ALTER DATABASE [SalesDB]
	MODIFY FILE (NAME = N'SalesDBSalesDataPartition2'
	    , OFFLINE);
GO
-- Potentially returns TWO messages. 
-- One to disconnect users (IF any are connected) to validate 
-- database state (they can almost immediatelly reconnect)
-- The other is again a disk error (because they couldn't contact
-- the file when taking it offline). This is not a problem 
-- as we're going to restore.

USE [SalesDB];
GO

SELECT [file_id], [name], [physical_name], [state_desc]
FROM [sys].[database_files];
GO

----------------------------------------------------------------------------------------------
------------------------------ Access Data - Query -------------------------------------------
----------------------------------------------------------------------------------------------
-- Partition1
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] < 2000000;
GO

-- Partition2
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 2000000 
        AND [s].[SalesID] < 4000000;
GO
-- Msg 679, Level 16, State 1, Line 2
-- One of the partitions of index 'SalesPK' for 
-- table 'dbo.Sales'(partition ID 72057594039828480) 
-- resides on a filegroup that cannot be accessed 
-- because it is offline, restoring, or defunct. 
-- This may limit the query result.


-- Partition3
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 4000000 
        AND [s].[SalesID] < 6000000;
GO

-- Partition4
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 6000000 
        AND [s].[SalesID] < 8000000;
GO

----------------------------------------------------------------------------------------------
------------------------------ Restore Damaged FILE from Backup ------------------------------
----------------------------------------------------------------------------------------------
USE [master];
GO

RESTORE DATABASE [SalesDB]
	FILE = N'SalesDBSalesDataPartition2'
	--, FILE = N'SalesDBSalesDataPartition1'
FROM DISK = N'D:\SQLskills\SalesDBBackup.bak' 
WITH FILE = 1, 
	MOVE N'SalesDBSalesDataPartition2' 
		TO N'H:\SalesDBSalesDataPartition2.ndf'
	--, MOVE N'SalesDBSalesDataPartition1' 
	--	TO N'D:\sqlskills\SalesDBSalesDataPartition1.ndf'
	, RECOVERY, STATS = 10
	-- Note: NORECOVERY should be your default but even if you
	-- state recovery, this cannot be recovered (STATE: recovery_pending)
	-- Message returned: The roll forward start point is now at log sequence number (LSN) 561000003706600001. Additional roll forward past LSN 568000001926900001 is required to complete the restore sequence.
go

----------------------------------------------------------------------------------------------
------------------------------ Backup the Tail -----------------------------------------------
----------------------------------------------------------------------------------------------
-- You must backup the tail of the log AFTER the file has been taken offline
-- otherwise the sync lsn will not match and you won't be able to bring the file
-- back online!

USE [master];
GO

BACKUP LOG [SalesDB]
	TO DISK = N'D:\SQLskills\SalesDBBackup.bak' 
	WITH NOINIT, COPY_ONLY, STATS = 10
GO

USE [SalesDB];
GO

SELECT [file_id], [name], [physical_name], [state_desc]
FROM [sys].[database_files];
GO

USE [master];
GO

--RESTORE HEADERONLY
--FROM DISK = N'D:\SQLskills\SalesDBBackup.bak' 
-- Now restore the tail
RESTORE LOG [SalesDB]
	FROM DISK = N'D:\SQLskills\SalesDBBackup.bak' 
	WITH FILE = 2, NORECOVERY, STATS = 10;
GO

-- Here you can use NORECOVERY and then just recover the
-- database with a separate statement:

USE [SalesDB];
GO

SELECT [file_id], [name], [physical_name], [state_desc]
FROM [sys].[database_files];
GO

USE [master];
GO

RESTORE DATABASE [SalesDB] WITH RECOVERY;
GO


----------------------------------------------------------------------------------------------
------------------------------ Access Data - Query -------------------------------------------
----------------------------------------------------------------------------------------------
USE [SalesDB];
GO

-- Partition1
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] < 2000000;
GO

-- Partition2
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 2000000 
        AND [s].[SalesID] < 4000000;
GO

-- Partition3
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 4000000 
        AND [s].[SalesID] < 6000000;
GO

-- Partition4
SELECT TOP 100 [s].* 
FROM [dbo].[Sales] AS [s]
	WHERE [s].[SalesID] >= 6000000 
        AND [s].[SalesID] < 8000000;
GO
