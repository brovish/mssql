/*============================================================================
  Lab:		Range Partitions Exercise 
  File:		Script3 - RangePartitionedTable.sql
  
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
-- Create the partition function
-------------------------------------------------------
CREATE PARTITION FUNCTION [OrderDateRangePFN]([datetime])
AS 
RANGE RIGHT FOR VALUES 
(
		'20030701',
		'20031001',
		'20040101',
		'20040401');
GO

-------------------------------------------------------
-- Create the partition scheme
-------------------------------------------------------
-- Discussion around "tiny" filegroup

ALTER DATABASE [AdventureWorks2008Test] 
	ADD FILEGROUP [Tiny];
GO

ALTER DATABASE [AdventureWorks2008Test]  
	ADD FILE
		(NAME = N'AWPTTiny', 
		FILENAME = N'D:\SQLskills\Demos\AWPTTiny.ndf', 
		SIZE = 2, FILEGROWTH = 0, MAXSIZE = 2) 
		TO FILEGROUP [Tiny];
GO

EXEC [sp_helpfile];
GO

CREATE PARTITION SCHEME [OrderDatePScheme]
AS 
PARTITION [OrderDateRangePFN] 
TO ([Tiny], [2003Q3],[2003Q4],[2004Q1],[2004Q2]);
GO

-- The first partition (in a RIGHT-based partition 
-- function will probably be empty). Because this 
-- first partition will remain empty, using the PRIMARY 
-- filegroup is acceptible as it's only a logical locator, 
-- no rows will ever reside there. 

--Ramneek: Kimberly update the script and instead of the PRIMARY being referred above in the comments, we are now using TINY filegroup.
-------------------------------------------------------
-- Create the OrdersRange table on the partition scheme
-------------------------------------------------------
CREATE TABLE [AdventureWorks2008Test].[dbo].[OrdersRange]  
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
			CONSTRAINT [OrdersRangeYear]
			CHECK ([OrderDate] >= '20030701' 
				AND [OrderDate] < '20040701'), 
	[TotalDue] [money] NULL
) ON [OrderDatePScheme] ([OrderDate]);
GO

-------------------------------------------------------
-- Add data to the OrdersRange table
-------------------------------------------------------
INSERT INTO [dbo].[OrdersRange]
SELECT [o].[OrderID] 
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
FROM [dbo].[Orders] AS [o];
GO

-------------------------------------------------------
-- Confirm Row to Partition Location
-------------------------------------------------------
SELECT [or].[OrderDate], 
		$partition.OrderDateRangePFN([or].[OrderDate]) 
			AS 'Partition Number'
FROM [dbo].[OrdersRange] AS [or]
ORDER BY [or].[OrderDate]
GO

-------------------------------------------------------
-- Verify Partition Ranges
-------------------------------------------------------
SELECT $partition.[OrderDateRangePFN]([or].[OrderDate]) 
			AS 'Partition Number'
	, min([or].[OrderDate]) AS 'Min Order Date'
	, max([or].[OrderDate]) AS 'Max Order Date'
	, count(*) AS 'Rows In Partition'
FROM [dbo].[OrdersRange] AS [or]
GROUP BY $partition.[OrderDateRangePFN]([or].[OrderDate]) 
ORDER BY 1 
GO

-------------------------------------------------------
-- Now create a clustered indexes on the 
-- non-partitioned table (Orders) as well
-- as the Partitioned table (OrdersPartitioned)
-------------------------------------------------------

-- First, the partitioned table
CREATE UNIQUE CLUSTERED INDEX [OrdersRangeCLInd]
ON [dbo].[OrdersRange]([OrderDate], [OrderID])
ON [OrderDatePScheme]([OrderDate]);
GO

-- Create a clustered index on the non-partitioned table
CREATE UNIQUE CLUSTERED INDEX [OrdersCLInd]
ON [dbo].[Orders]([OrderDate], [OrderID])
ON [PRIMARY];
GO 

-------------------------------------------------------
-- Compare the query plans on the two tables 
-- by turning on "Include Actual Execution Plan" 
-- from the Query drop-down menu.
-------------------------------------------------------

SET STATISTICS IO ON;
GO

SELECT * FROM [dbo].[Orders];
SELECT * FROM [dbo].[OrdersRange];
GO