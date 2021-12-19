/*============================================================================
  File:     IsolateWithPartitioning_ONLINE_USB.sql

  Summary:  How about Partitioning an object for better control...
            ** This is the "usb demo" script ** 
  
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

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition1];
GO

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition1'
	, FILENAME = N'H:\SalesDBSalesDataPartition1.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition1];
GO
PRINT 'Created SalesDBSalesDataPartition1';
GO

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition2];
GO

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition2'
	, FILENAME = N'I:\SalesDBSalesDataPartition2.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition2];
GO
PRINT 'Created SalesDBSalesDataPartition2';
GO

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition3];
go

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition3'
	, FILENAME = N'J:\SalesDBSalesDataPartition3.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition3];
GO
PRINT 'Created SalesDBSalesDataPartition3';
GO

ALTER DATABASE [SalesDB] 
ADD FILEGROUP [SalesDBSalesDataPartition4];
GO

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesDataPartition4'
	, FILENAME = N'K:\SalesDBSalesDataPartition4.ndf' 
	, SIZE = 100
	, MAXSIZE = 120
	, FILEGROWTH = 10)
TO FILEGROUP [SalesDBSalesDataPartition4];
GO
PRINT 'Created SalesDBSalesDataPartition4';
GO

EXEC sp_helpfile;
GO

----------------------------------------------------------------------------------------------
----------------------------- File Setup complete -------------------------------------------- 
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
------------------------------ Partition Function --------------------------------------------
----------------------------------------------------------------------------------------------

CREATE PARTITION FUNCTION [Sales4Partitions_PFN](int)
AS 
RANGE RIGHT FOR VALUES (2000000,		-- 2 million
						4000000,		-- 4 million
						6000000);		-- 6 million
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Scheme ----------------------------------------------
----------------------------------------------------------------------------------------------
CREATE PARTITION SCHEME [Sales4Partitions_PS]
AS 
PARTITION [Sales4Partitions_PFN] TO 
		(SalesDBSalesDataPartition1, SalesDBSalesDataPartition2, 
		SalesDBSalesDataPartition3, SalesDBSalesDataPartition4 );
GO

----------------------------------------------------------------------------------------------
------------------------------ MOVE to a Partitioned Table -----------------------------------
----------------------------------------------------------------------------------------------

EXEC [sp_helpindex] 'Sales';
GO

-- What about another NC index?
CREATE INDEX [ExistingNC] 
ON [dbo].[Sales] ([SalesPersonID])
WITH (ONLINE = ON);
GO

-- Creating a CL Index ON a PS moves 
-- the DATA (the table) but not any other
-- nonclustered indexes.

-- And, oddly enough, the way to REBUILD a
-- CL PK on a PScheme is to essentially separate
-- the CL index from the PK definition and 
-- re-create the CL index ON the PScheme.
-- (< 30 secs on KLR machine)
CREATE UNIQUE CLUSTERED INDEX [SalesPK] 
ON [dbo].[Sales] ([SalesID])
WITH (DROP_EXISTING = ON, ONLINE = ON)
ON [Sales4Partitions_PS]([SalesID]);
GO

-- Review the location of the indexes
EXEC [sp_helpindex] 'Sales';
GO

CREATE INDEX [NewIndex]
ON [dbo].[Sales] ([SalesPersonID])
WITH (ONLINE = ON)
--ON [Sales4Partitions_PS](SalesID) -- you don't need to mention the scheme
GO                                  -- new indexes are partitioned by default

EXEC [sp_helpindex] 'Sales';
GO

-- Existing indexes must be rebuilt on the new
-- scheme
CREATE INDEX [ExistingNC] 
ON [dbo].[Sales] ([SalesPersonID])
WITH (DROP_EXISTING = ON, ONLINE = ON)
ON [Sales4Partitions_PS] (SalesID)
GO

EXEC [sp_helpindex] 'Sales';
GO

-- Now, everything is fully aligned!

----------------------------------------------------------------------------------------------
------------------------------ Backup for later recovery -------------------------------------
----------------------------------------------------------------------------------------------

USE [msdb];
GO

EXEC [sp_delete_database_backuphistory] 'SalesDB';
GO

USE [master];
GO

-- this takes a few minutes to run...
BACKUP DATABASE [SalesDB] 
	TO DISK = N'D:\SQLskills\SalesDBBackup.bak'
	WITH NAME = N'Full Database Backup'
	    , DESCRIPTION = 'Starting point for recovery'
		, INIT
		, STATS = 1;
GO