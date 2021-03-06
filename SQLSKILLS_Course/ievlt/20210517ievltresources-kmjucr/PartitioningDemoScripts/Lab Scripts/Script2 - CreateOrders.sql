/*============================================================================
  Lab:		Range Partitions Exercise 
  File:		Script2 - CreateOrders.sql
  
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
-- Setup Script for Partitioning Exercise

-- This script creates the Orders table with the 
-- same schema as PurchaseOrderHeader.
-- INSERT SELECT is used to populate the table.
-------------------------------------------------------

USE [AdventureWorks2008Test];
GO

-------------------------------------------------------
-- Create the new Orders table.
-------------------------------------------------------

CREATE TABLE [AdventureWorks2008Test].[dbo].[Orders]
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
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL, 
	[TotalDue] [money] NULL
)
GO

-------------------------------------------------------
-- Populate with data.
-------------------------------------------------------
INSERT INTO [dbo].[Orders]
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
		WHERE ([o].[OrderDate] >= '20030701' 
				 AND [o].[OrderDate] < '20040701')
GO

-------------------------------------------------------
-- Modify Rows to later show RIGHT and LEFT in 
-- RANGE Partitions using DATETIME Data.
-------------------------------------------------------
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20030930'
	WHERE [OrderID] = 416
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20031001'
	WHERE [OrderID] = 417
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20031001 10:31am'
	WHERE [OrderID] = 418
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20031231'
	WHERE [OrderID] = 1090
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040101'
	WHERE [OrderID] = 1091
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040101 10:31am'
	WHERE [OrderID] = 1092
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040331'
	WHERE [OrderID] = 1860
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040401'
	WHERE [OrderID] = 1861
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040401 10:31am'
	WHERE [OrderID] = 1862
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040331'
	WHERE [OrderID] = 2832
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040401'
	WHERE [OrderID] = 2833
GO
UPDATE [AdventureWorks2008Test].[dbo].[Orders]
	SET [OrderDate] = '20040401 10:31am'
	WHERE [OrderID] = 2834
GO
-------------------------------------------------------
-- Optionally, verify row count of data. 
-- 2757 Rows for this date range.
-------------------------------------------------------
SELECT count(*) AS [Orders Row Count]
FROM [AdventureWorks2008Test].[dbo].[Orders]
GO