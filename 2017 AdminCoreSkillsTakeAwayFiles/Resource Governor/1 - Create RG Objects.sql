USE master;
GO

SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

CREATE RESOURCE POOL ToughLuckPool
  WITH (MAX_CPU_PERCENT = 20);
GO

CREATE RESOURCE POOL GoodGuysPool
  WITH (MAX_CPU_PERCENT = 100);
GO

-- so what's changed?
SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

-- Take care of our friends first
CREATE WORKLOAD GROUP MyFriends
  USING GoodGuysPool;
GO
  
-- And then those pesky users from floor 5
CREATE WORKLOAD GROUP AccessUsersWhoInsistOnDirectTableAccess
  USING ToughLuckPool;
GO

SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

-- We have to be able to work out who is connected
IF OBJECT_ID ('dbo.UserClassifier') IS NOT NULL
  DROP FUNCTION dbo.UserClassifier;
GO

CREATE FUNCTION dbo.UserClassifier ()
  RETURNS SYSNAME WITH SCHEMABINDING
AS
BEGIN
	DECLARE @ClassifierGroup SYSNAME;
	
	IF SUSER_SNAME() = N'MyFriendBill'
	  SET @ClassifierGroup = N'MyFriends';
	ELSE IF  SUSER_SNAME() = N'AnnoyingAccessUserOnFloor5'
	  SET @ClassifierGroup = 'AccessUsersWhoInsistOnDirectTableAccess';
	ELSE 
	  SET @ClassifierGroup = N'Default';
	  
	RETURN @ClassifierGroup;
END;
GO

ALTER RESOURCE GOVERNOR 
  WITH (CLASSIFIER_FUNCTION = dbo.UserClassifier);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

USE master;
GO
