/*============================================================================
  File:     IsolateWithPartitioning_ONLINE.sql

  Summary:  How about Partitioning an object for better control...
  
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
go

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition1];
go

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition1'
	, FILENAME = N'D:\SQLskills\SalesDBSalesDataPartition1.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition1];
GO
PRINT 'Created SalesDBSalesDataPartition1'
GO

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition2];
go

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition2'
	, FILENAME = N'D:\SQLskills\SalesDBSalesDataPartition2.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition2];
GO
PRINT 'Created SalesDBSalesDataPartition2'
GO

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition3];
go

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition3'
	, FILENAME = N'D:\SQLskills\SalesDBSalesDataPartition3.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition3];
GO
PRINT 'Created SalesDBSalesDataPartition3'
GO

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition4];
go

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition4'
	, FILENAME = N'D:\SQLskills\SalesDBSalesDataPartition4.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition4]
GO
PRINT 'Created SalesDBSalesDataPartition4'
GO

sp_helpfile
go

----------------------------------------------------------------------------------------------
----------------------------- File Setup complete -------------------------------------------- 
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
------------------------------ Partition Function --------------------------------------------
----------------------------------------------------------------------------------------------

CREATE PARTITION FUNCTION Sales4Partitions_PFN(int)
AS 
RANGE RIGHT FOR VALUES (2000000,		-- 2 million
						4000000,		-- 4 million
						6000000)		-- 6 million
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Scheme ----------------------------------------------
----------------------------------------------------------------------------------------------
CREATE PARTITION SCHEME [Sales4Partitions_PS]
AS 
PARTITION [Sales4Partitions_PFN] TO 
		(SalesDBSalesDataPartition1, SalesDBSalesDataPartition2, 
		SalesDBSalesDataPartition3, SalesDBSalesDataPartition4 )
GO

----------------------------------------------------------------------------------------------
------------------------------ MOVE to a Partitioned Table -----------------------------------
----------------------------------------------------------------------------------------------

sp_helpindex [Sales]
go

-- Re-creating the PK on a scheme
-- moves the table even though the CL 
-- index was created with a PK...
-- this (originally) took me some TIME
-- to figure out...

-- note - the data is moving... this might take
-- a bit of time?
CREATE UNIQUE CLUSTERED INDEX [SalesPK]
ON [dbo].[Sales] ([SalesID])
WITH (DROP_EXISTING = ON, ONLINE = ON)
ON [Sales4Partitions_PS]([SalesID]);
GO

sp_helpindex [Sales]
go

-- What about another NC index?
-- create index test on sales (SalesPersonID)
CREATE INDEX [test] 
ON [dbo].[Sales] ([SalesPersonID])
--ON [Sales4Partitions_PS](SalesID)

sp_helpindex [Sales]
go

-- YES - if it's a non-unique nonclustered index it
-- is AUTOMATICALLY aligned with the base table!

-- Unaligned?
--CREATE INDEX [test2] 
--ON [dbo].[Sales] ([SalesPersonID])
--ON [PRIMARY];
go

-- SCENARIO what if - Partitioning by date...
--CREATE UNIQUE INDEX [SalesID]
--ON [dbo].[Sales] ([SalesID], DATE)
--ON [Sales4Partitions_PS]([SalesID]);
GO
----------------------------------------------------------------------------------------------
------------------------------ Backup for later recovery -------------------------------------
----------------------------------------------------------------------------------------------

USE [msdb];
go

EXEC sp_delete_database_backuphistory 'SalesDB'
go

USE [master];
go

BACKUP DATABASE [SalesDB] 
	TO DISK = N'D:\SQLskills\SalesDBBackup.bak'
	WITH NAME = N'Full Database Backup'
	    , DESCRIPTION = 'Starting point for recovery'
		, INIT
		, STATS = 10;
go