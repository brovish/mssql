-- AD217 LabSetup

USE master;
GO


EXEC sp_configure 'show advanced options',1;
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell',1;
RECONFIGURE;
GO

-- From AD202

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'WarehouseManagement') 
BEGIN
  ALTER DATABASE WarehouseManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE WarehouseManagement;
END;
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

-- Added as starter for AD205

USE WarehouseManagement;
GO

CREATE SCHEMA Reports AUTHORIZATION dbo;
GO

CREATE SCHEMA Barcode AUTHORIZATION dbo;
GO

CREATE SCHEMA Warehouse AUTHORIZATION dbo;
GO

CREATE SCHEMA Sales AUTHORIZATION dbo;
GO

CREATE SCHEMA [Admin] AUTHORIZATION dbo;
GO

CREATE SCHEMA DBA AUTHORIZATION dbo;
GO

EXEC xp_cmdshell 'NET USER BelaLugosi SQLRocks! /ADD /FULLNAME:"Bela Lugosi" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER EarthaKitt SQLRocks! /ADD /FULLNAME:"Eartha Kitt" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER ErnestBorgnine SQLRocks! /ADD /FULLNAME:"Ernest Borgnine" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER GaleStorm SQLRocks! /ADD /FULLNAME:"Gale Storm" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER HumphreyBogart SQLRocks! /ADD /FULLNAME:"Humphrey Bogart" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER JackKlugman SQLRocks! /ADD /FULLNAME:"Jack Klugman" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER JonathanWinters SQLRocks! /ADD /FULLNAME:"Jonathan Winters" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER LonChaney SQLRocks! /ADD /FULLNAME:"Lon Chaney" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER LynnRedgrave SQLRocks! /ADD /FULLNAME:"Lynn Redgrave" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER RichardBriers SQLRocks! /ADD /FULLNAME:"Richard Briers" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER RichardGriffiths SQLRocks! /ADD /FULLNAME:"Richard Griffiths" /PASSWORDCHG:NO';

EXEC xp_cmdshell 'NET USER RichardDawson SQLRocks! /ADD /FULLNAME:"Richard Dawson" /PASSWORDCHG:NO';
EXEC xp_cmdshell 'NET USER SsasService SQLRocks! /ADD /FULLNAME:"SSAS Service Account" /PASSWORDCHG:NO';

EXEC xp_cmdshell 'NET LOCALGROUP DBATeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP DBATeam HumphreyBogart /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP DBATeam LynnRedgrave /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam ErnestBorgnine /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam HumphreyBogart /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam JonathanWinters /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ManagementTeam LonChaney /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam EarthaKitt /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam LonChaney /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam RichardBriers /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP WarehouseTeam RichardGriffiths /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam GaleStorm /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam JonathanWinters /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam SandraBullock /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP ReportingTeam TomHanks /ADD';

EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam BelaLugosi /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam ErnestBorgnine /ADD';
EXEC xp_cmdshell 'NET LOCALGROUP SalesTeam JackKlugman /ADD';
GO

USE WarehouseManagement;
GO

CREATE TABLE Sales.BusinessCategories
( BusinessCategoryID int IDENTITY(1,1)
    CONSTRAINT PK_BusinessCategories PRIMARY KEY,
  BusinessCategoryName nvarchar(50) NOT NULL
);
GO

CREATE TABLE Sales.Customers 
( CustomerID int IDENTITY(1,1) 
    CONSTRAINT PK_Customers PRIMARY KEY,
  CustomerName nvarchar(50) NOT NULL,
  BusinessCategoryID int NOT NULL
    CONSTRAINT FK_Customers_BusinessCategories 
    FOREIGN KEY REFERENCES Sales.BusinessCategories(BusinessCategoryID),
  IsActive bit
    CONSTRAINT DF_Customers_IsActive DEFAULT (1)
);
GO

CREATE TABLE Reports.Settings
( SettingID int IDENTITY(1,1)
    CONSTRAINT PK_Settings PRIMARY KEY,
  SettingName nvarchar(50) NOT NULL,
  SettingValue nvarchar(100) NOT NULL
);
GO

CREATE PROC Reports.GetCustomerLookupList
AS
BEGIN
  SELECT CustomerID, CustomerName 
  FROM Sales.Customers 
  ORDER BY CustomerID;
END;
GO

CREATE PROC Reports.GetActiveCustomerLookupList
AS
BEGIN
  SELECT CustomerID, CustomerName 
  FROM Sales.Customers 
  WHERE IsActive <> 0
  ORDER BY CustomerID;
END;
GO
------------------ AD205 Changes ---------------

USE WarehouseManagement;
GO

CREATE SCHEMA Staging AUTHORIZATION dbo;
GO

USE master;
GO

CREATE LOGIN [SDUPROD\DBATeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\ManagementTeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\ReportingTeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\SalesTeam] FROM WINDOWS;
GO

CREATE LOGIN [SDUPROD\JackKlugman] FROM WINDOWS;
GO

CREATE LOGIN [SDUPROD\ErnestBorgnine] FROM WINDOWS;
GO

CREATE LOGIN [SDUPROD\RichardDawson] FROM WINDOWS;
GO

CREATE LOGIN ReadyToScan WITH PASSWORD = 'SQLRocks!', CHECK_POLICY = OFF;
GO
 
ALTER SERVER ROLE sysadmin ADD MEMBER [SDUPROD\DBATeam];
GO

USE WarehouseManagement;
GO

CREATE ROLE SalesManagers;
GO

------------------ AD206 Changes ----------------------

USE master;
GO

GRANT ALTER TRACE TO [SDUPROD\RichardDawson];
GO

USE WarehouseManagement;
GO

CREATE USER [SDUPROD\DBATeam] FOR LOGIN [SDUPROD\DBATeam];
GO
CREATE USER [SDUPROD\ManagementTeam] FOR LOGIN [SDUPROD\ManagementTeam];
GO
CREATE USER [SDUPROD\ReportingTeam] FOR LOGIN [SDUPROD\ReportingTeam];
GO
CREATE USER [SDUPROD\SalesTeam] FOR LOGIN [SDUPROD\SalesTeam];
GO

CREATE USER [SDUPROD\JackKlugman] FOR LOGIN [SDUPROD\JackKlugman];
GO
CREATE USER [SDUPROD\ErnestBorgnine] FOR LOGIN [SDUPROD\ErnestBorgnine];
GO

CREATE USER ReadyToScan FOR LOGIN ReadyToScan;
GO

ALTER ROLE SalesManagers 
  ADD MEMBER [SDUPROD\ErnestBorgnine];
GO

GRANT EXECUTE ON SCHEMA::Reports TO [SDUPROD\ReportingTeam];
GO

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Barcode TO ReadyToScan;
GO

GRANT SELECT ON SCHEMA::Sales TO [SDUPROD\SalesTeam];
GO

GRANT CONTROL ON SCHEMA::Staging TO [SDUPROD\ReportingTeam];
GO

GRANT EXECUTE ON SCHEMA::Warehouse TO [SDUPROD\WarehouseTeam];
GO

GRANT SELECT ON SCHEMA::Staging TO [SDUPROD\SsasService];
GO

GRANT INSERT, UPDATE ON Sales.Customers TO [SDUPROD\SalesTeam];
GO

GRANT INSERT, UPDATE, DELETE ON Sales.BusinessCategories TO SalesManagers;
GO

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Sales TO [SDUPROD\JackKlugman];
GO

------------------ AD209 Prep ------------------
USE master;
GO

ALTER DATABASE WarehouseManagement SET RECOVERY SIMPLE;
GO

USE WarehouseManagement;
GO

CREATE SCHEMA ETL AUTHORIZATION dbo;
GO

CREATE TABLE ETL.Configurations
( ConfigurationID int IDENTITY(1,1)
    CONSTRAINT PK_Configurations PRIMARY KEY NONCLUSTERED,
  EnvironmentName nvarchar(50) NOT NULL,
  ConfigurationName nvarchar(50) NOT NULL,
  ConfigurationValue nvarchar(max) NOT NULL
);
GO

CREATE CLUSTERED INDEX IX_Configurations_EnvironmentName_ConfigurationName ON ETL.Configurations (EnvironmentName, ConfigurationName);
GO

CREATE NONCLUSTERED INDEX IX_Configurations_ConfigurationName_EnvironmentName ON ETL.Configurations (ConfigurationName, EnvironmentName);
GO

------------------ AD211 Setup -----------------

-- Removed

------------------ AD212 and AD213 Setup -----------------

-- Removed data that would have been inserted in AD211 setup

------------------ AD214 Setup

USE msdb;
GO

/****** Object:  Job [Export Products]    Script Date: 24/06/2013 5:52:34 PM ******/
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 24/06/2013 5:52:34 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
  EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]';
END;

DECLARE @jobId BINARY(16);
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Export Products', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SDUPROD\Administrator', @job_id = @jobId OUTPUT;

/****** Object:  Step [Delete Product Data Backup]    Script Date: 24/06/2013 5:52:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete Product Data Backup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'IF EXIST C:\Temp\Products.bak DEL C:\Temp\Products.bak', 
		@flags=0;

/****** Object:  Step [Create Product Data Backup]    Script Date: 24/06/2013 5:52:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Product Data Backup', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'IF EXIST C:\Temp\Products.txt REN C:\Temp\Products.txt Products.bak', 
		@flags=0;

/****** Object:  Step [Extract Products]    Script Date: 24/06/2013 5:52:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extract Products', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\ETL\ExtractProducts\ExtractProducts.dtsx\"" /SERVER SDUPROD /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0;

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Monday 8AM', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130624, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=235959, 
		@schedule_uid=N'3b8a242f-3bbe-432b-989b-37b5cd09dc21';

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
GO

------------------ AD217 Setup -----------------

USE master;
GO

CREATE LOGIN HighPriorityUser WITH PASSWORD = 'SQLRocks!', CHECK_POLICY = OFF;
GO
CREATE LOGIN MediumPriorityUser WITH PASSWORD = 'SQLRocks!', CHECK_POLICY = OFF;
GO
CREATE LOGIN LowPriorityUser WITH PASSWORD = 'SQLRocks!', CHECK_POLICY = OFF;
GO

USE WarehouseManagement;
GO

CREATE USER HighPriorityUser FOR LOGIN HighPriorityUser;
GO
CREATE USER MediumPriorityUser FOR LOGIN MediumPriorityUser;
GO
CREATE USER LowPriorityUser FOR LOGIN LowPriorityUser;
GO

ALTER ROLE db_datareader ADD MEMBER HighPriorityUser;
GO
ALTER ROLE db_datareader ADD MEMBER MediumPriorityUser;
GO
ALTER ROLE db_datareader ADD MEMBER LowPriorityUser;
GO

USE PopkornKraze;
GO

CREATE USER HighPriorityUser FOR LOGIN HighPriorityUser;
GO
CREATE USER MediumPriorityUser FOR LOGIN MediumPriorityUser;
GO
CREATE USER LowPriorityUser FOR LOGIN LowPriorityUser;
GO

ALTER ROLE db_datareader ADD MEMBER HighPriorityUser;
GO
ALTER ROLE db_datareader ADD MEMBER MediumPriorityUser;
GO
ALTER ROLE db_datareader ADD MEMBER LowPriorityUser;
GO

------------------ Cleanup ---------------------

USE master;
GO

EXEC sp_configure 'xp_cmdshell',0;
RECONFIGURE;
GO

