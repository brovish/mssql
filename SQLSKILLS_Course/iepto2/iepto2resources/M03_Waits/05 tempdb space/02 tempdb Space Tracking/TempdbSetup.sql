/*============================================================================
  File:     TempdbSetup.sql

  Summary:  Stored proc to drive tempdb space usage

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
DROP PROCEDURE [dbo].[MyStoredProc]
GO

CREATE PROCEDURE [MyStoredProc]
AS
BEGIN

-- Pre-aggregate data into tempdb
SELECT * INTO [#TempCustomers]
FROM [SalesDB].[dbo].[Customers];

CREATE NONCLUSTERED INDEX [#TC_CustomerID]
ON [#TempCustomers] ([CustomerID]);

SELECT * INTO [#TempProducts]
FROM [SalesDB].[dbo].[Products];

CREATE NONCLUSTERED INDEX [#TP_ProductID]
ON [#TempProducts] ([ProductID]);
CREATE NONCLUSTERED INDEX [#TP_Price]
ON [#TempProducts] ([Price]);


SELECT * INTO [#TempSales]
FROM [SalesDB].[dbo].[Sales];

CREATE NONCLUSTERED INDEX [#TS_SalesID]
ON [#TempSales] ([SalesID]);
CREATE NONCLUSTERED INDEX [#TS_CustomerID]
ON [#TempSales] ([CustomerID]);
CREATE NONCLUSTERED INDEX [#TS_ProductID]
ON [#TempSales] ([ProductID]);


SELECT
	[tp].[Name] AS [Product],
	SUM ([ts].[Quantity]) AS [Quantity],
	[tp].[Price] AS [Amount]
FROM [#TempProducts] AS [tp]
JOIN [#TempSales] AS [ts]
	ON [ts].[ProductID] = [tp].[ProductID]
GROUP BY [tp].[Name], [tp].[Price]
ORDER BY [tp].[Name];
END
GO
