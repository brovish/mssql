-- AD208 LabSetup

USE master;
GO


EXEC sp_configure 'show advanced options',1;
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell',1;
RECONFIGURE;
GO

-- From AD202

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'WarehouseManagement') 
BEGIN
  ALTER DATABASE WarehouseManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE WarehouseManagement;
END;
GO

CREATE DATABASE WarehouseManagement
ON PRIMARY 
( NAME = wm_systemdata,
  FILENAME = 'C:\SQLData\warehousemanagement.mdf',
  SIZE = 10MB,
  FILEGROWTH = 1MB,
  MAXSIZE = UNLIMITED
),
FILEGROUP USERDATA DEFAULT
( NAME = wm_userdata,
  FILENAME = 'C:\SQLData\warehousemanagement_user.ndf',
  SIZE = 100MB,
  FILEGROWTH = 10MB,
  MAXSIZE = UNLIMITED
),
FILEGROUP ARCHIVEDATA
( NAME = wm_archivedata,
  FILENAME = 'C:\SQLData\warehousemanagement_archive.ndf',
  SIZE = 200MB,
  FILEGROWTH = 10MB,
  MAXSIZE = UNLIMITED
)
LOG ON
( NAME = wm_log,
  FILENAME = 'C:\SQLLogs\warehousemanagement.ldf',
  SIZE = 100MB,
  FILEGROWTH = 5MB,
  MAXSIZE = UNLIMITED
);
GO

-- Added as starter for AD205

USE WarehouseManagement;
GO

CREATE SCHEMA Reports AUTHORIZATION dbo;
GO

CREATE SCHEMA Barcode AUTHORIZATION dbo;
GO

CREATE SCHEMA Warehouse AUTHORIZATION dbo;
GO

CREATE SCHEMA Sales AUTHORIZATION dbo;
GO

CREATE SCHEMA [Admin] AUTHORIZATION dbo;
GO

CREATE SCHEMA DBA AUTHORIZATION dbo;
GO

EXEC xp_cmdshell 'NET USER BelaLugosi SQLRocks! /ADD /FULLNAME:"Bela Lugosi" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER EarthaKitt SQLRocks! /ADD /FULLNAME:"Eartha Kitt" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER ErnestBorgnine SQLRocks! /ADD /FULLNAME:"Ernest Borgnine" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER GaleStorm SQLRocks! /ADD /FULLNAME:"Gale Storm" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER HumphreyBogart SQLRocks! /ADD /FULLNAME:"Humphrey Bogart" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER JackKlugman SQLRocks! /ADD /FULLNAME:"Jack Klugman" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER JonathanWinters SQLRocks! /ADD /FULLNAME:"Jonathan Winters" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER LonChaney SQLRocks! /ADD /FULLNAME:"Lon Chaney" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER LynnRedgrave SQLRocks! /ADD /FULLNAME:"Lynn Redgrave" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER RichardBriers SQLRocks! /ADD /FULLNAME:"Richard Briers" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER RichardGriffiths SQLRocks! /ADD /FULLNAME:"Richard Griffiths" /PASSWORDCHG:NO';

EXEC xp_cmdshell 'NET USER RichardDawson SQLRocks! /ADD /FULLNAME:"Richard Dawson" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER SsasService SQLRocks! /ADD /FULLNAME:"SSAS Service Account" /PASSWORDCHG:NO';

EXEC xp_cmdshell 'NET LOCALGROUP DBATeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP DBATeam HumphreyBogart /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP DBATeam LynnRedgrave /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam ErnestBorgnine /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam HumphreyBogart /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam JonathanWinters /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam LonChaney /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam EarthaKitt /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam LonChaney /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam RichardBriers /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam RichardGriffiths /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam GaleStorm /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam JonathanWinters /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam SandraBullock /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam TomHanks /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam BelaLugosi /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam ErnestBorgnine /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam JackKlugman /ADD';
GO

USE WarehouseManagement;
GO

CREATE TABLE Sales.BusinessCategories
( BusinessCategoryID int IDENTITY(1,1)
    CONSTRAINT PK_BusinessCategories PRIMARY KEY,
  BusinessCategoryName nvarchar(50) NOT NULL
);
GO

CREATE TABLE Sales.Customers 
( CustomerID int IDENTITY(1,1) 
    CONSTRAINT PK_Customers PRIMARY KEY,
  CustomerName nvarchar(50) NOT NULL,
  BusinessCategoryID int NOT NULL
    CONSTRAINT FK_Customers_BusinessCategories 
    FOREIGN KEY REFERENCES Sales.BusinessCategories(BusinessCategoryID),
  IsActive bit
    CONSTRAINT DF_Customers_IsActive DEFAULT (1)
);
GO

CREATE TABLE Reports.Settings
( SettingID int IDENTITY(1,1)
    CONSTRAINT PK_Settings PRIMARY KEY,
  SettingName nvarchar(50) NOT NULL,
  SettingValue nvarchar(100) NOT NULL
);
GO

CREATE PROC Reports.GetCustomerLookupList
AS
BEGIN
  SELECT CustomerID, CustomerName 
  FROM Sales.Customers 
  ORDER BY CustomerID;
END;
GO

CREATE PROC Reports.GetActiveCustomerLookupList
AS
BEGIN
  SELECT CustomerID, CustomerName 
  FROM Sales.Customers 
  WHERE IsActive <> 0
  ORDER BY CustomerID;
END;
GO
------------------ AD205 Changes ---------------

USE WarehouseManagement;
GO

CREATE SCHEMA Staging AUTHORIZATION dbo;
GO

USE master;
GO

CREATE LOGIN [SDUPROD\DBATeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\ManagementTeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\ReportingTeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\SalesTeam] FROM WINDOWS;
GO

CREATE LOGIN [SDUPROD\JackKlugman] FROM WINDOWS;
GO

CREATE LOGIN [SDUPROD\ErnestBorgnine] FROM WINDOWS;
GO

CREATE LOGIN [SDUPROD\RichardDawson] FROM WINDOWS;
GO

CREATE LOGIN ReadyToScan WITH PASSWORD = 'SQLRocks!', CHECK_POLICY = OFF;
GO
 
ALTER SERVER ROLE sysadmin ADD MEMBER [SDUPROD\DBATeam];
GO

USE WarehouseManagement;
GO

CREATE ROLE SalesManagers;
GO

------------------ AD206 Changes ----------------------

USE master;
GO

GRANT ALTER TRACE TO [SDUPROD\RichardDawson];
GO

USE WarehouseManagement;
GO

CREATE USER [SDUPROD\DBATeam] FOR LOGIN [SDUPROD\DBATeam];
GO
CREATE USER [SDUPROD\ManagementTeam] FOR LOGIN [SDUPROD\ManagementTeam];
GO
CREATE USER [SDUPROD\ReportingTeam] FOR LOGIN [SDUPROD\ReportingTeam];
GO
CREATE USER [SDUPROD\SalesTeam] FOR LOGIN [SDUPROD\SalesTeam];
GO

CREATE USER [SDUPROD\JackKlugman] FOR LOGIN [SDUPROD\JackKlugman];
GO
CREATE USER [SDUPROD\ErnestBorgnine] FOR LOGIN [SDUPROD\ErnestBorgnine];
GO

CREATE USER ReadyToScan FOR LOGIN ReadyToScan;
GO

ALTER ROLE SalesManagers 
  ADD MEMBER [SDUPROD\ErnestBorgnine];
GO

GRANT EXECUTE ON SCHEMA::Reports TO [SDUPROD\ReportingTeam];
GO

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Barcode TO ReadyToScan;
GO

GRANT SELECT ON SCHEMA::Sales TO [SDUPROD\SalesTeam];
GO

GRANT CONTROL ON SCHEMA::Staging TO [SDUPROD\ReportingTeam];
GO

GRANT EXECUTE ON SCHEMA::Warehouse TO [SDUPROD\WarehouseTeam];
GO

GRANT SELECT ON SCHEMA::Staging TO [SDUPROD\SsasService];
GO

GRANT INSERT, UPDATE ON Sales.Customers TO [SDUPROD\SalesTeam];
GO

GRANT INSERT, UPDATE, DELETE ON Sales.BusinessCategories TO SalesManagers;
GO

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Sales TO [SDUPROD\JackKlugman];
GO

------------------ Cleanup ---------------------

USE master;
GO

EXEC sp_configure 'xp_cmdshell',0;
RECONFIGURE;
GO

