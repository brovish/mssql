-- AD202 Solution
--  CreateWarehouseManagementDatabase.sql

USE master;
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

