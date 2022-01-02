/*============================================================================
  File:     01a_Build_CCI_Tables.sql

  SQL Server Versions: 2016 onwards
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
USE [master];
GO
RESTORE DATABASE [ContosoRetailDW] 
	FROM  DISK = N'C:\Backups\ContosoRetailDW.bak' 
	WITH  FILE = 1,  
	MOVE N'ContosoRetailDW2.0' TO N'C:\Databases\ContosoRetailDW.mdf',  
	MOVE N'ContosoRetailDW2.0_log' TO N'C:\Databases\ContosoRetailDW.ldf',   
	REPLACE,  
	STATS = 5;
GO
*/

USE [ContosoRetailDW];
GO

/*
	Ensure statistics are fully updated
*/
UPDATE STATISTICS dbo.FactSales WITH FULLSCAN;
GO


/*
	Create a new table and copy data
	from dbo.FactSales into it
*/
IF OBJECT_ID('FastSales_CCI') IS NOT NULL
BEGIN
	DROP TABLE dbo.FactSales_CCI;
END
GO
CREATE TABLE dbo.FactSales_CCI
	(
	SalesKey int NOT NULL IDENTITY (1, 1),
	DateKey datetime NOT NULL,
	channelKey int NOT NULL,
	StoreKey int NOT NULL,
	ProductKey int NOT NULL,
	PromotionKey int NOT NULL,
	CurrencyKey int NOT NULL,
	UnitCost money NOT NULL,
	UnitPrice money NOT NULL,
	SalesQuantity int NOT NULL,
	ReturnQuantity int NOT NULL,
	ReturnAmount money NULL,
	DiscountQuantity int NULL,
	DiscountAmount money NULL,
	TotalCost money NOT NULL,
	SalesAmount money NOT NULL,
	ETLLoadID int NULL,
	LoadDate datetime NULL,
	UpdateDate datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.FactSales_CCI ON
GO
IF EXISTS(SELECT * FROM dbo.FactSales)
	 EXEC('INSERT INTO dbo.FactSales_CCI (SalesKey, DateKey, channelKey, StoreKey, ProductKey, PromotionKey, CurrencyKey, UnitCost, UnitPrice, SalesQuantity, ReturnQuantity, ReturnAmount, DiscountQuantity, DiscountAmount, TotalCost, SalesAmount, ETLLoadID, LoadDate, UpdateDate)
		SELECT SalesKey, DateKey, channelKey, StoreKey, ProductKey, PromotionKey, CurrencyKey, UnitCost, UnitPrice, SalesQuantity, ReturnQuantity, ReturnAmount, DiscountQuantity, DiscountAmount, TotalCost, SalesAmount, ETLLoadID, LoadDate, UpdateDate FROM dbo.FactSales WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.FactSales_CCI OFF
GO

/*
	Create a CI on SalesKey
*/
CREATE CLUSTERED INDEX CX_FactSales_CCI ON dbo.FactSales_CCI 
	(
	SalesKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*
	Now create the clustered columnstore index
*/
CREATE CLUSTERED COLUMNSTORE INDEX CX_FactSales_CCI 
ON dbo.FactSales_CCI 
WITH(MAXDOP=1, DROP_EXISTING = ON) ON [PRIMARY]
GO

/*
	Add a PK on SalesKey
*/
ALTER TABLE dbo.FactSales_CCI ADD CONSTRAINT
	PK_FactSales_CCI_SalesKey PRIMARY KEY NONCLUSTERED 
	(
	SalesKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/*
	Create another new table and copy data
	from dbo.FactSales into it
*/
IF OBJECT_ID('FactSales_CCISorted') IS NOT NULL
BEGIN
	DROP TABLE dbo.FactSales_CCISorted;
END
GO
CREATE TABLE dbo.FactSales_CCISorted
	(
	SalesKey int NOT NULL IDENTITY (1, 1),
	DateKey datetime NOT NULL,
	channelKey int NOT NULL,
	StoreKey int NOT NULL,
	ProductKey int NOT NULL,
	PromotionKey int NOT NULL,
	CurrencyKey int NOT NULL,
	UnitCost money NOT NULL,
	UnitPrice money NOT NULL,
	SalesQuantity int NOT NULL,
	ReturnQuantity int NOT NULL,
	ReturnAmount money NULL,
	DiscountQuantity int NULL,
	DiscountAmount money NULL,
	TotalCost money NOT NULL,
	SalesAmount money NOT NULL,
	ETLLoadID int NULL,
	LoadDate datetime NULL,
	UpdateDate datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.FactSales_CCISorted ON
GO
IF EXISTS(SELECT * FROM dbo.FactSales)
	 EXEC('INSERT INTO dbo.FactSales_CCISorted (SalesKey, DateKey, channelKey, StoreKey, ProductKey, PromotionKey, CurrencyKey, UnitCost, UnitPrice, SalesQuantity, ReturnQuantity, ReturnAmount, DiscountQuantity, DiscountAmount, TotalCost, SalesAmount, ETLLoadID, LoadDate, UpdateDate)
		SELECT SalesKey, DateKey, channelKey, StoreKey, ProductKey, PromotionKey, CurrencyKey, UnitCost, UnitPrice, SalesQuantity, ReturnQuantity, ReturnAmount, DiscountQuantity, DiscountAmount, TotalCost, SalesAmount, ETLLoadID, LoadDate, UpdateDate FROM dbo.FactSales WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.FactSales_CCISorted OFF
GO

/*
	Create a CI that leads on Datekey
*/
CREATE CLUSTERED INDEX CX_FactSales_CCISorted ON dbo.FactSales_CCISorted
	(
	DATEKEY, StoreKey, ProductKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*
	Now create the clustered columnstore index
*/
CREATE CLUSTERED COLUMNSTORE INDEX CX_FactSales_CCISorted 
ON dbo.FactSales_CCISorted WITH(MAXDOP=1, DROP_EXISTING = ON) ON [PRIMARY]
GO

/*
	Add a PK on SalesKey
*/
ALTER TABLE dbo.FactSales_CCISorted ADD CONSTRAINT
	PK_FactSales_CCISorted_SalesKey PRIMARY KEY NONCLUSTERED 
	(
	SalesKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
