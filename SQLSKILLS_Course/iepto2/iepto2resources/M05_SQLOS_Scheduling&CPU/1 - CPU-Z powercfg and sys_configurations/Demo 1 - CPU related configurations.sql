/*================================================================
  File:     CPU related configurations.sql

  SQL Server Versions tested: SQL Server 2012 11.0.3321
------------------------------------------------------------
  Written by Joseph I. Sack, SQLskills.com

  (c) 2012, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
=================================================================*/

SELECT 'Scheduler related CPU settings' as '-';

SELECT name, value, value_in_use,
		is_advanced,is_dynamic
FROM sys.configurations 
WHERE name IN
	('affinity mask',
	'affinity64 mask',
	'cost threshold for parallelism',
	'lightweight pooling',
	'max degree of parallelism',
	'max worker threads',
	'priority boost')
ORDER BY name;
GO

SELECT 'CPU vs HT Ratio (CPU-Z more precise)' as '-';
SELECT	cpu_count, 
		hyperthread_ratio
FROM sys.dm_os_sys_info;
GO

SELECT 'Schedulers' as '-';
SELECT	*
FROM sys.dm_os_schedulers
WHERE status LIKE 'VISIBLE ONLINE%';

