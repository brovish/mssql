-- external volume or not, restore will overwrite the db if it already exists(the replace option is only to force overwrite 
-- if tail of log not backed up?). Therefore when we start the image, we always get a fresh copy 
RESTORE DATABASE AdventureWorks2017 FROM DISK = '/usr/work/database_backups/AdventureWorks2017.bak'
 WITH
 MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf',
 MOVE 'AdventureWorks2017_Log' TO '/var/opt/mssql/data/AdventureWorks2017.ldf'
GO

ALTER DATABASE AdventureWorks2017 SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 300, INTERVAL_LENGTH_MINUTES = 1, MAX_STORAGE_SIZE_MB = 20, MAX_PLANS_PER_QUERY = 10);
GO

RESTORE DATABASE [WideWorldImporters] FROM  DISK = N'/usr/work/database_backups/wwi.bak' 
    WITH   
    MOVE N'WWI_Primary' TO N'/var/opt/mssql/data/WideWorldImporters.mdf',  
    MOVE N'WWI_UserData' TO N'/var/opt/mssql/data/WideWorldImporters_UserData.ndf',  
    MOVE N'WWI_Log' TO N'/var/opt/mssql/data/WideWorldImporters.ldf',  
    MOVE N'WWI_InMemory_Data_1' TO N'/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1'
GO

ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 300, INTERVAL_LENGTH_MINUTES = 1, MAX_STORAGE_SIZE_MB = 20, MAX_PLANS_PER_QUERY = 10);
GO

RESTORE DATABASE AdventureWorksDW2016 FROM DISK = '/usr/work/database_backups/AdventureWorksDW2016.bak'
 WITH
 MOVE 'AdventureWorksDW2016_Data' TO '/var/opt/mssql/data/AdventureWorksDW2016.mdf',
 MOVE 'AdventureWorksDW2016_Log' TO '/var/opt/mssql/data/AdventureWorksDW2016.ldf'
GO

ALTER DATABASE AdventureWorksDW2016 SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 300, INTERVAL_LENGTH_MINUTES = 1, MAX_STORAGE_SIZE_MB = 20, MAX_PLANS_PER_QUERY = 10);
GO

-- scripts will like these will persist the data changes over container restarts as well as image rebuilds 
-- if you are using external volume 
CREATE DATABASE heroes;
GO
USE heroes;
GO
CREATE TABLE HeroValue (id INT, name VARCHAR(50));
GO

-- server info 
SELECT @@SERVERNAME,
    -- SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
    -- SERVERPROPERTY('MachineName'),
    -- SERVERPROPERTY('ServerName'),
    @@version;
go