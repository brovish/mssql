USE [CreditPV];
GO

EXEC [sp_helpfile];
GO

-- PART 2: We'll discuss in Partial Database Availability 
--         and Online Piecemeal Restore

----------------------------------------------------------------------------------------------
---------------------------------- Disaster strikes! -----------------------------------------
----------------------------------------------------------------------------------------------

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_dt] BETWEEN '20200701' AND '20200801'
GO


-- Pull out the USB device that has July's data:
SET STATISTICS IO ON;
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_dt] >= '20200914' 
	AND [cpv].[Charge_dt] < '20200915';
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_dt] >= '20200702' 
	AND [cpv].[Charge_dt] < '20200704'; 
GO

SELECT [cpv].*
FROM [dbo].[ChargePV] AS [cpv]
WHERE datename(DW, [cpv].[Charge_dt]) = 'Monday'
GO

-- So far - no problems... SQL Server hasn't even 
-- noticed that the drive has been removed...

-- Why?    The data's in cache!

-- We can even modify data:

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_no] = 146551 AND
    [cpv].[Charge_dt] BETWEEN '20200701' AND '20200801';
GO

UPDATE [dbo].[Charges202007]
SET [charge_amt] = 7890
WHERE [charge_no] = 146551 
    AND [Charge_dt] = '20200712 10:45:23.027';
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_no] = 146551 
AND [cpv].[Charge_dt] BETWEEN '20200701' AND '20200801';
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_dt] BETWEEN '20200701' AND '20200801';
GO

-- Let's check state first:
SELECT [file_id]
    , [name]
    , [physical_name]
    , [state_desc] 
FROM [sys].[database_files];
GO

CHECKPOINT;
GO

ALTER DATABASE [CreditPV]
	MODIFY FILE (NAME = N'CreditPVFGFile2', OFFLINE);
GO

-- Unfortunately, the view won't work for ANY data:
SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_dt] >= '20200914' 
	AND [cpv].[Charge_dt] < '20200915';
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[Charge_dt] >= '20200702' 
	AND [cpv].[Charge_dt] < '20200704'; 
GO

-- One option would be to temporarily disable this data
-- in the view
ALTER VIEW [dbo].[ChargePV]
AS
SELECT * FROM [dbo].[charges202006]
UNION ALL
--SELECT * FROM [dbo].[charges202007]
--UNION ALL
SELECT * FROM [dbo].[charges202008]
UNION ALL
SELECT * FROM [dbo].[charges202009];
GO

----------------------------------------------------------------------------------------------
------------------------------ Restore the file ----------------------------------------------
----------------------------------------------------------------------------------------------

USE [Master];
GO

RESTORE DATABASE [CreditPV]
	FILE = N'CreditPVFGFile2'
FROM DISK = N'D:\SQLskills\Demos\CreditPV.bak' 
WITH FILE = 1, 
	MOVE N'CreditPVFGFile2' TO N'D:\SQLskills\CreditPVFGFile2.ndf',
	NORECOVERY;
GO

-- Let's check state first:
USE [CreditPV];
GO

SELECT [file_id]
    , [name]
    , [physical_name]
    , [state_desc] 
FROM [sys].[database_files];
GO

-- We must backup the tail first and then we can start our
-- restore sequence - while the database is COMPLETELY offline
BACKUP LOG [CreditPV]
	TO DISK = N'D:\SQLskills\Demos\CreditPVLOG.bak' 
	WITH INIT, NO_TRUNCATE;
GO

-- Next, we can restore the piece that's damaged.
-- This will reduce our total amount of downtime.
USE [master];
GO

-- Now restore the tail
RESTORE LOG [CreditPV]
FROM DISK = N'D:\SQLskills\Demos\CreditPVLOG.bak' 
	WITH FILE = 1, RECOVERY;
GO

-- Now, everyone can get back in!
USE [CreditPV];
GO

ALTER VIEW [dbo].[ChargePV]
AS
SELECT * 
FROM [dbo].[charges202006]
UNION ALL
SELECT * 
FROM [dbo].[charges202007]
UNION ALL
SELECT * 
FROM [dbo].[charges202008]
UNION ALL
SELECT * 
FROM [dbo].[charges202009];
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt]
    BETWEEN '20200701' AND '20200801';
GO
