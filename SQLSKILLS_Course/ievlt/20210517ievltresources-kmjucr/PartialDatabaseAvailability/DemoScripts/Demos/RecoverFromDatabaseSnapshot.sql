/*============================================================================
  File:     RecoverFromDatabaseSnapshot.sql

  Summary:  Create, drop and recover... using 2005 ENTERPRISE Engine
			Database Snapshots.

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

USE [SalesDB]
GO

sp_helpfile
go

CREATE DATABASE [SalesDB_Snapshot] 
ON
( NAME = N'SalesDBData', FILENAME = N'C:\SQLskills\SalesDBData.mdfss')
AS SNAPSHOT OF SalesDB
GO

-- Checkout the ACTUAL file size rather than the appearance of the file's size!
SELECT db_name(v.database_id) AS [Database Name]
	, v.file_id AS [File ID]
	, f.[name] AS [Database File Name]
	, CASE 
			WHEN f.is_sparse = 0 THEN 'No'
			ELSE 'Yes' 
	  END AS [Sparse File]
	, f.[name] AS [File Name]
	, v.size_on_disk_bytes/1024 AS [PHYSICAL Size (KB)]
	, f.[size]*8/1024 AS [LOGICAL Size (MB)]
	, f.physical_name AS [Physical File Name]
FROM sys.dm_io_virtual_file_stats(db_id('SalesDB_Snapshot'), -1) AS v
	JOIN sys.master_files AS f ON v.file_id = f.file_id
WHERE f.database_id = v.database_id
	AND f.database_id = db_id('SalesDB_Snapshot')
go

USE SalesDB
go

DROP TABLE Sales
go

-- Phew - we have a DB Snapshot...

USE SalesDB_Snapshot
go

SELECT count(*) FROM Sales
go

-- Should we set the database to restricted access? Probably!
USE master
go

ALTER DATABASE SalesDB
	SET RESTRICTED_USER
	WITH ROLLBACK IMMEDIATE 
go

-- Now we need to recreate the sales table...

-- Finally, we can recover all of the sales data from an INSERT/SELECT

SET IDENTITY_INSERT SalesDB.dbo.Sales ON
go

INSERT SalesDB.dbo.Sales
		( SalesID
		, SalesPersonID
		, CustomerID
		, ProductID
		, Quantity)
SELECT *
	FROM [SalesDB_Snapshot].dbo.Sales 
	WHERE SalesID < 100000
go

DBCC CHECKIDENT('Sales')
go

--DBCC CHECKIDENT('Sales', RESEED)
--go

USE master
go

ALTER DATABASE SalesDB
	SET MULTI_USER
	WITH ROLLBACK IMMEDIATE 
go

