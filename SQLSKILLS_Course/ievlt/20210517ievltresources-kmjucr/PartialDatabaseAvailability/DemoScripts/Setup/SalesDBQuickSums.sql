/*============================================================================
  File:     SalesDBQuckSums.sql

  Summary:  Getting the quick sample values from the Sample DB for Always On demos.
  
  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by SQLskills.com

  (c) SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
go

SET NOCOUNT OFF
go

USE SalesDB
go

SELECT COUNT(*) AS [Sales TotalRowCount]
FROM Sales
go
SELECT SalesPersonID, sum(quantity) AS [TotalSalesBySalesPerson]
FROM Sales
GROUP BY SalesPersonID
ORDER BY 2 desc
go

SELECT ProductID, sum(quantity) AS [TotalSalesByProduct]
FROM Sales
GROUP BY ProductID
ORDER BY 2 desc
go

SELECT CustomerID, sum(quantity) AS [TotalSalesByCustomer]
FROM Sales
GROUP BY CustomerID
ORDER BY 1 desc
go