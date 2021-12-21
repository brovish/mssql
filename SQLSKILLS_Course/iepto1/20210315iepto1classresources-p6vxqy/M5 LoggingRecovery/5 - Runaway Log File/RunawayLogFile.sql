/*============================================================================
  File:     RunawayLogFile.sql

  Summary:  This script shows how a transaction
		log can grow out of control if it is mis-managed

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [master];
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company];
END
GO

CREATE DATABASE [Company] ON PRIMARY (
    NAME = N'Company_data',
    FILENAME = N'D:\SQLskills\Company_data.mdf',
	SIZE = 3MB,
	FILEGROWTH = 512KB)
LOG ON (
    NAME = N'Company_log',
    FILENAME = N'D:\SQLskills\Company_log.ldf',
    SIZE = 1MB,
    FILEGROWTH = 256KB);
GO
USE [Company];
GO

SET NOCOUNT ON;
GO

-- If using indirect checkpoints by default, execute this to
-- disable them otherwise the demo won't work.
-- It's artificially creating a small log to show the effect
-- of log clearing on the permon counters.
ALTER DATABASE [Company] SET TARGET_RECOVERY_TIME = 0 SECONDS;
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE [BigRows] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO

-- Make sure the database is in FULL
-- recovery model
ALTER DATABASE [Company] SET RECOVERY FULL;
GO

-- In another window, run LoopInserts.sql

-- Go to perfmon and monitor the log with log size,
-- log size used, percent log used
-- Set scale for size and used size to 0.01

-- Watch the saw-tooth - even though we're in
-- FULL recovery mode, the log is being cleared
-- We're actually in pseudo-simple until a full
-- database backup is taken

BACKUP DATABASE [Company] TO
	DISK = N'C:\SQLskills\Company.bck'
	WITH INIT, STATS;
GO

-- Now the log is out of control...
-- Change comment out the  waitfor and set the
-- counters to 0.0001

-- Log size is hundreds of MB!

-- What's causing the log to not be cleared?
SELECT [log_reuse_wait_desc]
	FROM [master].[sys].[databases]
	WHERE [name] = N'Company';
GO

-- So let's do one
BACKUP LOG [Company] TO
	DISK = N'C:\SQLskills\Company_log.bck'
	WITH INIT, STATS;
GO

-- And another one
BACKUP LOG [Company] TO
	DISK = N'C:\SQLskills\Company_log.bck'
	WITH STATS;
GO

-- Note counters.....