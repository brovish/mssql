-- Sample script from Aaron Bertrand and Boris Baryshnikov
-- Updated by Greg Low

-- initial table
CREATE TABLE dbo.ConsolidationMetrics
(
	SnapshotTime			DATETIME,
	[object_name]			NVARCHAR(256),
	counter_name			NVARCHAR(256),
	instance_name			NVARCHAR(256),
	counter_value			BIGINT,
	LastStatisticsResetTime	DATETIME
);

-- schedule this query:	
;WITH rawstats AS
(
	SELECT
		[object_name],
		counter_name,
		instance_name,
		val = cntr_value
	FROM
		sys.dm_os_performance_counters
	WHERE
		[object_name] LIKE N'%:[WR]% Stats%'
		AND counter_name IN 
		(
			N'CPU usage %', N'CPU usage % base', 
			N'Active requests', N'Blocked tasks',
			N'Active parallel threads',
			N'Max request CPU time (ms)',
			N'Active memory grant amount (KB)',
			N'Pending memory grants count',
			N'Used memory (KB)'
		)
)
INSERT dbo.ConsolidationMetrics
(
	SnapshotTime, [object_name], counter_name,
	instance_name, counter_value 
)
SELECT
	CURRENT_TIMESTAMP, s1.[object_name],
	s1.counter_name, s1.instance_name,
	CASE WHEN s1.counter_name <> N'CPU usage %'
		THEN s1.val
	ELSE
		CONVERT(BIGINT, s1.val * 100.0 / COALESCE(s2.val, 1))
	END,
	CASE WHEN s1.[object_name] LIKE '%Resource Pool%'
		THEN rp.statistics_start_time 
	ELSE	
		wg.statistics_start_time 
	END
FROM
	rawstats AS s1
LEFT OUTER JOIN
	rawstats AS s2
ON
	s1.counter_name = N'CPU usage %'
	AND s2.counter_name = N'CPU usage % base'
	AND s1.[object_name] = s2.[object_name]
	AND s1.instance_name = s2.instance_name
LEFT OUTER JOIN
	sys.dm_resource_governor_resource_pools AS rp
ON
	s1.instance_name = rp.[name]
LEFT OUTER JOIN
	sys.dm_resource_governor_workload_groups AS wg
ON
	s1.instance_name = wg.[name] 
WHERE
	s1.counter_name <> N'CPU usage % base';
