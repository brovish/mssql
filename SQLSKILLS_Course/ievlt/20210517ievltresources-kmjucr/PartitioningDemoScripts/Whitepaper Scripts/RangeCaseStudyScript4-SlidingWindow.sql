/*============================================================================
  File:     RangeCaseStudyScript4-SlidingWindow.sql

  MSDN Whitepaper: Partitioned Tables and Indexes in SQL Server 2005
  http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnsql90/html/sql2k5partition.asp

  Summary:  This script was originally included with the Partitioned Tables 
			and Indexes Whitepaper released on MSDN and written by Kimberly
			L. Tripp. To get more details about this whitepaper please 
			access the whitepaper on MSDN.

			This script has been significantly modified from the script
			originally posted with the whitepaper. The difference is that 
			this script covers the switch in and switch out of BOTH the 
			[Orders] and the [Order Details] tables.

			This script is used to highlight and discuss the rolling range
			scenario.

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

USE [PartitionedSalesDB];
go

-------------------------------------------------------
-- Quick backup to make sure that we have one.
-------------------------------------------------------
--BACKUP DATABASE PartitionedSalesDB TO DISK = 'C:\SQLskills\PartitionedSalesDB\PartitionedSalesDB.bak'
--	WITH INIT
--RESTORE DATABASE PartitionedSalesDB FROM DISK = 'C:\SQLskills\PartitionedSalesDB\PartitionedSalesDB.bak'
--	WITH REPLACE

-------------------------------------------------------
-- Determine the partition with which to work
-------------------------------------------------------
SELECT ps.name AS PSName, 
		dds.destination_id AS PartitionNumber, 
		fg.name AS FileGroupName
FROM (((sys.tables AS t 
	INNER JOIN sys.indexes AS i 
		ON (t.object_id = i.object_id))
	INNER JOIN sys.partition_schemes AS ps 
		ON (i.data_space_id = ps.data_space_id))
	INNER JOIN sys.destination_data_spaces AS dds 
		ON (ps.data_space_id = dds.partition_scheme_id))
	INNER JOIN sys.filegroups AS fg
		ON dds.data_space_id = fg.data_space_id
WHERE (t.name = 'Orders') and (i.index_id IN (0,1))
	AND dds.destination_id = $partition.TwoYearDateRangePFN('20021001') 

-------------------------------------------------------
-- Create staging tables for both Orders and Order Details
-- For the NEW Data of October 2004
-------------------------------------------------------
CREATE TABLE [PartitionedSalesDB].[dbo].[OrdersOctober2004]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NULL,
	[ModifiedDate] [datetime] NULL,
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL,
	[TotalDue] [money] NULL
) ON [FG1];
GO

CREATE TABLE [dbo].[OrderDetailsOctober2004](
	[OrderID] [int] NOT NULL,
	[LineNumber] [smallint] NOT NULL,
	[ProductID] [int] NULL,
	[UnitPrice] [money] NULL,
	[OrderQty] [smallint] NULL,
	[ReceivedQty] [float] NULL,
	[RejectedQty] [float] NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NULL,
	[ModifiedDate] [datetime] NOT NULL, 
	[LineTotal]  AS (([UnitPrice]*[OrderQty])),
	[StockedQty]  AS (([ReceivedQty]-[RejectedQty]))
) ON [FG1];
GO

-- -------------------------------------------------------
-- Populate the October 2004 table with new data.
-- -------------------------------------------------------
-- Through INSERT...SELECT or through parallel bulk insert
-- statements against the text files.
INSERT dbo.[OrdersOctober2004]
	SELECT o.[PurchaseOrderID] 
			, o.[EmployeeID]
			, o.[VendorID]
			, o.[TaxAmt]
			, o.[Freight] 
			, o.[SubTotal] 
			, o.[Status] 
			, o.[RevisionNumber] 
			, o.[ModifiedDate] 
			, o.[ShipMethodID] 
			, o.[ShipDate] 
			, dateadd(yy, 1, o.[OrderDate])
			, o.[TotalDue] 
	FROM AdventureWorks2008.Purchasing.PurchaseOrderHeader AS o
		WHERE (o.[OrderDate] >= '20031001' 
				 AND o.[OrderDate] < '20031101')

INSERT dbo.[OrderDetailsOctober2004]
	SELECT 	od.PurchaseOrderID
			, od.PurchaseOrderDetailID -- LineNumber?
			, od.ProductID
			, od.UnitPrice
			, od.OrderQty
			, od.ReceivedQty
			, od.RejectedQty
			, dateadd(yy, 1, o.[OrderDate])
			, od.DueDate
			, od.ModifiedDate
	FROM AdventureWorks2008.Purchasing.PurchaseOrderDetail AS od
		JOIN AdventureWorks2008.Purchasing.PurchaseOrderHeader AS o
				ON o.PurchaseOrderID = od.PurchaseOrderID
		WHERE (o.[OrderDate] >= '20031001' 
				 AND o.[OrderDate] < '20031101')
GO

-- -------------------------------------------------------
-- Once the data is loaded then you can ALTER TABLE to
-- add the constraint. Be sure to use default WITH CHECK to 
-- verify the data and create a "trusted" constraint.
-- -------------------------------------------------------
ALTER TABLE PartitionedSalesDB.[dbo].[OrdersOctober2004]  
WITH CHECK
ADD CONSTRAINT OrdersOctober2004RangeYearCK
	CHECK ([OrderDate] >= '20041001' 
		AND [OrderDate] < '20041101')
GO

ALTER TABLE PartitionedSalesDB.[dbo].[OrderDetailsOctober2004]  
WITH CHECK
ADD CONSTRAINT OrderDetailsOctober2004RangeYearCK
	CHECK ([OrderDate] >= '20041001' 
		AND [OrderDate] < '20041101')
GO
-------------------------------------------------------
-- The table must have the same clustered index
-- definition!
-------------------------------------------------------
ALTER TABLE [OrdersOctober2004]
ADD CONSTRAINT OrdersOctober2004PK
 PRIMARY KEY CLUSTERED (OrderDate, OrderID)
ON [FG1]
GO

ALTER TABLE dbo.[OrderDetailsOctober2004]
ADD CONSTRAINT OrderDetailsOctober2004PK
	PRIMARY KEY CLUSTERED (OrderDate, OrderID, LineNumber)
ON [FG1]
GO

-------------------------------------------------------
-- Now that the data is ready to be moved IN you can 
-- prepare to switch out the old data.
-- Create a table for the October 2001 partition being 
-- moved out 

-- THIS MUST BE ON THE SAME FILEGROUP AS THE PARTITION
-- BEING SWITCHED OUT. 
-- Remember, a switch solely "switches" meta data - to do this
-- the objects must be on the same filegroup!
-------------------------------------------------------
CREATE TABLE PartitionedSalesDB.[dbo].[OrdersOctober2002]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NULL,
	[ModifiedDate] [datetime] NULL,
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL, 
	[TotalDue] [money] NULL
) ON [FG1]
GO

CREATE TABLE [dbo].[OrderDetailsOctober2002](
	[OrderID] [int] NOT NULL,
	[LineNumber] [smallint] NOT NULL,
	[ProductID] [int] NULL,
	[UnitPrice] [money] NULL,
	[OrderQty] [smallint] NULL,
	[ReceivedQty] [float] NULL,
	[RejectedQty] [float] NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NULL,
	[ModifiedDate] [datetime] NOT NULL, 
	[LineTotal]  AS (([UnitPrice]*[OrderQty])),
	[StockedQty]  AS (([ReceivedQty]-[RejectedQty]))
) ON FG1
GO
-------------------------------------------------------
-- The table must have the same clustered index
-- definition!
-------------------------------------------------------
ALTER TABLE [OrdersOctober2002]
ADD CONSTRAINT OrdersOctober2002PK
 PRIMARY KEY CLUSTERED (OrderDate, OrderID)
ON [FG1]
GO

SELECT * FROM dbo.[OrdersOctober2002]
GO

ALTER TABLE dbo.[OrderDetailsOctober2002]
ADD CONSTRAINT OrderDetailsOctober2002PK
	PRIMARY KEY CLUSTERED (OrderDate, OrderID, LineNumber)
ON FG1
GO

SELECT * FROM dbo.[OrdersOctober2002]
GO

-------------------------------------------------------
-- "Switch" the old partition out to a new table
-------------------------------------------------------
ALTER TABLE Orders
SWITCH PARTITION 2
TO OrdersOctober2002
GO

SELECT * FROM dbo.[OrdersOctober2002]
GO

ALTER TABLE OrderDetails
SWITCH PARTITION 2
TO OrderDetailsOctober2002
GO

SELECT * FROM dbo.[OrderDetailsOctober2002]
GO
-- Next you could back up the table and/or just drop it,
-- depending on what your archiving rules are, etc.

-------------------------------------------------------
-- Verify Data In Partition Ranges 3, 7, 9, ... 25
-------------------------------------------------------
SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM Orders
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

-------------------------------------------------------
-- Alter the partition function to drop the old range
-- The idea is that when paritions are merged a boundary
-- point is removed.

-- The merge operation should be extremely fast!
-------------------------------------------------------
ALTER PARTITION FUNCTION TwoYearDateRangePFN()
MERGE RANGE ('20021001')
GO 

-------------------------------------------------------
-- Verify Partition Ranges
-- Data was in partitions 3 through 25 and now merge removed
-- partiton 2...
-- SQL Server always numbers the data based on the CURRENT
-- number of partitions so if you run the query again you 
-- will see ONLY 23 partitions but the partition numbers
-- will be 2, 3, etc. even though NO DATA HAS MOVED (only 
-- the logical partition numbers have changed).
-------------------------------------------------------

SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM Orders
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM OrderDetails
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

-------------------------------------------------------
-- This also removes the filegroup associated with the
-- partition scheme (meaning that [FG1] filegroup is 
-- no longer associated. If you want to roll the new data
-- through the same existing 24 partitions then you
-- will need to make FG1 next used again.
-------------------------------------------------------

--Use the following query to see to see ALL filegroups
SELECT * FROM sys.filegroups

-- Use the following query to see to see ONLY the filegroups
-- associated with OrdersRange

-------------------------------------------------------
-- Alter the partition SCHEME to add the next partition
-------------------------------------------------------
select * from sys.partition_functions

ALTER PARTITION SCHEME TwoYearDateRangePScheme NEXT USED [FG1]
GO

-------------------------------------------------------
-- Alter the partition function to add the new range
-------------------------------------------------------
ALTER PARTITION FUNCTION TwoYearDateRangePFN() 
SPLIT RANGE ('20041001')
GO 

-------------------------------------------------------
-- BEFORE you can add this data you must allow it.
-------------------------------------------------------
ALTER TABLE Orders
ADD CONSTRAINT OrdersRangeMaxOctober2004
	CHECK ([OrderDate] < '20041101')

ALTER TABLE Orders
ADD CONSTRAINT OrdersRangeMinNovember2002
	CHECK ([OrderDate] >= '20021101')

ALTER TABLE Orders
DROP CONSTRAINT OrdersRangeYearCK
go

ALTER TABLE OrderDetails
ADD CONSTRAINT OrderDetailsRangeMaxOctober2004
	CHECK ([OrderDate] < '20041101')

ALTER TABLE OrderDetails
ADD CONSTRAINT OrderDetailsRangeMinNovember2002
	CHECK ([OrderDate] >= '20021101')

ALTER TABLE OrderDetails
DROP CONSTRAINT OrderDetailsRangeYearCK
go

-------------------------------------------------------
-- "Switch" the new partition in.
-------------------------------------------------------
ALTER TABLE OrdersOctober2004
SWITCH TO Orders PARTITION 25
GO

ALTER TABLE OrderDetailsOctober2004
SWITCH TO OrderDetails PARTITION 25
GO
-------------------------------------------------------
-- Verify Date Ranges for partitions
-------------------------------------------------------
SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM Orders
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

-------------------------------------------------------
-- Drop the staging tables
-------------------------------------------------------
DROP TABLE dbo.OrdersOctober2002
GO

DROP TABLE dbo.OrdersOctober2004
GO

-------------------------------------------------------
-- Backup the filegroup
-------------------------------------------------------
BACKUP DATABASE PartitionedSalesDB 
	FILEGROUP = N'FG1' 
TO DISK = N'D:\SQLskills\PartitionedSalesDB\PartitionedSalesDB.bak'
GO