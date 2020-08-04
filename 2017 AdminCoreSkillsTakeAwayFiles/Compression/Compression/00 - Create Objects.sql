USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'Compression')
BEGIN
  ALTER DATABASE Compression SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE Compression;
END;
GO

CREATE DATABASE Compression;
GO

USE Compression;
GO

-- Add required objects


USE tempdb;
GO