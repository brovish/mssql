/*============================================================================
  File:     TempdbAnnotated.sql

  Summary:  Stored proc to drive tempdb space usage - annotated

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

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

USE [msdb]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[MyStoredProc]'))
DROP PROCEDURE [dbo].[PSR_MyStoredProc]
GO

CREATE PROCEDURE [PSR_MyStoredProc]
AS
BEGIN

-- Initial
DECLARE @SPID INT
DECLARE @HighestInternal INT
DECLARE @LastInternal INT
DECLARE @ThisInternal INT
DECLARE @CurrentDiff INT
Declare @Detailed INT
SELECT @SPID = 55 -- ********* CHANGE THIS *********
Select @Detailed = 1
SELECT @HighestInternal = 0
SELECT @LastInternal =  [internal_objects_alloc_page_count]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID

-- Pre-aggregate data into tempdb

SELECT * INTO [#TempCustomers]
FROM [SalesDB].[dbo].[Customers];

CREATE NONCLUSTERED INDEX [#TC_CustomerID]
ON [#TempCustomers] ([CustomerID]);

-- In code
SELECT @ThisInternal = [internal_objects_alloc_page_count]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID
SET @CurrentDiff = @ThisInternal - @LastInternal
SET @LastInternal = @ThisInternal
IF @CurrentDiff > @HighestInternal SET @HighestInternal = @CurrentDiff

If @Detailed = 1
SELECT 1, [user_objects_alloc_page_count]-[user_objects_dealloc_page_count] AS [User],
@HighestInternal AS [Internal],
([user_objects_alloc_page_count]-[user_objects_dealloc_page_count]) + @HighestInternal AS [Total]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID

SELECT * INTO [#TempProducts]
FROM [SalesDB].[dbo].[Products];

CREATE NONCLUSTERED INDEX [#TP_ProductID]
ON [#TempProducts] ([ProductID]);
CREATE NONCLUSTERED INDEX [#TP_Price]
ON [#TempProducts] ([Price]);

-- In code
SELECT @ThisInternal = [internal_objects_alloc_page_count]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID
SET @CurrentDiff = @ThisInternal - @LastInternal
SET @LastInternal = @ThisInternal
IF @CurrentDiff > @HighestInternal SET @HighestInternal = @CurrentDiff

If @Detailed = 1
SELECT 2, [user_objects_alloc_page_count]-[user_objects_dealloc_page_count] AS [User],
@HighestInternal AS [Internal],
([user_objects_alloc_page_count]-[user_objects_dealloc_page_count]) + @HighestInternal AS [Total]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID

SELECT * INTO [#TempSales]
FROM [SalesDB].[dbo].[Sales];

CREATE NONCLUSTERED INDEX [#TS_SalesID]
ON [#TempSales] ([SalesID]);
CREATE NONCLUSTERED INDEX [#TS_CustomerID]
ON [#TempSales] ([CustomerID]);
CREATE NONCLUSTERED INDEX [#TS_ProductID]
ON [#TempSales] ([ProductID]);

-- In code
SELECT @ThisInternal = [internal_objects_alloc_page_count]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID
SET @CurrentDiff = @ThisInternal - @LastInternal
SET @LastInternal = @ThisInternal
IF @CurrentDiff > @HighestInternal SET @HighestInternal = @CurrentDiff

If @Detailed = 1
SELECT 3, [user_objects_alloc_page_count]-[user_objects_dealloc_page_count] AS [User],
@HighestInternal AS [Internal],
([user_objects_alloc_page_count]-[user_objects_dealloc_page_count]) + @HighestInternal AS [Total]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID

SELECT
	[tp].[Name] AS [Product],
	SUM ([ts].[Quantity]) AS [Quantity],
	[tp].[Price] AS [Amount]
FROM [#TempProducts] AS [tp]
JOIN [#TempSales] AS [ts]
	ON [ts].[ProductID] = [tp].[ProductID]
GROUP BY [tp].[Name], [tp].[Price]
ORDER BY [tp].[Name];

-- Final
SELECT [user_objects_alloc_page_count]-[user_objects_dealloc_page_count] AS [User],
@HighestInternal AS [Internal],
([user_objects_alloc_page_count]-[user_objects_dealloc_page_count]) + @HighestInternal AS [Total]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID

END
GO

