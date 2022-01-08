SELECT  [configuration_id],
        [name],
        [value],
        [minimum],
        [maximum],
        [value_in_use],
        [description],
        [is_dynamic],
        [is_advanced]	
FROM sys.configurations
ORDER BY name;