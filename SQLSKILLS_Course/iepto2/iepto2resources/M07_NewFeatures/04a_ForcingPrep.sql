/*============================================================================
  File:     04a_ForcingPred.sql

  SQL Server Versions: 2016, 2017, 2019
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*
	Start with a clean copy of WWI
*/
USE [master];
GO
RESTORE DATABASE [WideWorldImporters] 
FROM  DISK = N'C:\Backups\WideWorldImportersEnlarged.bak' 
WITH  FILE = 1,  
MOVE N'WWI_Primary' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters.mdf',  
MOVE N'WWI_UserData' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters_UserData.ndf',  
MOVE N'WWI_Log' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters.ldf',  
MOVE N'WWI_InMemory_Data_1' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters_InMemory_Data_1',  
NOUNLOAD, 
REPLACE, 
STATS = 5;
GO


/*
	Enable Query Store with settings we want
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), 
	DATA_FLUSH_INTERVAL_SECONDS = 60,  
	INTERVAL_LENGTH_MINUTES = 10, 
	MAX_STORAGE_SIZE_MB = 100, 
	QUERY_CAPTURE_MODE = ALL, 
	SIZE_BASED_CLEANUP_MODE = AUTO, 
	MAX_PLANS_PER_QUERY = 200)
GO

/*
	Clear out any old data, just in case
*/
ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE CLEAR;
GO


/*
	Create a procedure for testing
*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_GetFullProductInfo];
GO

CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]
	@StockItemID INT
AS	

	SELECT 
		[o].[CustomerID], 
		[o].[OrderDate], 
		[ol].[StockItemID], 
		[ol].[Quantity],
		[ol].[UnitPrice]
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	ORDER BY [o].[OrderDate] DESC;

	SELECT
		[o].[CustomerID], 
		SUM([ol].[Quantity]*[ol].[UnitPrice])
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	GROUP BY [o].[CustomerID]
	ORDER BY [o].[CustomerID] ASC;
GO

/*
	Run SP
*/
EXEC [Sales].[usp_GetFullProductInfo] 90 WITH RECOMPILE;
GO

EXEC [Sales].[usp_GetFullProductInfo] 224 WITH RECOMPILE;
GO


/*
	Add some data...as may happen during a normal day
*/
INSERT INTO [Sales].[OrderLines]
	([OrderLineID], [OrderID], [StockItemID], 
	[Description], [PackageTypeID], [Quantity], 
	[UnitPrice], [TaxRate], [PickedQuantity], 
	[PickingCompletedWhen], [LastEditedBy], 
	[LastEditedWhen])
SELECT 
	[OrderLineID] + 800000, [OrderID], [StockItemID], 
	[Description], [PackageTypeID], [Quantity] + 2, 
	[UnitPrice], [TaxRate], [PickedQuantity], 
	NULL, [LastEditedBy], SYSDATETIME() 
FROM [WideWorldImporters].[Sales].[OrderLines]
WHERE [OrderID] > 54999;
GO


/*
	Re-run the stored procedures
*/	
EXEC [Sales].[usp_GetFullProductInfo] 90 WITH RECOMPILE;
GO

EXEC [Sales].[usp_GetFullProductInfo] 224 WITH RECOMPILE;
GO


