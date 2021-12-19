/*============================================================================
  File:     RangeCaseStudyScript2-PartitionedTable.sql

  MSDN Whitepaper: Partitioned Tables and Indexes in SQL Server 2005
  http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnsql90/html/sql2k5partition.asp

  Summary:  This script was originally included with the Partitioned Tables 
			and Indexes Whitepaper released on MSDN and written by Kimberly
			L. Tripp. To get more details about this whitepaper please 
			access the whitepaper on MSDN.

			This script has a slight modification from the one posted 
			originally with the partitioning whitepaper. The difference 
			is highlighted in the INSERT...SELECT to the [Order Details] 
			table. The change is due to a column rename in AdventureWorks2008Test. 
			LineNumber has been changed and replaced by PurchaseOrderDetailID.

			Addionally, these scripts have been re-written to use RIGHT based 
			Partition Functions instead of left!
			
			This script is used to build and populate the partitioned table.

    SQL Server Version: SQL Server 2008+
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

USE [PartitionedSalesDB];
GO

-------------------------------------------------------
-- Create the partition function
-------------------------------------------------------
CREATE PARTITION FUNCTION [TwoYearDateRangePFN](datetime)
AS 
RANGE RIGHT FOR VALUES 
(			'20021001',	-- Oct 2002
			'20021101',	-- Nov 2002
			'20021201',	-- Dec 2002
			'20030101',	-- Jan 2003
			'20030201',	-- Feb 2003
			'20030301',	-- Mar 2003
			'20030401',	-- Apr 2003
			'20030501',	-- May 2003
			'20030601',	-- Jun 2003
			'20030701',	-- Jul 2003
			'20030801',	-- Aug 2003
			'20030901',	-- Sep 2003
			'20031001',	-- Oct 2003
			'20031101',	-- Nov 2003
			'20031201',	-- Dec 2003
			'20040101',	-- Jan 2004
			'20040201',	-- Feb 2004
			'20040301',	-- Mar 2004
			'20040401',	-- Apr 2004
			'20040501',	-- May 2004
			'20040601',	-- Jun 2004
			'20040701',	-- Jul 2004
			'20040801',	-- Aug 2004
			'20040901');	-- Sep 2004
go

-- As per the lecture and NOT the whitepaper, I usually use a "tiny"
-- filegroup for the "empty" partition at the far LEFT in a right-based
-- function.

ALTER DATABASE [PartitionedSalesDB] 
	ADD FILEGROUP [Tiny];
go

ALTER DATABASE [PartitionedSalesDB] 
	ADD FILE
		(NAME = N'PartitionedSalesDBTiny', 
		FILENAME = N'D:\SQLskills\Demos\PartitionedSalesDBTiny.ndf', 
		SIZE = 2, FILEGROWTH = 0, MAXSIZE = 2) 
		TO FILEGROUP [Tiny];
go


-------------------------------------------------------
-- Create the partition scheme
-------------------------------------------------------
CREATE PARTITION SCHEME [TwoYearDateRangePScheme]
AS 
PARTITION [TwoYearDateRangePFN] TO 
		( [Tiny], [FG1], [FG2], [FG3], [FG4], [FG5], [FG6], 
		  [FG7], [FG8], [FG9], [FG10],[FG11],[FG12],
		  [FG13],[FG14],[FG15],[FG16],[FG17],[FG18],
		  [FG19],[FG20],[FG21],[FG22],[FG23],[FG24]);
-- The last partition will ALWAYS be empty using the Rolling Range Scenario. 
-- Using the PRIMARY is acceptible for this as no data will actually reside there.
GO

-------------------------------------------------------
-- Create the Orders table on the RANGE partition scheme
-------------------------------------------------------
CREATE TABLE [PartitionedSalesDB].[dbo].[Orders]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL ,
	[RevisionNumber] [tinyint] NULL ,
	[ModifiedDate] [datetime] NULL ,
	[ShipMethodID]	tinyint NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL
		CONSTRAINT OrdersRangeYearCK
			CHECK ([OrderDate] >= '20021001' 
				AND [OrderDate] < '20041001'), 
	[TotalDue] [money] NULL
) ON TwoYearDateRangePScheme(OrderDate)
GO

CREATE TABLE [dbo].[OrderDetails](
	[OrderID] [int] NOT NULL,
	[LineNumber] [smallint] NOT NULL,
	[ProductID] [int] NULL,
	[UnitPrice] [money] NULL,
	[OrderQty] [smallint] NULL,
	[ReceivedQty] [float] NULL,
	[RejectedQty] [float] NULL,
	[OrderDate] [datetime] NOT NULL
		CONSTRAINT OrderDetailsRangeYearCK
			CHECK ([OrderDate] >= '20021001' 
				 AND [OrderDate] < '20041001'), 
	[DueDate] [datetime] NULL,
	[ModifiedDate] [datetime] NOT NULL 
		CONSTRAINT [OrderDetailsModifiedDateDFLT] 
			DEFAULT (getdate()),
	[LineTotal]  AS (([UnitPrice]*[OrderQty])),
	[StockedQty]  AS (([ReceivedQty]-[RejectedQty]))
) ON TwoYearDateRangePScheme(OrderDate)
GO

-------------------------------------------------------
-- Copy data from AdventureWorks2008 to create the Orders 
-- and OrderDetails tables. You MUST install the AdeventureWorks
-- Database in order for these next two INSERT/SELECT
-- statements to populate the tables.
-- See the BOL topic: "Running Setup to Install AventureWorks 
-- Sample Database and Samples" for information on how to 
-- install the AdventureWorks2008 sample database.
-------------------------------------------------------

-- Use the two following two queries to populate the PartitionedSalesDB 
-- tables with AdventureWorks2008 data. Note: A few partitions
-- will NOT contain any data.

INSERT [dbo].[Orders]
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
	FROM [AdventureWorks2008].[Purchasing].[PurchaseOrderHeader] AS [o]
		WHERE ([OrderDate] >= '20021001' 
				 AND [OrderDate] < '20041001');
go

INSERT [dbo].[OrderDetails]
	SELECT 	[od].[PurchaseOrderID]
			, [od].[PurchaseOrderDetailID] -- LineNumber (in earlier releases this was LineNumber)
			, [od].[ProductID]
			, [od].[UnitPrice]
			, [od].[OrderQty]
			, [od].[ReceivedQty]
			, [od].[RejectedQty]
			, [o].[OrderDate]
			, [od].[DueDate]
			, [od].[ModifiedDate]
	FROM [AdventureWorks2008].[Purchasing].[PurchaseOrderDetail] AS [od]
		JOIN [AdventureWorks2008].[Purchasing].[PurchaseOrderHeader] AS [o]
				ON [o].[PurchaseOrderID] = [od].[PurchaseOrderID]
		WHERE ([o].[OrderDate] >= '20021001' 
				 AND [o].[OrderDate] < '20041001');
go

-------------------------------------------------------
-- Verify Partition Ranges
-------------------------------------------------------

-- Note: Partitions 4,5,6 and 8 do NOT contain any data.

SELECT $partition.[TwoYearDateRangePFN]([o].[OrderDate]) 
			AS [Partition Number]
	, min([o].[OrderDate]) AS [Min Order Date]
	, max([o].[OrderDate]) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM [dbo].[Orders] AS [o]
GROUP BY $partition.TwoYearDateRangePFN([o].[OrderDate])
ORDER BY [Partition Number];
go

SELECT $partition.TwoYearDateRangePFN([od].[OrderDate]) 
			AS [Partition Number]
	, min([od].[OrderDate]) AS [Min Order Date]
	, max([od].[OrderDate]) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM [dbo].[OrderDetails] AS [od]
GROUP BY $partition.TwoYearDateRangePFN([od].[OrderDate])
ORDER BY [Partition Number];
go

-------------------------------------------------------
-- To see the partition information row by row - just for Orders
-------------------------------------------------------

SELECT [o].[OrderDate], 
	$partition.[TwoYearDateRangePFN]([o].[OrderDate]) 
		AS [Partition Number]
FROM [dbo].[Orders] AS [o]
ORDER BY [o].[OrderDate];
go

-------------------------------------------------------
-- Create the clustered indexes as Primary keys
-- for both partitioned tables. Specifying the SCHEME 
-- is optional. If the table is partitioned the defaulf 
-- behavior is for SQL Server to create the cl index 
-- on the same partition scheme.
-------------------------------------------------------
ALTER TABLE [dbo].[Orders]
ADD CONSTRAINT [OrdersPK]
	PRIMARY KEY CLUSTERED ([OrderDate], [OrderID])
	ON [TwoYearDateRangePScheme]([OrderDate]);
go

ALTER TABLE [dbo].[OrderDetails]
ADD CONSTRAINT [OrderDetailsPK]
	PRIMARY KEY CLUSTERED ([OrderDate], [OrderID], [LineNumber])
	ON [TwoYearDateRangePScheme]([OrderDate]);
go