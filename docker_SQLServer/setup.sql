-- RESTORE DATABASE AdventureWorks2014 FROM DISK = '/var/backups/AdventureWorks2014.bak'
--  WITH
--  MOVE 'AdventureWorks2014_Data' TO '/var/opt/mssql/data/Adventureworks2014.mdf',
--  MOVE 'AdventureWorks2014_Log' TO '/var/opt/mssql/data/Adventureworks2014.ldf'

CREATE DATABASE heroes;
GO
USE heroes;
GO
CREATE TABLE HeroValue (id INT, name VARCHAR(50));
GO