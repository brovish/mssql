/*============================================================================
  File:     IsolateLargeCriticalTable_ONLINE.sql

  Summary:  Can we isolate ONLY this table to take only the table offline.
			This STILL allows us to backup the transaction log AND it keeps
			users from seeing the damaged data. Depending on the table lost,
			you might still want to take the entire database offline.
  
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

USE SalesDB
go

ALTER DATABASE [SalesDB] 
ADD FILEGROUP SalesDataFG
go

ALTER DATABASE [SalesDB]
ADD FILE
(	NAME = N'SalesDBSalesData'
	, FILENAME = N'D:\SQLskills\SalesDBSalesData.ndf' 
	, SIZE = 400
	, MAXSIZE = 600
	, FILEGROWTH = 50)
TO FILEGROUP SalesDataFG
GO

sp_helpfile;
GO

sp_helpindex Sales;
GO

CREATE UNIQUE CLUSTERED INDEX SalesPK 
ON Sales (SalesID)
WITH (DROP_EXISTING = ON, ONLINE = ON)
ON SalesDataFG;	
GO

sp_helpindex Sales
go
-- Don't forget to setup for the Partitioning scenario!