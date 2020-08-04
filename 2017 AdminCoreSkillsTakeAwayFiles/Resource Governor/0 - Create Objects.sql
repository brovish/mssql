USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'RGovernor')
  DROP DATABASE RGovernor;
GO

CREATE DATABASE RGovernor;
GO

USE RGovernor;
GO

SELECT * INTO dbo.Product
FROM AdventureWorks2008.Production.Product;
GO

ALTER TABLE dbo.Product
  ADD CONSTRAINT PK_Product PRIMARY KEY (ProductID);
GO

USE master;
GO

IF EXISTS(SELECT 1 FROM syslogins WHERE name = 'MyFriendBill')
  DROP LOGIN MyFriendBill;
GO

CREATE LOGIN MyFriendBill 
  WITH PASSWORD = 'MyFriendBill', CHECK_POLICY = OFF;
GO

IF EXISTS(SELECT 1 FROM syslogins WHERE name = 'AnnoyingAccessUserOnFloor5')
  DROP LOGIN AnnoyingAccessUserOnFloor5;
GO

CREATE LOGIN AnnoyingAccessUserOnFloor5 
  WITH PASSWORD = 'AnnoyingAccessUserOnFloor5', CHECK_POLICY = OFF;
GO

USE RGovernor;
GO

CREATE USER MyFriendBill FOR LOGIN MyFriendBill;
GO
GRANT SELECT ON SCHEMA::dbo TO MyFriendBill;
GO

CREATE USER AnnoyingAccessUserOnFloor5 FOR LOGIN AnnoyingAccessUserOnFloor5;
GO
GRANT SELECT ON SCHEMA::dbo TO AnnoyingAccessUserOnFloor5;
GO

USE master;
GO