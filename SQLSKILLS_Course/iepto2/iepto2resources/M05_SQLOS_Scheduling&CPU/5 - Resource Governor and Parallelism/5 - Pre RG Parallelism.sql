/*============================================================================
	File: 1 - Pre RG Parallelism.sql 

	SQL Server Versions:2008 R2
------------------------------------------------------------------------------
	Copyright (C) 2012 Joe Sack, SQLskills.com
	All rights reserved. 

	For more scripts and sample code, check out
		http://www.sqlskills.com/ 

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit. 

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/ 

USE Credit;
GO

EXEC sp_configure 'show advanced options', 1
RECONFIGURE

-- Setting max degree of parallelism
EXEC sp_configure 'max degree of parallelism', 0
RECONFIGURE

-- Parallel query
EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';

-- Setting max degree of parallelism
EXEC sp_configure 'max degree of parallelism', 1
RECONFIGURE

-- Now let's try again
EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';

DBCC FREEPROCCACHE;
	
-- Now let's override the instance default
EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt OPTION (MAXDOP 4)',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';

-- Create a resource pool for report users
USE master;
GO
CREATE RESOURCE POOL rpReportUsers
WITH
(
     MAX_CPU_PERCENT = 100,
     MIN_CPU_PERCENT = 0
);
GO

--- Create a workload group forreport users
CREATE WORKLOAD GROUP wgReportUsers
WITH
(
     MAX_DOP = 1
) USING [rpReportUsers]
GO

-- Creating an example Reporting login/user
USE master;
GO


CREATE LOGIN [CreditRptUsr] WITH PASSWORD=N'xyz1234', 
DEFAULT_DATABASE=[Credit], CHECK_POLICY=OFF;
GO

USE Credit;
GO

CREATE USER [CreditRptUsr] FOR LOGIN [CreditRptUsr]
GO

EXEC sp_addrolemember N'db_datareader', N'CreditRptUsr'
GO

-- This user also needs SHOWPLAN (for our demo)
GRANT SHOWPLAN TO CreditRptUsr;
GO



-- Create a classifier function
USE master;
GO



CREATE FUNCTION dbo.rgClassifierFunction() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN

    DECLARE @grp AS sysname
    IF (SUSER_NAME() = 'CreditRptUsr')
        SET @grp = 'wgReportUsers'
    ELSE
        SET @grp = 'default'
    RETURN @grp
END;
GO

-- Enable RG
ALTER RESOURCE GOVERNOR WITH
	(CLASSIFIER_FUNCTION=dbo.rgClassifierFunction);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

DBCC FREEPROCCACHE;
GO

-- Check that RG is enabled
SELECT classifier_function_id, is_enabled
FROM sys.resource_governor_configuration;

-- Check on resource pool
SELECT pool_id, min_cpu_percent, max_cpu_percent
FROM sys.resource_governor_resource_pools
WHERE name = 'rpReportUsers';

-- Check on workload group
SELECT group_id, max_dop
FROM sys.resource_governor_workload_groups
WHERE name = 'wgReportUsers';

DBCC FREEPROCCACHE;
GO

-- **
-- Reconnect as [CreditRptUsr] 'xyz1234' 
-- **
USE Credit;
GO

-- Who is this?
SELECT SUSER_NAME();

-- Security memberships?
SELECT  [principal_id],
        [sid],
        [name],
        [type],
        [usage] 
FROM sys.user_token;
GO

SELECT  *
FROM sys.login_token;
GO

-- Parallel or serial? Really??
EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt OPTION (MAXDOP 4)',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';

-- Let's revert and compare the plan
-- ** RECONNECT as administrator **
-- **                            **

USE Credit;
GO

EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt OPTION (MAXDOP 4)',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';

-- Cleanup
USE master;
GO

ALTER RESOURCE GOVERNOR WITH
	(CLASSIFIER_FUNCTION=NULL);
GO

ALTER RESOURCE GOVERNOR DISABLE;
GO

DROP WORKLOAD GROUP [wgReportUsers];
DROP RESOURCE POOL [rpReportUsers];
DROP FUNCTION dbo.rgClassifierFunction;

EXEC sp_configure 'max degree of parallelism', 0
RECONFIGURE

DROP LOGIN [CreditRptUsr];
GO


/* -- Cleanup Script
-- Disable RG
ALTER RESOURCE GOVERNOR WITH
	(CLASSIFIER_FUNCTION=NULL);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO


IF  EXISTS ( SELECT name FROM sys.resource_governor_workload_groups WHERE name = N'wgPlanCacheBloater')
BEGIN
	DROP WORKLOAD GROUP [wgPlanCacheBloater]
END
GO
IF  EXISTS ( SELECT name FROM sys.resource_governor_workload_groups WHERE name = N'wgReportUsers')
BEGIN
	DROP WORKLOAD GROUP [wgReportUsers]
END
GO

IF  EXISTS ( SELECT name FROM sys.resource_governor_resource_pools WHERE name = N'rpPlanCacheBloater')
BEGIN
	DROP RESOURCE POOL [rpPlanCacheBloater]
END
GO

IF  EXISTS ( SELECT name FROM sys.resource_governor_resource_pools WHERE name = N'rpReportUsers')
BEGIN
	DROP RESOURCE POOL [rpReportUsers]
END
GO

IF OBJECT_ID(N'rgClassifierFunction') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.rgClassifierFunction;
END
GO
*/