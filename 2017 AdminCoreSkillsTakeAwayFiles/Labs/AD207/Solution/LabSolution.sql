-- AD207 Solution

-- Exercise 1

USE master;
GO

SELECT * FROM sys.dm_database_encryption_keys;
GO

-- Exercise 2

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SQLRocks!';
GO

CREATE CERTIFICATE WarehouseManagementTDECert WITH SUBJECT = 'TDE Certificate for WarehouseManagement Database';
GO

-- Exercise 3

BACKUP CERTIFICATE WarehouseManagementTDECert TO FILE = 'C:\Labs\AD207\WarehouseManagementTDECert.cer'
  WITH PRIVATE KEY ( FILE = 'C:\Labs\AD207\WarehouseManagementTDECert.pvk',
                     ENCRYPTION BY PASSWORD = 'SQLRocks!'
                   );
GO

-- Exercise 4

USE WarehouseManagement;
GO

CREATE DATABASE ENCRYPTION KEY 
  WITH ALGORITHM = AES_256
  ENCRYPTION BY SERVER CERTIFICATE WarehouseManagementTDECert;
GO

ALTER DATABASE WarehouseManagement SET ENCRYPTION ON;
GO

SELECT * FROM sys.dm_database_encryption_keys;
GO

SELECT * FROM sys.databases WHERE database_id IN (2,14);
GO
