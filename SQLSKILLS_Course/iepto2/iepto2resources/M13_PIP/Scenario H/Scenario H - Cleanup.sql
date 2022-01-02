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