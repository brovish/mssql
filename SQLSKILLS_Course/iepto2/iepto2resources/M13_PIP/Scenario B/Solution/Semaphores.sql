SELECT  [resource_semaphore_id],
        [target_memory_kb],
        [max_target_memory_kb],
        [total_memory_kb],
        [available_memory_kb],
        [granted_memory_kb],
        [used_memory_kb],
        [grantee_count],
        [waiter_count],
        [timeout_error_count],
        [forced_grant_count],
        [pool_id]
FROM    sys.dm_exec_query_resource_semaphores;
GO
