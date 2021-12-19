/*============================================================================
  File:     RegionalRangeCaseStudyFilegroups.sql

  MSDN Whitepaper: Partitioned Tables and Indexes in SQL Server 2005
  http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnsql90/html/sql2k5partition.asp

  Summary:  This script was originally included with the Partitioned Tables 
			and Indexes Whitepaper released on MSDN and written by Kimberly
			L. Tripp. To get more details about this whitepaper please 
			access the whitepaper on MSDN.

			This script creates the filegroups needed to create the 
			partitioned table. For this script to succeed you must have
			created already a [PartitionedSalesDB] database.
			
  SQL Server Version: 2008+
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

-- The [PartitionedSalesDB] was created in the RangeCaseStudyScript1-Filegroups.sql
-- script. If you did not review the RangeCaseStudyScripts 1 - 4 but still
-- want to create this list-based scenario, create the [PartitionedSalesDB]
-- database by uncommenting and running this next line:
-- CREATE DATABASE [PartitionedSalesDB]
-- GO

USE [PartitionedSalesDB];
go

-------------------------------------------------------
-- Add 5 FILEGROUPS to the [PartitionedSalesDB] Database
-------------------------------------------------------
-- This script adds 5 FILEGROUPS and 5 FILES
-- (one file for each filegroup) to the [PartitionedSalesDB] database. 

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [Spain];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [Italy];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [France];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [UK];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [Germany];
GO

ALTER DATABASE [PartitionedSalesDB] 	
ADD FILE 	  
 	(NAME = N'PartitionedSalesDBSpain',
        FILENAME = N'D:\SQLskills\PartitionedSalesDB\PartitionedSalesDBSpain.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [Spain];
go

ALTER DATABASE [PartitionedSalesDB] 	
ADD FILE 	  
 	(NAME = N'PartitionedSalesDBItaly',
        FILENAME = N'D:\SQLskills\PartitionedSalesDB\PartitionedSalesDBItaly.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [Italy];
go

ALTER DATABASE [PartitionedSalesDB] 	
ADD FILE 	  
 	(NAME = N'PartitionedSalesDBFrance',
        FILENAME = N'D:\SQLskills\PartitionedSalesDB\PartitionedSalesDBFrance.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [France];
go

ALTER DATABASE [PartitionedSalesDB] 	
ADD FILE 	  
 	(NAME = N'PartitionedSalesDBUK',
        FILENAME = N'D:\SQLskills\PartitionedSalesDB\PartitionedSalesDBUK.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [UK];
go

ALTER DATABASE [PartitionedSalesDB] 	
ADD FILE 	  
 	(NAME = N'PartitionedSalesDBGermany',
        FILENAME = N'D:\SQLskills\PartitionedSalesDB\PartitionedSalesDBGermany.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [Germany];
go

-------------------------------------------------------
-- Verify all files and filegroups
-------------------------------------------------------
USE [PartitionedSalesDB];
go

sp_helpfilegroup;
exec sp_helpfile;
go
