
-- Chapter 2

-- copy and be ready to run the following code on that window:
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO
SELECT * FROM Production.Product p1 CROSS JOIN
Production.Product p2

-- copy the following code to a second window
SELECT cpu_time, reads, total_elapsed_time, logical_reads, row_count
FROM sys.dm_exec_requests
WHERE session_id = 56
GO
SELECT cpu_time, reads, total_elapsed_time, logical_reads, row_count
FROM sys.dm_exec_sessions
WHERE session_id = 56

-- create the following stored procedure with three simple queries:
CREATE PROC test
AS
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 60677
SELECT * FROM Person.Address WHERE AddressID = 21
SELECT * FROM HumanResources.Employee WHERE BusinessEntityID = 229

-- note that the code uses the sys.dm_exec_sql_text DMF
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO
EXEC test
GO
SELECT * FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
WHERE objectid = OBJECT_ID('dbo.test')

-- we can easily extend our previous query to inspect the plan cache to use statement_start_offset
-- and statement_end_offset and get something like the following code:
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO
EXEC test
GO
SELECT SUBSTRING(text, (statement_start_offset/2) + 1,
((CASE statement_end_offset
WHEN -1
THEN DATALENGTH(text)
ELSE
statement_end_offset
END
- statement_start_offset)/2) + 1) AS statement_text, *
FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
WHERE objectid = OBJECT_ID('dbo.test')

-- to test the concept for a particular query
SELECT SUBSTRING(text, 44 / 2 + 1, (168 - 44) / 2 + 1) FROM sys.dm_exec_sql_text(
0x03000500996DB224E0B27201B7A1000001000000000000000000000000000000000000000000000000000000)

-- using the example before
SELECT * from sys.dm_exec_sql_text(
0x03000500996DB224E0B27201B7A1000001000000000000000000000000000000000000000000000000000000)

-- the text of the batch is stored in the SQL Manager Cache or SQLMGR
SELECT * FROM sys.dm_os_memory_objects
WHERE type = 'MEMOBJ_SQLMGR'

-- here is an example:
SELECT * FROM sys.dm_exec_query_plan(
0x05000500996DB224B0C9B8F80100000001000000000000000000000000000000000000000000000000000000)

-- to understand the problem, let’s look at an example of the behavior of sys.dm_exec_query_stats 
-- when a query is autoparameterized:
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO
SELECT * FROM Person.Address
WHERE AddressID = 12
GO
SELECT * FROM Person.Address
WHERE AddressID = 37
GO
SELECT * FROM sys.dm_exec_query_stats

-- however, we can see a different behavior with the following query:
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 79
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 59
GO
SELECT * FROM sys.dm_exec_query_stats

-- note that the query is grouping on the query_hash value to aggregate similar queries
SELECT TOP 20 query_stats.query_hash,
SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count)
AS avg_cpu_time,
MIN(query_stats.statement_text) AS statement_text
FROM
(SELECT qs.*,
SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
((CASE statement_end_offset
WHEN -1 THEN DATALENGTH(ST.text)
ELSE qs.statement_end_offset END
- qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st) AS query_stats
GROUP BY query_stats.query_hash
ORDER BY avg_cpu_time DESC

-- notice that there is no need to use the statement_start_offset and statement_end_offset columns 
-- to separate the particular queries and that this time we are grouping on the query_plan_hash value.
SELECT TOP 20 query_plan_hash,
SUM(total_worker_time) / SUM(execution_count) AS avg_cpu_time,
MIN(plan_handle) AS plan_handle, MIN(text) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st
GROUP BY query_plan_hash
ORDER BY avg_cpu_time DESC

-- finally, we could also apply the same concept to find the most expensive queries currently executing
SELECT TOP 20 SUBSTRING(st.text, (er.statement_start_offset/2) + 1,
((CASE statement_end_offset
WHEN -1
THEN DATALENGTH(st.text)
ELSE
er.statement_end_offset
END
- er.statement_start_offset)/2) + 1) AS statement_text
, *
FROM sys.dm_exec_requests er
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
ORDER BY total_elapsed_time DESC

-- run the trace and then execute the following ad hoc query in Management Studio:
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 60677

-- if, on the other hand, we create and execute the same query as part of a simple stored procedure
CREATE PROC test
AS
SELECT * FROM HumanResources.Employee WHERE BusinessEntityID = 229

-- and run it, as in
EXEC test

-- c# code for rpc test
using System;
using System.Data;
using System.Data.SqlClient;

class Test
{
	static void Main()
	{
		SqlConnection cnn = null;
		SqlDataReader reader = null;
		try
			{
			cnn = new SqlConnection("Data Source=(local);
			Initial Catalog=AdventureWorks2012;Integrated Security=SSPI");
			SqlCommand cmd = new SqlCommand();
			cmd.Connection = cnn;
			cmd.CommandText = "dbo.test";
			cmd.CommandType = CommandType.StoredProcedure;
			cnn.Open();
			reader = cmd.ExecuteReader();
			while (reader.Read())
			{
				Console.WriteLine(reader[0]);
			}
			return;
		}
		catch (Exception e)
		{
			throw e;
		}
		finally
		{
			if (cnn != null)
			{
				if (cnn.State != ConnectionState.Closed)
				cnn.Close();
			}
		}
	}
}

-- to compile the c# code, run the following in a command prompt window:
csc test.cs

-- you can create an extended events session by selecting one or more of the following events:
SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'event' AND
(capabilities & 1 = 0 OR capabilities IS NULL)
ORDER BY name

-- each event has a set of columns that you can display by using the sys.dm_xe_object_columns DMV
SELECT o.name, c.name as column_name, c.description
FROM sys.dm_xe_objects o
JOIN sys.dm_xe_object_columns c
ON o.name = c.object_name
WHERE object_type = 'event' AND
c.column_type <> 'readonly' AND
(o.capabilities & 1 = 0 OR o.capabilities IS NULL)
ORDER BY o.name, c.name

-- you can run the following code to find the entire list of available actions:
SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'action' AND
(capabilities & 1 = 0 OR capabilities IS NULL)
ORDER BY name

-- predicates are used to limit the data you want to capture
SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'pred_source' AND
(capabilities & 1 = 0 OR capabilities IS NULL)
ORDER BY name

-- you can list the six available targets by running the following query:
SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'target' AND
(capabilities & 1 = 0 OR capabilities IS NULL)
ORDER BY name

-- to see how it works, run the following query:
SELECT te.trace_event_id, name, package_name, xe_event_name
FROM sys.trace_events te
JOIN sys.trace_xe_event_map txe ON te.trace_event_id = txe.trace_event_id
WHERE te.trace_event_id IS NOT NULL
ORDER BY name

-- trace_id 1 is usually the default trace
SELECT * FROM sys.traces

-- once you get the trace ID, you can run the following code
SELECT te.trace_event_id, name, package_name, xe_event_name
FROM sys.trace_events te
JOIN sys.trace_xe_event_map txe ON te.trace_event_id = txe.trace_event_id
WHERE te.trace_event_id IN (
SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(2))
ORDER BY name

-- to follow up on our example, use the following script to create our extended events session:
CREATE EVENT SESSION test ON SERVER
ADD EVENT sqlserver.module_end(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.rpc_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.sp_statement_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.sql_statement_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text))
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)

-- as shown in Chapter 1, we also need to start the extended events session by running the following:
ALTER EVENT SESSION [test]
ON SERVER
STATE=START

-- to test it, run the following statements:
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 60677
GO
SELECT * FROM Person.Address WHERE AddressID = 21
GO
SELECT * FROM HumanResources.Employee WHERE BusinessEntityID = 229
GO

-- to read the current captured events, run the following code:
SELECT name, target_name, execution_count, CAST(target_data AS xml)
AS target_data
FROM sys.dm_xe_sessions s
JOIN sys.dm_xe_session_targets t
ON s.address = t.event_session_address
WHERE s.name = 'test'

-- however, because reading XML directly is not much fun, we can use XQuery to extract the data from the XML document
SELECT
	event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
	event_data.value('(event/action[@name="query_hash"]/value)[1]',
		'varchar(max)') AS query_hash,
	event_data.value('(event/data[@name="cpu_time"]/value)[1]', 'int')
		AS cpu_time,
	event_data.value('(event/data[@name="duration"]/value)[1]', 'int')
		AS duration,
	event_data.value('(event/data[@name="logical_reads"]/value)[1]', 'int')
		AS logical_reads,
	event_data.value('(event/data[@name="physical_reads"]/value)[1]', 'int')
		AS physical_reads,
	event_data.value('(event/data[@name="writes"]/value)[1]', 'int') AS writes,
	event_data.value('(event/data[@name="statement"]/value)[1]', 'varchar(max)')
		AS statement
FROM(SELECT evnt.query('.') AS event_data
FROM
(SELECT CAST(target_data AS xml) AS target_data
	FROM sys.dm_xe_sessions s
	JOIN sys.dm_xe_session_targets t
	ON s.address = t.event_session_address
	WHERE s.name = 'test'
	AND t.target_name = 'ring_buffer'
) AS data
	CROSS APPLY target_data.nodes('RingBufferTarget/event') AS xevent(evnt)
) AS xevent(event_data)

-- you can update the previous query to aggregate this data directly
SELECT query_hash, SUM(cpu_time) AS cpu_time, SUM(duration) AS duration,
SUM(logical_reads) AS logical_reads, SUM(physical_reads) AS physical_reads,
SUM(writes) AS writes, MAX(statement) AS statement
FROM #eventdata
GROUP BY query_hash

-- run the following statements:
ALTER EVENT SESSION [test]
ON SERVER
STATE=STOP
GO
DROP EVENT SESSION [test] ON SERVER

-- the following example is exactly the same as before, but using the file target
CREATE EVENT SESSION test ON SERVER
ADD EVENT sqlserver.module_end(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.rpc_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.sp_statement_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text)),
ADD EVENT sqlserver.sql_statement_completed(
	ACTION(sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,
		sqlserver.sql_text))
ADD TARGET package0.event_file(SET filename=N'C:\Data\test.xel')
WITH (STARTUP_STATE=OFF)

-- after starting the session and capturing some events, you can query its data by using the following query
SELECT
	event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
	event_data.value('(event/action[@name="query_hash"]/value)[1]',
		'varchar(max)') AS query_hash,
	event_data.value('(event/data[@name="cpu_time"]/value)[1]', 'int')
		AS cpu_time,
	event_data.value('(event/data[@name="duration"]/value)[1]', 'int')
		AS duration,
	event_data.value('(event/data[@name="logical_reads"]/value)[1]', 'int')
		AS logical_reads,
	event_data.value('(event/data[@name="physical_reads"]/value)[1]', 'int')
		AS physical_reads,
	event_data.value('(event/data[@name="writes"]/value)[1]', 'int') AS writes,
	event_data.value('(event/data[@name="statement"]/value)[1]', 'varchar(max)')
AS statement
FROM
(
	SELECT CAST(event_data AS xml)
	FROM sys.fn_xe_file_target_read_file
	(
		'C:\Data\test*.xel',
		NULL,
		NULL,
		NULL
	)
) AS xevent(event_data)

-- make sure to replace the session_id as required if you are testing this code.
CREATE EVENT SESSION [test] ON SERVER
ADD EVENT sqlos.wait_info(
WHERE ([sqlserver].[session_id]=(61)))
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- start the event:
ALTER EVENT SESSION [test]
ON SERVER
STATE=START

-- for example, run the following query:
SELECT * FROM Production.Product p1 CROSS JOIN
Production.Product p2

-- then you can read the captured data:
SELECT
	event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
	event_data.value('(event/data[@name="wait_type"]/text)[1]', 'varchar(40)')
		AS wait_type,
	event_data.value('(event/data[@name="duration"]/value)[1]', 'int')
		AS duration,
	event_data.value('(event/data[@name="opcode"]/text)[1]', 'varchar(40)')
		AS opcode,
	event_data.value('(event/data[@name="signal_duration"]/value)[1]', 'int')
AS signal_duration
FROM(SELECT evnt.query('.') AS event_data
	FROM
(SELECT CAST(target_data AS xml) AS target_data
	FROM sys.dm_xe_sessions s
	JOIN sys.dm_xe_session_targets t
	ON s.address = t.event_session_address
	WHERE s.name = 'test'
	AND t.target_name = 'ring_buffer'
) AS data
	CROSS APPLY target_data.nodes('RingBufferTarget/event') AS xevent(evnt)
) AS xevent(event_data)

-- we could use the following query to get the collected data:
SELECT sii.instance_name, collection_time, [path] AS counter_name,
formatted_value AS counter_value_percent
FROM snapshots.performance_counter_values pcv
JOIN snapshots.performance_counter_instances pci
ON pcv.performance_counter_instance_id = pci.performance_counter_id
JOIN core.snapshots_internal si ON pcv.snapshot_id = si.snapshot_id
JOIN core.source_info_internal sii ON sii.source_id = si.source_id
WHERE pci.[path] = '\Processor(_Total)\% Processor Time'
ORDER BY pcv.collection_time desc


















