/*
DBCC FREEPROCCACHE ( { plan_handle | sql_handle | pool_name } )
*/

-- Clear a single plan from cache by plan_handle
SELECT TOP 1 plan_handle
FROM sys.dm_exec_cached_plans
ORDER BY usecounts
GO

DBCC FREEPROCCACHE (plan_handle)
GO


-- Clear a single plan from cache by sql_handle

SELECT TOP 1 sql_handle
FROM sys.dm_exec_query_stats
ORDER BY execution_count

DBCC FREEPROCCACHE (sql_handle)
GO

-- Using Resource Governor to allow targeted flushing

/*
-- Cleanup
USE master;
GO

ALTER RESOURCE GOVERNOR WITH
	(CLASSIFIER_FUNCTION=NULL);
GO

ALTER RESOURCE GOVERNOR DISABLE;
GO

DROP WORKLOAD GROUP [wgPlanCacheBloater];
DROP RESOURCE POOL [rpPlanCacheBloater];
DROP FUNCTION dbo.rgClassifierFunction;
GO

EXECUTE sp_configure 'show advanced options', 1
RECONFIGURE
EXECUTE sp_configure 'optimize for ad hoc workloads', 0
RECONFIGURE
EXECUTE sp_configure 'show advanced options', 0
RECONFIGURE
GO
*/

-- Create a resource pool for PlanCacheBloater
USE master;
GO
CREATE RESOURCE POOL rpPlanCacheBloater
WITH
(
     MAX_CPU_PERCENT = 100,
     MIN_CPU_PERCENT = 0
);
GO

--- Create a workload group for plan cache abuser
CREATE WORKLOAD GROUP wgPlanCacheBloater
WITH
(
     MAX_DOP = 1
) USING [rpPlanCacheBloater]
GO

CREATE FUNCTION dbo.rgClassifierFunction() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN

    DECLARE @grp AS sysname
    IF (APP_NAME() = 'PlanCacheBloater')
        SET @grp = 'wgPlanCacheBloater'
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

-- Start Workloads


-- View Plan Cache usage
SELECT 
	pool_id,
	objtype AS [cache_type],
	count_big(*) AS [total_plan_count],
	sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [total_size_mbytes],
	avg(usecounts) AS [avg_use_counts],
	sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [single_use_size_mbytes],
	sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [single_use_plan_count]
FROM sys.dm_exec_cached_plans
GROUP BY objtype, pool_id
ORDER BY [single_use_size_mbytes] DESC


-- Clear the pool for the bad cache usage
DBCC FREEPROCCACHE (rpPlanCacheBloater)
GO

-- View Plan Cache usage
SELECT 
	pool_id,
	objtype AS [cache_type],
	count_big(*) AS [total_plan_count],
	sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [total_size_mbytes],
	avg(usecounts) AS [avg_use_counts],
	sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [single_use_size_mbytes],
	sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [single_use_plan_count]
FROM sys.dm_exec_cached_plans
GROUP BY objtype, pool_id
ORDER BY [single_use_size_mbytes] DESC

/*
DBCC FREESYSTEMCACHE ( {'ALL' | cache_name } [, pool_name ] ) {WITH MARK_IN_USE_FOR_REMOVAL}
*/

-- Lookup cache names for clearing
SELECT DISTINCT name
FROM sys.dm_os_memory_cache_clock_hands

-- Clear all SQL Plans from cache
DBCC FREESYSTEMCACHE('SQL Plans')

-- View Plan Cache usage
SELECT 
	pool_id,
	objtype AS [cache_type],
	count_big(*) AS [total_plan_count],
	sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [total_size_mbytes],
	avg(usecounts) AS [avg_use_counts],
	sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [single_use_size_mbytes],
	sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [single_use_plan_count]
FROM sys.dm_exec_cached_plans
GROUP BY objtype, pool_id
ORDER BY [single_use_size_mbytes] DESC

-- Clear just a single pool
DBCC FREESYSTEMCACHE('SQL Plans', rpPlanCacheBloater)

-- View Plan Cache usage
SELECT 
	pool_id,
	objtype AS [cache_type],
	count_big(*) AS [total_plan_count],
	sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [total_size_mbytes],
	avg(usecounts) AS [avg_use_counts],
	sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [single_use_size_mbytes],
	sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [single_use_plan_count]
FROM sys.dm_exec_cached_plans
GROUP BY objtype, pool_id
ORDER BY [single_use_size_mbytes] DESC

-- Remove all plans and mark any in use for removal once they are complete
DBCC FREESYSTEMCACHE('SQL Plans', rpPlanCacheBloater) WITH MARK_IN_USE_FOR_REMOVAL;

-- View Plan Cache usage
SELECT 
	pool_id,
	objtype AS [cache_type],
	count_big(*) AS [total_plan_count],
	sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [total_size_mbytes],
	avg(usecounts) AS [avg_use_counts],
	sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [single_use_size_mbytes],
	sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [single_use_plan_count]
FROM sys.dm_exec_cached_plans
GROUP BY objtype, pool_id
ORDER BY [single_use_size_mbytes] DESC

/* DBCC DROPCLEANBUFFERS  */

-- Clear the buffer pool
DBCC DROPCLEANBUFFERS 