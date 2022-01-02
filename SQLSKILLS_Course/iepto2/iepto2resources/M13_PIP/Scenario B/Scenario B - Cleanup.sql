EXEC [master].[sys].[sp_configure] 'show advanced options', 1;
RECONFIGURE;
GO

EXEC [master].[sys].[sp_configure] 'max server memory', 3500;
RECONFIGURE;
GO

EXEC [master].[sys].[sp_configure] 'show advanced options', 0;
RECONFIGURE;
GO

USE [master]
RESTORE DATABASE [Credit] FROM  DISK = N'C:\Temp\ORIGINAL_CreditBackup100.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5

GO

