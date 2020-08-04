-- close all other windows first

USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'RGovernor')
  ALTER DATABASE RGovernor SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE RGovernor;
GO

IF EXISTS(SELECT 1 FROM syslogins WHERE name = 'MyFriendBill')
  DROP LOGIN MyFriendBill;
  
IF EXISTS(SELECT 1 FROM syslogins WHERE name = 'AnnoyingAccessUserOnFloor5')
  DROP LOGIN AnnoyingAccessUserOnFloor5; 
  
ALTER RESOURCE GOVERNOR 
  WITH (CLASSIFIER_FUNCTION = NULL);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO 

SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

IF EXISTS(SELECT name FROM sys.resource_governor_workload_groups 
          WHERE name = N'MyFriends')
  DROP WORKLOAD GROUP MyFriends;
GO

IF EXISTS(SELECT name FROM sys.resource_governor_workload_groups 
          WHERE name = N'AccessUsersWhoInsistOnDirectTableAccess')
  DROP WORKLOAD GROUP AccessUsersWhoInsistOnDirectTableAccess;
GO

IF EXISTS(SELECT name FROM sys.resource_governor_resource_pools 
          WHERE name = N'ToughLuckPool')
  DROP RESOURCE POOL ToughLuckPool;
GO

IF EXISTS(SELECT name FROM sys.resource_governor_resource_pools 
          WHERE name = N'GoodGuysPool')
  DROP RESOURCE POOL GoodGuysPool;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO 

SELECT * FROM sys.dm_resource_governor_configuration;
SELECT * FROM sys.dm_resource_governor_resource_pools;
SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserClassifier]'))
  DROP FUNCTION dbo.UserClassifier;
GO
