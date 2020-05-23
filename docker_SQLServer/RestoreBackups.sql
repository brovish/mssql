RESTORE DATABASE AdventureWorks2017 FROM DISK = '/usr/work/database_backups/AdventureWorks2017.bak'
 WITH
 MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf',
 MOVE 'AdventureWorks2017_Log' TO '/var/opt/mssql/data/AdventureWorks2017.ldf'

CREATE DATABASE heroes;
GO
USE heroes;
GO
CREATE TABLE HeroValue (id INT, name VARCHAR(50));
GO

-- server info 
SELECT @@SERVERNAME,
    SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
    SERVERPROPERTY('MachineName'),
    SERVERPROPERTY('ServerName'),
    @@version;
go