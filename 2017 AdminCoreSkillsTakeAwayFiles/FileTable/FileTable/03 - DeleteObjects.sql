USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DocumentData') BEGIN
  ALTER DATABASE DocumentData SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DocumentData;
END;

EXEC sp_configure @configname = 'show advanced options', @configvalue = 1;
GO
RECONFIGURE;
GO

EXEC sp_configure @configname = 'xp_cmdshell', @configvalue = 1;
GO
RECONFIGURE;
GO

EXEC xp_cmdshell 'IF EXIST C:\ExternalAccess RMDIR C:\ExternalAccess /S /Q';
GO

