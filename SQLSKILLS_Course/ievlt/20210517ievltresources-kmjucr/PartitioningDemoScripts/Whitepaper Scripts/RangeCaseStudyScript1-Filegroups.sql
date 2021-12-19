/*============================================================================
  File:     RangeCaseStudyScript1-Filegroups.sql

  MSDN Whitepaper: Partitioned Tables and Indexes in SQL Server 2005
  http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnsql90/html/sql2k5partition.asp

  Summary:  This script was originally included with the Partitioned Tables 
			and Indexes Whitepaper released on MSDN and written by Kimberly
			L. Tripp. To get more details about this whitepaper please 
			access the whitepaper on MSDN.

			This script adds 24 FILEGROUPS and 24 FILES to a new database
			named PartitionedSalesDB. 
			
			This script uses a table to build the filegroups - make sure
			to modify the INSERT statements to use the appropriate disks. 
			Also, the initial size (1MB), maximum size (100MB) and the
			growth rate (5MB) for these filegroups is different (MUCH smaller)
			than the whitepaper showed. If desired, change the 
			string to use the desired sizes.

  Date:     November 2014

  SQL Server Version: SQL Server 2005+
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
-- SETUP SECTION
-------------------------------------------------------
-- First, create a subdirectory for the PartitionedSalesDB database.
-- IMPORTANT: The following SQLCMD line will fail unless you are running
-- in SQLCMD mode. 
!!mkdir D:\SQLskills\PartitionedSalesDB
go

-- The PartitionedSalesDB will use user-defined filegroups for data and
-- will not place user-defined objects in the primary file.
-- Because of this the primary portion of the database can be
-- relatively small. However, the transaction log may grow quite
-- large. As a best practice, you should pre-allocate the tranaction
-- log to an appropriate size. For this sample database, the log
-- will not grow too large so we'll use the defaults for 
-- database creation.

-- DROP DATABASE [PartitionedSalesDB]
CREATE DATABASE [PartitionedSalesDB];
GO

-------------------------------------------------------
-- Add 24 FILEGROUPS to the Sales Database
-------------------------------------------------------

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG1];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG2];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG3];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG4];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG5];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG6];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG7];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG8];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG9];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG10];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG11];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG12];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG13];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG14];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG15];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG16];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG17];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG18];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG19];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG20];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG21];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG22];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG23];
GO

ALTER DATABASE [PartitionedSalesDB]
ADD FILEGROUP [FG24];
GO

-------------------------------------------------------
-- Add Files to each Filegroup
-------------------------------------------------------
USE [PartitionedSalesDB];
go

CREATE TABLE [PartitionedSalesDB].[dbo].[FilegroupInfo]
(
	[PartitionNumber]	smallint,
	[FilegroupNumber]	tinyint,
	[Location]	        nvarchar(50)
);
go

-- All files go to DRIVE D:\SQLskills\PartitionedSalesDB - for testing...
INSERT [dbo].[FilegroupInfo] VALUES (1, 1, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (2, 2, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (3, 3, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (4, 4, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (5, 5, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (6, 7, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (7, 8, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (8, 9, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (9, 9, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (10, 10, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (11, 11, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (12, 12, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (13, 13, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (14, 14, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (15, 15, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (16, 16, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (17, 17, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (18, 18, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (19, 19, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (20, 20, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (21, 21, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (22, 22, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (23, 23, N'D:\SQLskills\PartitionedSalesDB');
INSERT [dbo].[FilegroupInfo] VALUES (24, 24, N'D:\SQLskills\PartitionedSalesDB');
go


-- All files directed to the disks as shown in the whitepaper
-- INSERT [dbo].[FilegroupInfo] VALUES (1, 1, N'E:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (2, 2, N'F:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (3, 3, N'G:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (4, 4, N'H:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (5, 5, N'I:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (6, 7, N'J:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (7, 8, N'K:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (8, 9, N'L:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (9, 9, N'M:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (10, 10, N'N:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (11, 11, N'O:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (12, 12, N'P:\PartitionedSalesDB')

-- INSERT [dbo].[FilegroupInfo] VALUES (13, 13, N'K:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (14, 14, N'L:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (15, 15, N'M:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (16, 16, N'N:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (17, 17, N'O:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (18, 18, N'P:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (19, 19, N'E:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (20, 20, N'F:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (21, 21, N'G:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (22, 22, N'H:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (23, 23, N'I:\PartitionedSalesDB')
-- INSERT [dbo].[FilegroupInfo] VALUES (24, 24, N'J:\PartitionedSalesDB')
-- go

DECLARE @PartitionNumber	smallint,
	@FilegroupNumber	tinyint,
	@Location		nvarchar(50),
	@ExecStr		nvarchar(300)

DECLARE FilegroupsToCreate CURSOR FOR 
	SELECT * FROM dbo.FileGroupInfo
	ORDER BY PartitionNumber
OPEN FilegroupsToCreate 
FETCH NEXT FROM FilegroupsToCreate INTO @PartitionNumber, @FilegroupNumber, @Location

WHILE (@@fetch_status <> -1) -- (-1) you've fetched beyond the cursor
BEGIN
    IF (@@fetch_status <> -2) -- (-2) you've fetched a row that no longer exists
    BEGIN  -- Fetch_status must be 0
	SELECT @ExecStr = N'ALTER DATABASE [PartitionedSalesDB] ' + 
			  N'	ADD FILE ' + 
			  N'	  (NAME = N''PartitionedSalesDBFG' + CONVERT(nvarchar, @PartitionNumber) + N'File1'',' +
			  N'       FILENAME = N''' + @Location + N'\PartitionedSalesDBFG' + CONVERT(nvarchar, @PartitionNumber) + 'File1.ndf'',' + 
			  N'       SIZE = 1MB,' +  
			  N'       MAXSIZE = 100MB,' +
			  N'       FILEGROWTH = 5MB)' +
			  N' TO FILEGROUP ' + N'[FG' + CONVERT(nvarchar, @PartitionNumber) + N']'
	SELECT (@ExecStr)
	--EXEC (@ExecStr) -- DO NOT UNCOMMENT THIS UNTIL YOU ARE SURE THE NAMES and LOCATIONS are correct.
    END

FETCH NEXT FROM FilegroupsToCreate INTO @PartitionNumber, @FilegroupNumber, @Location
END

DEALLOCATE FilegroupsToCreate 
GO

-- Each of the twenty four files should be added with the information you used within the FileGroupInfo table
-- ALTER DATABASE [PartitionedSalesDB] 	
-- ADD FILE 	  
-- 	(NAME = N'PartitionedSalesDBFG1File1',
--         FILENAME = N'C:\SQLskills\PartitionedSalesDB\PartitionedSalesDBFG1File1.ndf'
--   	SIZE = 1MB,
--         MAXSIZE = 100MB,
--         FILEGROWTH = 5MB) 
-- TO FILEGROUP [FG1]

-------------------------------------------------------
-- Verify all files and filegroups
-------------------------------------------------------
USE [PartitionedSalesDB];
go

sp_helpfilegroup;
exec sp_helpfile;
go
