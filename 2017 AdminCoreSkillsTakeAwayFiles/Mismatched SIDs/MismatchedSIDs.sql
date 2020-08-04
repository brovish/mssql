use tempdb;
GO

DROP DATABASE Mismatch;
GO
DROP Login TestUser;
GO

CREATE DATABASE Mismatch
ON ( NAME = Mismatch_dat,
     FILENAME = 'C:\Temp\Mismatch_Data.mdf',
                   SIZE = 5,
                   MAXSIZE = 50,
                   FILEGROWTH = 5 )
LOG ON
( NAME = Mismatch_log,
    FILENAME = 'C:\Temp\Mismatch_Log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

USE Mismatch;
GO

CREATE TABLE dbo.TestTable
( TestTableID int IDENTITY,
  Description varchar(200)
);
GO

INSERT dbo.TestTable (Description) VALUES('Hello Greg');
GO

CREATE LOGIN TestUser WITH PASSWORD = 'Pa$$w0rd', CHECK_POLICY = OFF;
GO

CREATE USER TestUser FROM Login TestUser;
GO

GRANT SELECT ON dbo.TestTable TO TestUser;
GO

-- Test login for that user now

USE tempdb;
GO

EXEC sp_detach_db 'Mismatch';
GO

DROP Login TestUser;
GO

CREATE LOGIN TestUser WITH PASSWORD = 'Pa$$w0rd', CHECK_POLICY = OFF;
GO

CREATE DATABASE Mismatch
ON ( NAME = Mismatch_dat,
     FILENAME = 'C:\Temp\Mismatch_Data.mdf',
                   SIZE = 5,
                   MAXSIZE = 50,
                   FILEGROWTH = 5 )
LOG ON
( NAME = Mismatch_log,
    FILENAME = 'C:\Temp\Mismatch_Log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB )
FOR ATTACH ;
GO

USE Mismatch;
GO

-- check access again now -> fails

-- try to create user -> fails
CREATE USER TestUser FOR LOGIN TestUser;
GO

SELECT * FROM sys.server_principals WHERE name = 'TestUser';
SELECT * FROM sys.database_principals WHERE name = 'TestUser';
GO

--  EXEC sp_change_users_login 'Report';
--  GO

ALTER USER TestUser WITH LOGIN = TestUser;
GO

USE tempdb;
GO

DROP DATABASE Mismatch;
GO
DROP Login TestUser;
GO
