SELECT  [classifier_function_id],
        [is_enabled]
FROM sys.resource_governor_configuration;

-- Check on resource pool
SELECT  [pool_id],
        [name],
        [min_cpu_percent],
        [max_cpu_percent],
        [min_memory_percent],
        [max_memory_percent],
        [cap_cpu_percent]
FROM sys.resource_governor_resource_pools;

-- Check on workload group
SELECT  [group_id],
        [name],
        [importance],
        [request_max_memory_grant_percent],
        [request_max_cpu_time_sec],
        [request_memory_grant_timeout_sec],
        [max_dop],
        [group_max_requests],
        [pool_id]
FROM sys.resource_governor_workload_groups;
