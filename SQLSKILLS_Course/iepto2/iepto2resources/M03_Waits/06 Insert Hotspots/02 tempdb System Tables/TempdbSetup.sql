/*============================================================================
  File:     TempdbSetup.sql

  Summary:  Create tempdb system table contention

  SQL Server Versions: 2019 onwards
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

IF DATABASEPROPERTYEX (N'TempdbTest', N'Version') > 0
BEGIN
	ALTER DATABASE [TempdbTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [TempdbTest];
END
GO

CREATE DATABASE [TempdbTest];
GO

USE [TempdbTest];
GO

CREATE TABLE [SampleTable] ([c1] INT IDENTITY);
GO

INSERT INTO [SampleTable] DEFAULT VALUES;
GO 50

CREATE OR ALTER PROCEDURE dbo.TempdbWorkload AS 
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #DummyTable ([c1] INT NOT NULL );

	INSERT INTO #DummyTable
		SELECT * FROM [TempdbTest].[dbo].[SampleTable];
END
GO

-- Start 50 clients

-- Look at waiting tasks

DBCC TRACEON (3604);
GO
DBCC PAGE ([tempdb], x, x, 0);
GO

SELECT [object_id], [name] FROM tempdb.sys.objects;
GO

-- Now enable in-memory system tables and reboot
SELECT SERVERPROPERTY ('IsTempdbMetadataMemoryOptimized');
GO

ALTER SERVER CONFIGURATION
	SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
GO

ALTER SERVER CONFIGURATION
	SET MEMORY_OPTIMIZED TEMPDB_METADATA = OFF;
GO