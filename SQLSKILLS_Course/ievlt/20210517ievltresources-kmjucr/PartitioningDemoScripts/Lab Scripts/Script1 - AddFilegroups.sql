/*============================================================================
  Lab:		Range Partitions Exercise 
  File:		Script1 - AddFilegroups.sql
  
  SQL Server Version: SQL Server 2019 (but will work for 2008+)
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

-------------------------------------------------------
-- Lab Setup: Step One
-- You must have a subdirectory of D:\AdventureWorks2008
-- OR REPLACE ALL references of this path.
-------------------------------------------------------
--!!mkdir D:\SQLskills\AdventureWorks2008Test
GO

-------------------------------------------------------
-- Lab Setup: Step Two 
-- Create a "test copy" version of AdventureWorks2008. 

-- Be sure to set your path correctly for the location
-- of the backup as well as the WITH MOVE option!

-- This script should be the only script requiring 
-- modifications for the entire lab.
-------------------------------------------------------

RESTORE DATABASE [AdventureWorks2008Test] 
	FROM DISK = N'D:\SQLskills\AdventureWorks2008Original_NoFS.BAK' 
	WITH  FILE = 1,  
		MOVE N'AdventureWorks2008_Data' 
			TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019Dev\MSSQL\DATA\AdventureWorks2008TestData.mdf'
		,  MOVE N'AdventureWorks2008_Log' 
			TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019Dev\MSSQL\DATA\AdventureWorks2008TestLog.ldf'
		,  NOUNLOAD,  STATS = 10;
GO

-------------------------------------------------------
-- Adding Filegroups and Files

-- This script adds 4 FILEGROUPS and 4 FILES
-- (one for each filegroup) to the AdventureWorks2008 
-- database. 
-------------------------------------------------------

ALTER DATABASE [AdventureWorks2008Test]
ADD FILEGROUP [2003Q3];
GO

ALTER DATABASE [AdventureWorks2008Test]
ADD FILEGROUP [2003Q4];
GO

ALTER DATABASE [AdventureWorks2008Test]
ADD FILEGROUP [2004Q1];
GO

ALTER DATABASE [AdventureWorks2008Test]
ADD FILEGROUP [2004Q2];
GO

-------------------------------------------------------
-- For RANGE Partitions
-- Add Files to each Filegroup

-- Be sure to set your path correctly for the location
-- of each newly created file below.

-- This script should be the only script requiring 
-- modifications for the entire lab.
-------------------------------------------------------
ALTER DATABASE [AdventureWorks2008Test]
ADD FILE 
  (NAME = N'RPFile1',
  FILENAME = N'D:\SQLskills\AdventureWorks2008Test\RPFile1.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB)
TO FILEGROUP [2003Q3];
GO

ALTER DATABASE [AdventureWorks2008Test]
ADD FILE 
  (NAME = N'RPFile2',
  FILENAME = N'D:\SQLskills\AdventureWorks2008Test\RPFile2.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB)
TO FILEGROUP [2003Q4];
GO

ALTER DATABASE [AdventureWorks2008Test]
ADD FILE 
  (NAME = N'RPFile3',
  FILENAME = N'D:\SQLskills\AdventureWorks2008Test\RPFile3.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB)
TO FILEGROUP [2004Q1];
GO

ALTER DATABASE [AdventureWorks2008Test]
ADD FILE 
  (NAME = N'RPFile4',
  FILENAME = N'D:\SQLskills\AdventureWorks2008Test\RPFile4.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB)
TO FILEGROUP [2004Q2];
GO

-------------------------------------------------------
-- Verify all files and filegroups
-------------------------------------------------------
USE [AdventureWorks2008Test];
GO

EXEC sp_helpfile;
GO