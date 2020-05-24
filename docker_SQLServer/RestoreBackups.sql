-- external volume or not, restore will overwrite the db if it already exists(the replace option is only to force overwrite 
-- if tail of log not backed up?). Therefore when we start the image, we always get a fresh copy 
RESTORE DATABASE AdventureWorks2017 FROM DISK = '/usr/work/database_backups/AdventureWorks2017.bak'
 WITH
 MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf',
 MOVE 'AdventureWorks2017_Log' TO '/var/opt/mssql/data/AdventureWorks2017.ldf'
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