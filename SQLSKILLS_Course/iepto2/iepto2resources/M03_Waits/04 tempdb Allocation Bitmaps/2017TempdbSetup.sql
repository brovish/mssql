/*============================================================================
  File:     TempdbSetup.sql

  Summary:  Create some nasty tempdb waits

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

/*
-- Make sure extra tempdb files are removed
USE [tempdb];
GO
DBCC SHRINKFILE (N'Tempdb2', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb2];
GO
DBCC SHRINKFILE (N'Tempdb3', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb3];
GO
DBCC SHRINKFILE (N'Tempdb4', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb4];
GO
DBCC SHRINKFILE (N'Tempdb5', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb5];
GO
DBCC SHRINKFILE (N'Tempdb6', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb6];
GO
DBCC SHRINKFILE (N'Tempdb7', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb7];
GO
DBCC SHRINKFILE (N'Tempdb8', EMPTYFILE);
ALTER DATABASE [tempdb] REMOVE FILE [Tempdb8];
GO

SELECT * FROM tempdb.sys.database_files;
*/

SET NOCOUNT ON;
GO

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

-- In PerfMon, add Databases: Transactions/Sec for tempdb

-- Start 100 clients in batches of 50

SELECT [resource_description], * FROM sys.dm_os_waiting_tasks;
GO

-- Look at PerfMon

-- Stop the test

-- You do not have to stop a real workload to add tempdb data
-- files. My workload creates tables and then truncates/fills
-- over and over, so adding another file doesn't help until the
-- workload restarts. Your workload may be similar...

-- Try adding another file, same size as existing file
ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb2],
    FILENAME = N'C:\SQLskills\2017tempdb2.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO

-- Recreate the table
USE [TempdbTest];
GO

CREATE TABLE [SampleTable] ([c1] INT IDENTITY);
GO

INSERT INTO [SampleTable] DEFAULT VALUES;
GO 50

-- Restart the test

-- Look at PerfMon

SELECT [resource_description], * FROM sys.dm_os_waiting_tasks;
GO

-- Stop the test

-- Now add six more files, same sizes as existing files
ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb3],
    FILENAME = N'C:\SQLskills\2017tempdb3.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO
ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb4],
    FILENAME = N'C:\SQLskills\2017tempdb4.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO

ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb5],
    FILENAME = N'C:\SQLskills\2017tempdb5.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO
ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb6],
    FILENAME = N'C:\SQLskills\2017tempdb6.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO

ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb7],
    FILENAME = N'C:\SQLskills\2017tempdb7.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO
ALTER DATABASE [tempdb]
ADD FILE 
(
    NAME = [Tempdb8],
    FILENAME = N'C:\SQLskills\2017tempdb8.ndf',
    SIZE = 25MB,
    FILEGROWTH = 5MB
);
GO

-- Recreate the table
USE [TempdbTest];
GO

CREATE TABLE [SampleTable] ([c1] INT IDENTITY);
GO

INSERT INTO [SampleTable] DEFAULT VALUES;
GO 50

-- Restart the test

-- Look at PerfMon

SELECT [resource_description], * FROM sys.dm_os_waiting_tasks;
GO

-- Stop the test
