-- AD217 Lab Solution

-- Exercise 1

SELECT * FROM sys.dm_resource_governor_resource_pools;
GO

SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

CREATE RESOURCE POOL InteractiveUsers
  WITH (MAX_CPU_PERCENT = 100);
GO

CREATE RESOURCE POOL ReportingUsers
  WITH (MAX_CPU_PERCENT = 50);
GO

CREATE RESOURCE POOL BackgroundTasks
  WITH (MAX_CPU_PERCENT = 20);
GO

SELECT * FROM sys.dm_resource_governor_resource_pools;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

SELECT * FROM sys.dm_resource_governor_resource_pools;
GO

-- Exercise 2

CREATE WORKLOAD GROUP HighPriorityUsers
  USING InteractiveUsers;
GO

CREATE WORKLOAD GROUP MediumPriorityUsers 
  USING ReportingUsers;
GO

CREATE WORKLOAD GROUP LowPriorityUsers 
  USING BackgroundTasks;
GO

SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

SELECT * FROM sys.dm_resource_governor_workload_groups;
GO

-- Execise 3

USE master;
GO

CREATE FUNCTION dbo.UserClassifier()
  RETURNS sysname WITH SCHEMABINDING
AS BEGIN
  DECLARE @WorkloadGroup sysname = 'default';

  IF SUSER_SNAME() = N'HighPriorityUser' BEGIN
    SET @WorkloadGroup = N'HighPriorityUsers';
  END ELSE BEGIN
    IF SUSER_SNAME() = N'MediumPriorityUser' BEGIN
      SET @WorkloadGroup = N'MediumPriorityUsers';
    END ELSE BEGIN
      IF SUSER_SNAME() = N'LowPriorityUser' BEGIN
        SET @WorkloadGroup = N'LowPriorityUsers';
      END;
    END; 
  END;

  RETURN @WorkloadGroup;
END;
GO

SELECT dbo.UserClassifier();
GO

GRANT EXECUTE ON dbo.UserClassifier TO public;
GO

ALTER RESOURCE GOVERNOR
  WITH (CLASSIFIER_FUNCTION = dbo.UserClassifier);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

SELECT * FROM sys.resource_governor_configuration;
GO
