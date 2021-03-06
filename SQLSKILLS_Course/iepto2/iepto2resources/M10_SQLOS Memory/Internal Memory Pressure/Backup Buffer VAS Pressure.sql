
-- 4MB * 16 Buffers = 64MB of backup buffers
BACKUP DATABASE [AdventureWorks2008R2] 
TO		DISK = N'C:\SQLskills\AdventureWorks2008R2.bak' 
WITH	INIT,  
		NAME = N'AdventureWorks2008R2-Full Database Backup', 
		STATS = 10,
		MAXTRANSFERSIZE = 4194304,
		BUFFERCOUNT = 16,
		COMPRESSION;
GO


-- 4MB * 64 Buffers = 256MB of backup buffers
BACKUP DATABASE [AdventureWorks2008R2] 
TO		DISK = N'C:\SQLskills\AdventureWorks2008R2.bak' 
WITH	INIT,  
		NAME = N'AdventureWorks2008R2-Full Database Backup', 
		STATS = 10,
		MAXTRANSFERSIZE = 4194304,
		BUFFERCOUNT = 64,
		COMPRESSION;
GO
