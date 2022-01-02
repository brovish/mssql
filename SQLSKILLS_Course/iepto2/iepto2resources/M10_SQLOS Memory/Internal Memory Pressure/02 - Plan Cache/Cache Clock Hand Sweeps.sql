-- Cache clock hands and last sweep info.
SELECT DISTINCT
	ch.clock_hand,
	ch.clock_status,
	cc.name,  
	cc.type, 
	cc.single_pages_kb + cc.multi_pages_kb as total_kb,  
	cc.single_pages_in_use_kb + cc.multi_pages_in_use_kb 
	as total_in_use_kb,  
	cc.entries_count,  
	cc.entries_in_use_count,
	ch.rounds_count,
	ch.removed_all_rounds_count, 
	DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (int, ( cpu_ticks / ms_ticks ))) - [round_start_time])/1000), GETDATE()) AS last_round_time, 
	ch.removed_last_round_count, last_tick_time, last_round_start_time, round_start_time,
	cpu_ticks, ms_ticks
FROM sys.dm_os_memory_cache_counters AS cc  
JOIN sys.dm_os_memory_cache_clock_hands AS ch 
	ON cc.cache_address =ch.cache_address
CROSS JOIN sys.dm_os_sys_info
WHERE ch.removed_all_rounds_count > 0 
ORDER BY 
	DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (int, ( cpu_ticks / ms_ticks ))) - [round_start_time])/1000), GETDATE()) DESC,
	removed_all_rounds_count DESC
