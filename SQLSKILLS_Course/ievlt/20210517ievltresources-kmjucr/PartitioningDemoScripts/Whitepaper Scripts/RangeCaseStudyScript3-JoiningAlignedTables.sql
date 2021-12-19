/*============================================================================
  File:     RangeCaseStudyScript3-JoiningAlignedTables.sql

  MSDN Whitepaper: Partitioned Tables and Indexes in SQL Server 2005
  http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnsql90/html/sql2k5partition.asp

  Summary:  This script was originally included with the Partitioned Tables 
			and Indexes Whitepaper released on MSDN and written by Kimberly
			L. Tripp. To get more details about this whitepaper please 
			access the whitepaper on MSDN.

			This script is used to view the showplan for joining aligned
			partitioned tables.

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

SELECT [o].[OrderID], [o].[OrderDate], [o].[VendorID], [od].[ProductID], [od].[OrderQty]
FROM [dbo].[Orders] AS [o]
	INNER JOIN [dbo].[OrderDetails] AS [od] 
            ON [o].[OrderID] = [od].[OrderID]
					AND [o].[OrderDate] = [od].[OrderDate]
WHERE [o].[OrderDate] >= '20040701' 
		AND [o].[OrderDate] <= '20040930 11:59:59.997';
go
	
-------------------------------------------------------
-- Reminder (from previous exercise) 
-- Verify Partition Ranges using the Partition Function
-------------------------------------------------------

SELECT $partition.TwoYearDateRangePFN([o].[OrderDate]) 
			AS [Partition Number]
	, min([o].[OrderDate]) AS [Min Order Date]
	, max([o].[OrderDate]) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM [dbo].[Orders] AS [o]
WHERE $partition.TwoYearDateRangePFN([o].[OrderDate]) IN (21, 22, 23)
GROUP BY $partition.TwoYearDateRangePFN([o].[OrderDate])
ORDER BY [Partition Number];
go

SELECT $partition.TwoYearDateRangePFN([od].[OrderDate]) 
			AS [Partition Number]
	, min([od].[OrderDate]) AS [Min Order Date]
	, max([od].[OrderDate]) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM [dbo].[OrderDetails] AS [od]
WHERE $partition.TwoYearDateRangePFN([od].[OrderDate]) IN (21, 22, 23)
GROUP BY $partition.TwoYearDateRangePFN([od].[OrderDate])
ORDER BY [Partition Number];
go