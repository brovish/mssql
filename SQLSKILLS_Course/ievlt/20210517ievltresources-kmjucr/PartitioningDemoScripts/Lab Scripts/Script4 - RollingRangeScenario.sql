/*============================================================================
  Lab:		Range Partitions Exercise 
  File:		Script4 - RollingRangeScenario.sql
  
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

USE [AdventureWorks2008Test];
GO

-------------------------------------------------------
-- WITHOUT Modifying the currently partitioned table
-- you can setup and manage the new data.
-- First, create a new filegroup in which you'll 
-- manipulate the quarter to be moved IN 
-- Q3 of 2004
-------------------------------------------------------
ALTER DATABASE [AdventureWorks2008Test]
ADD FILEGROUP [2004Q3];
GO

-------------------------------------------------------
-- Add a file to the new filegroup
-------------------------------------------------------
ALTER DATABASE [AdventureWorks2008Test]
ADD FILE 
  (NAME = N'2004Q3',
  FILENAME = N'D:\SQLskills\AdventureWorks2008Test\2004Q3.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB)
TO FILEGROUP [2004Q3];
GO

-------------------------------------------------------
-- Create a table for the quarter to be moved IN
-- Q3 of 2004
-------------------------------------------------------
CREATE TABLE [AdventureWorks2008Test].[dbo].[Orders2004Q3]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL ,
	[RevisionNumber] [tinyint] NULL,
	[ModifiedDate] [datetime] NULL,
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL
			CONSTRAINT [Orders2004Q3MinDate]
			CHECK ([OrderDate] >= '20040701'), 
	[TotalDue] [money] NULL
) ON [2004Q3];
GO

ALTER TABLE [AdventureWorks2008Test].[dbo].[Orders2004Q3]
ADD CONSTRAINT [Orders2004Q3MaxDate] 
		CHECK ([OrderDate] < '20041001');
GO

-------------------------------------------------------
-- Populate new table with Q3 2004 data.
-------------------------------------------------------
INSERT INTO [AdventureWorks2008Test].[dbo].[Orders2004Q3]
	SELECT [o].[PurchaseOrderID] 
			, [o].[EmployeeID]
			, [o].[VendorID]
			, [o].[TaxAmt]
			, [o].[Freight] 
			, [o].[SubTotal] 
			, [o].[Status] 
			, [o].[RevisionNumber] 
			, [o].[ModifiedDate] 
			, [o].[ShipMethodID] 
			, [o].[ShipDate] 
			, [o].[OrderDate] 
			, [o].[TotalDue] 
	FROM [AdventureWorks2008Test].[Purchasing].[PurchaseOrderHeader] AS [o]
	WHERE [o].[OrderDate] >= '20040701' 
		AND [o].[OrderDate] < '20041001';
GO

-------------------------------------------------------
-- The table *must* have the same clustered index
-- definition!
-------------------------------------------------------
--CREATE CLUSTERED INDEX [Orders2004Q3CLInd]
CREATE UNIQUE CLUSTERED INDEX [Orders2004Q3CLInd]
ON [dbo].[Orders2004Q3]([OrderDate], [OrderID])
ON [2004Q3];
GO

-- DROP INDEX [Orders2004Q3].[Orders2004Q3CLInd]

sp_help [Orders2004Q3];
go

-- What have we done?
-- Created the data for staging in and placed it on DESTINATION


-------------------------------------------------------
-- Now that the data is ready to be moved IN you can 
-- prepare to swap out the old data.
-- Create a table for the quarter being moved
-- out - which is Q3 of 2003 
-- THIS MUST BE ON THE CORRECT FILEGROUP 
-- A Switch solely "switches" meta data - to do this
-- the objects must be on the same filegroup!
-------------------------------------------------------
CREATE TABLE [AdventureWorks2008Test].[dbo].[Orders2003Q3]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL ,
	[RevisionNumber] [tinyint] NULL,
	[ModifiedDate] [datetime] NULL,
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL, 
	[TotalDue] [money] NULL
) ON [2003Q3];
GO
-------------------------------------------------------
-- The table must have the same clustered index
-- definition!
-------------------------------------------------------
CREATE UNIQUE CLUSTERED INDEX [Orders2003Q3CLInd]
ON [dbo].[Orders2003Q3]([OrderDate], [OrderID])
ON [2003Q3];
GO

SELECT * FROM [dbo].[Orders2003Q3]; -- empty!
SELECT * FROM [dbo].[Orders2004Q3];
GO
-------------------------------------------------------
-- "Switch" the old partition out to a new table
-------------------------------------------------------
ALTER TABLE [dbo].[OrdersRange]
SWITCH PARTITION 2
TO [dbo].[Orders2003Q3];
GO

SELECT * FROM [dbo].[Orders2003Q3]; -- now has what the partition used to have!
go
-- Why Partition 2? Because in a RIGHT-based Partition 
-- function, the first partition will remain empty!

-- Next you could back up the table and/or just drop it,
-- depending on what your archiving rules are, etc.

-- The nice part about having this isolated in it's own
-- filgroup, is that you effectively get table level restore
-- into a new location if desired. Using partial database
-- restores you can restore just the primary and a subset 
-- of filegroups - and still access the data. Then you can
-- move data into another database.

-------------------------------------------------------
-- Verify Data In Partition Ranges 3, 4 and 5 ONLY
-------------------------------------------------------
SELECT $partition.[OrderDateRangePFN]([or].[OrderDate]) 
			AS 'Parition Number'
	, min([or].[OrderDate]) AS 'Min Order Date'
	, max([or].[OrderDate]) AS 'Max Order Date'
	, count(*) AS 'Rows In Partition'
FROM [dbo].[OrdersRange] AS [or]
GROUP BY $partition.[OrderDateRangePFN]([or].[OrderDate])
ORDER BY 1;
GO

-------------------------------------------------------
-- Alter the partition function to drop the old range
-- The idea is that when paritions are merged a boundary
-- point is removed.
-- If there's data on the paritions then it needs to be
-- consolidated to one partition. Which partition's
-- filegroup will get the data? The one that DOES NOT 
-- contain the boundary point that being removed. The 
-- remaining partition will host the data (but none should
-- exist). By having already emptied this partition 
-- (by switching it out and replacing it with an empty 
-- table - therefore empty partition) there won't be 
-- any data to move!

-- Because no data needs to move, the merge operation 
-- should be extremely fast!
-------------------------------------------------------
ALTER PARTITION FUNCTION [OrderDateRangePFN]()
MERGE RANGE ('20030701')
GO 

-------------------------------------------------------
-- Verify Partition Ranges
-- Data was in partitions 3, 4, 5 and now merge removed
-- partiton	2...
-- SQL Server always numbers the data based on the CURRENT
-- number of partitions so if you run the query again you 
-- will see ONLY 3 partitions but the partition numbers
-- will be 2, 3 and 4 even though NO DATA HAS MOVED (only 
-- partition numbers have changed).
-------------------------------------------------------
SELECT $partition.[OrderDateRangePFN]([or].[OrderDate]) 
			AS 'Parition Number'
	, min([or].[OrderDate]) AS 'Min Order Date'
	, max([or].[OrderDate]) AS 'Max Order Date'
	, count(*) AS 'Rows In Partition'
FROM [dbo].[OrdersRange] AS [or]
GROUP BY $partition.[OrderDateRangePFN]([or].[OrderDate])
ORDER BY 1;
GO

-------------------------------------------------------
-- This also removes the filegroup associated with the
-- partition scheme (meaning that [2003Q3] filegroup is 
-- no longer associated.
-------------------------------------------------------

--Use the following query to see to see ALL filegroups
SELECT * FROM [sys].[filegroups];
GO

-- Use the following query to see to see ONLY the filegroups
-- associated with OrdersRange
SELECT [ps].[name] AS PSName, 
		[dds].[destination_id] AS PartitionNumber, 
        [dds].[data_space_id] AS FileGroup,
		[fg].[name] AS FileGroupName
FROM ((([sys].[tables] AS [t] 
	INNER JOIN [sys].[indexes] AS [i] 
		ON ([t].[object_id] = [i].[object_id]))
	INNER JOIN [sys].[partition_schemes] AS [ps] 
		ON ([i].[data_space_id] = [ps].[data_space_id]))
	INNER JOIN [sys].[destination_data_spaces] AS [dds] 
		ON ([ps].[data_space_id] = [dds].[partition_scheme_id]))
	INNER JOIN [sys].[filegroups] AS [fg]
		ON [dds].[data_space_id] = [fg].[data_space_id]
WHERE ([t].[name] = 'OrdersRange') AND ([i].[index_id] IN (0,1));
GO

-------------------------------------------------------
-- Alter the partition SCHEME to set the next filegroup
-- that should be used if a new partition is added
-------------------------------------------------------
ALTER PARTITION SCHEME [OrderDatePScheme] 
NEXT USED [2004Q3];
GO

-------------------------------------------------------
-- BEFORE you can add this data you must allow it.
-------------------------------------------------------

ALTER TABLE [dbo].[OrdersRange]
ADD CONSTRAINT [OrdersRangeMax]
	CHECK ([OrderDate] < '20041001');
GO

ALTER TABLE [dbo].[OrdersRange]
ADD CONSTRAINT [OrdersRangeMin]
	CHECK ([OrderDate] >= '20031001');
GO

ALTER TABLE [dbo].[OrdersRange]
DROP CONSTRAINT [OrdersRangeYear];
GO

-------------------------------------------------------
-- Alter the partition function to add the new range
-------------------------------------------------------
ALTER PARTITION FUNCTION [OrderDateRangePFN]() 
SPLIT RANGE ('20040701');
GO 

SELECT * FROM [dbo].[Orders2004Q3];
GO
-------------------------------------------------------
-- "Switch" the new partition in.
-------------------------------------------------------
ALTER TABLE [dbo].[Orders2004Q3]   
SWITCH TO [dbo].[OrdersRange] PARTITION 5;
GO

SELECT * FROM [dbo].[Orders2004Q3];   
GO

-------------------------------------------------------
-- Verify New Date Ranges for partitions - All 4!
-------------------------------------------------------
SELECT $partition.[OrderDateRangePFN]([or].[OrderDate]) 
			AS 'Parition Number'
	, min([or].[OrderDate]) AS 'Min Order Date'
	, max([or].[OrderDate]) AS 'Max Order Date'
	, count(*) AS 'Rows In Partition'
FROM [dbo].[OrdersRange] AS [or]
GROUP BY $partition.[OrderDateRangePFN]([or].[OrderDate])
ORDER BY 1;
GO

-------------------------------------------------------
-- Verify Final Constraints, Indexes, and Table Structures
-------------------------------------------------------
--exec sp_helpconstraint Orders2004Q3   
--exec sp_helpconstraint OrdersRange
--exec sp_helpindex Orders2004Q3   
--exec sp_helpindex OrdersRange
--exec sp_help Orders2004Q3   
--exec sp_help OrdersRange