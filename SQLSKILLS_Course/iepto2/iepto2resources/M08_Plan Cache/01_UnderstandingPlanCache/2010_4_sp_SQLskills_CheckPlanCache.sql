-- This script is from the blog post below. Please
-- check the blog post for an updated version.

-- Be sure to review the blog category: Plan Cache
-- http://www.sqlskills.com/BLOGS/KIMBERLY/category/Plan-cache.aspx
-- And, specifically, this post:
-- http://www.sqlskills.com/BLOGS/KIMBERLY/category/Plan-cache.aspx#p2 

-- This procedure looks at cache and totals the single-use plans
-- to report the percentage of memory consumed (and therefore
-- wasted) from single-use plans.
			
USE [master];
GO

IF OBJECTPROPERTY (
	OBJECT_ID (N'sp_SQLskills_CheckPlanCache'),
		N'IsProcedure') = 1
	DROP PROCEDURE [sp_SQLskills_CheckPlanCache];
GO

CREATE PROCEDURE [sp_SQLskills_CheckPlanCache]
	(@Percent	DECIMAL (6,3) OUTPUT,
	 @WastedMB	DECIMAL (19,3) OUTPUT)
AS
SET NOCOUNT ON;

DECLARE @ConfiguredMemory	DECIMAL (19,3)
	, @PhysicalMemory		DECIMAL (19,3)
	, @MemoryInUse			DECIMAL (19,3)
	, @SingleUsePlanCount	BIGINT;

CREATE TABLE [#ConfigurationOptions]
(
	[name]				NVARCHAR (35)
	, [minimum]			INT
	, [maximum]			INT
	, [config_value]	INT				-- in bytes
	, [run_value]		INT				-- in bytes
);
INSERT [#ConfigurationOptions] EXEC (
	N'sp_configure ''max server memory''');

SELECT @ConfiguredMemory = [run_value] / 1024 / 1024 
FROM [#ConfigurationOptions] 
WHERE [name] = N'max server memory (MB)';

SELECT @PhysicalMemory = [total_physical_memory_kb] / 1024 
FROM sys.dm_os_sys_memory;

-- New in 2008R2
SELECT @MemoryInUse = [physical_memory_in_use_kb] / 1024 
FROM sys.dm_os_process_memory;

SELECT @WastedMB = SUM ( CAST (
		(CASE WHEN [usecounts] = 1
			AND [objtype] IN (N'Adhoc', N'Prepared') 
		THEN [size_in_bytes] ELSE 0 END)
			AS DECIMAL (12, 2))) / 1024 / 1024 
	, @SingleUsePlanCount = SUM (
		CASE WHEN [usecounts] = 1
			AND [objtype] IN (N'Adhoc', N'Prepared') 
		THEN 1 ELSE 0 END)
	, @Percent = @WastedMB / @MemoryInUse * 100
FROM sys.dm_exec_cached_plans;

SELECT	[TotalPhysicalMemory (MB)] = @PhysicalMemory
	, [TotalConfiguredMemory (MB)] = @ConfiguredMemory
	, [MaxMemoryAvailableToSQLServer (%)] =
		@ConfiguredMemory / @PhysicalMemory * 100
	, [MemoryInUseBySQLServer (MB)] = @MemoryInUse
	, [TotalSingleUsePlanCache (MB)] = @WastedMB
	, TotalNumberOfSingleUsePlans = @SingleUsePlanCount
	, [PercentOfConfiguredCacheWastedForSingleUsePlans (%)] = 
		@Percent;
GO

EXEC sys.sp_MS_marksystemobject N'sp_SQLskills_CheckPlanCache';
GO

---------------------------------------------------------
-- Logic (in a job?) to decide whether or not to
-- clear - using sproc...
---------------------------------------------------------

DECLARE @Percent		DECIMAL (6, 3)
		, @WastedMB		DECIMAL (19,3)
		, @StrMB		NVARCHAR (20)
		, @StrPercent	NVARCHAR (20)

EXEC [sp_SQLskills_CheckPlanCache] 
	@Percent OUTPUT, @WastedMB OUTPUT;

SELECT @StrMB = CONVERT (NVARCHAR (20), @WastedMB)
		, @StrPercent = CONVERT (NVARCHAR (20), @Percent);

IF @Percent > 10 OR @WastedMB > 2000
	BEGIN
        -- persist cache info into troubleshooting db
		DBCC FREESYSTEMCACHE (N'SQL Plans');
		RAISERROR (N'%s MB (%s percent) was allocated to single-use plan cache. Single-use plans have been cleared.', 10, 1, @StrMB, @StrPercent);
	END
ELSE
	BEGIN
		RAISERROR (N'Only %s MB (%s percent) is allocated to single-use plan cache - no need to clear cache now.', 10, 1, @StrMB, @StrPercent);
		-- Note: this is only a warning message and
		-- not an actual error.
	END
GO