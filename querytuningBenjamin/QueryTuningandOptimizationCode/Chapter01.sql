
-- Chapter 1

-- As an example, copy the following query to the Management Studio Query Editor
SELECT DISTINCT(City) FROM Person.Address

-- To show an XML plan, you can use the following commands:
SET SHOWPLAN_XML ON
GO
SELECT DISTINCT(City) FROM Person.Address
GO
SET SHOWPLAN_XML OFF

-- Run the following query and request an XML plan:
SELECT * FROM Sales.SalesOrderDetail
WHERE OrderQty = 1

-- You can use the following code to display a text execution plan:
SET SHOWPLAN_TEXT ON
GO
SELECT DISTINCT(City) FROM Person.Address
GO
SET SHOWPLAN_TEXT OFF
GO

-- Run the following example:
SET SHOWPLAN_ALL ON
GO
SELECT DISTINCT(City) FROM Person.Address
GO
SET SHOWPLAN_ALL OFF
GO

-- Now run the following code:
SET STATISTICS PROFILE ON
GO
SELECT * FROM Sales.SalesOrderDetail
WHERE OrderQty * UnitPrice > 25000
GO
SET STATISTICS PROFILE OFF
GO

-- For example, in SQL Server 2014, the following query will produce a trivial plan:
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43666

-- You can use the undocumented (and therefore unsupported) trace flag 8757
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43666
OPTION (QUERYTRACEON 8757)

-- For example, even when the following query joins four tables and requires a Sort
SELECT pm.ProductModelID, pm.Name, Description, pl.CultureID,
cl.Name AS Language
FROM Production.ProductModel AS pm
	JOIN Production.ProductModelProductDescriptionCulture AS pl
		ON pm.ProductModelID = pl.ProductModelID
	JOIN Production.Culture AS cl
		ON cl.CultureID = pl.CultureID
	JOIN Production.ProductDescription AS pd
		ON pd.ProductDescriptionID = pl.ProductDescriptionID
ORDER BY pm.ProductModelID

-- Although the list of possible values is not documented, the following are popular and easy to obtain:
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43666
OPTION (MAXDOP 1)

-- Using the function
SELECT CustomerID, ('AW' + dbo.ufnLeadingZeros(CustomerID))
	AS GenerateAccountNumber
FROM Sales.Customer
ORDER BY CustomerID

-- If trying to run
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43666
OPTION (MAXDOP 8)

-- For example, the query
SELECT DISTINCT(CustomerID)
FROM Sales.SalesOrderHeader

-- Run the following statement to drop the existing statistics for the VacationHours column
DROP STATISTICS HumanResources.Employee._WA_Sys_0000000C_49C3F6B7

-- Next, temporarily disable automatic creation of statistics at the database level:
ALTER DATABASE AdventureWorks2012 SET AUTO_CREATE_STATISTICS OFF

-- Then run this query:
SELECT * FROM HumanResources.Employee
WHERE VacationHours = 48

-- Do not forget to reenable the automatic creation of statistics
ALTER DATABASE AdventureWorks2012 SET AUTO_CREATE_STATISTICS ON

-- Let’s suppose you intend to run the following query but forgot to include the WHERE clause:
SELECT * FROM Sales.SalesOrderHeader soh, Sales.SalesOrderDetail sod
WHERE soh.SalesOrderID = sod.SalesOrderID

-- For example, missing the join predicate in the following query will return an incorrect syntax error:
SELECT * FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod
-- ON soh.SalesOrderID = sod.SalesOrderID

-- Run the following example
DECLARE @code nvarchar(15)
SET @code = '95555Vi4081'
SELECT * FROM Sales.SalesOrderHeader
WHERE CreditCardApprovalCode = @code

-- To simulate this problem, run the following example:
SELECT * FROM Sales.SalesOrderDetail
ORDER BY UnitPrice

-- Suppose you create the following filtered index:
CREATE INDEX IX_Color ON Production.Product(Name, ProductNumber)
WHERE Color = 'White'

-- Then you run the following query:
DECLARE @color nvarchar(15)
SET @color = 'White'
SELECT Name, ProductNumber FROM Production.Product
WHERE Color = @color

-- However, the following query will use the index:
SELECT Name, ProductNumber FROM Production.Product
WHERE Color = 'White'

-- For now, remove the index we just created:
DROP INDEX Production.Product.IX_Color

-- A plan_handle is a hash value that represents a specific execution plan
SELECT * FROM sys.dm_exec_requests
CROSS APPLY
sys.dm_exec_query_plan(plan_handle)

-- The sys.dm_exec_query_stats DMV contains one row per query statement within the cached plan
SELECT * FROM sys.dm_exec_query_stats
CROSS APPLY
sys.dm_exec_query_plan(plan_handle)

-- You can run the following query to get this information
SELECT TOP 10 total_worker_time/execution_count AS avg_cpu_time,
plan_handle, query_plan
FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
ORDER BY avg_cpu_time DESC

-- Part of the generated code is shown next.
/****************************************************/
/* Created by: SQL Server 2014 Profiler */
/* Date: 12/18/2013 08:37:22 AM */
/****************************************************/
-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 5
-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share
exec @rc = sp_trace_create @TraceID output, 0, N'InsertFileNameHere', @maxfilesize,
NULL
if (@rc != 0) goto error
-- Client side File and Table cannot be scripted
-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 2, @on
exec sp_trace_setevent @TraceID, 10, 66, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 4, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 7, @on
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on

-- You could use the following code to create the extended event session:
CREATE EVENT SESSION [test] ON SERVER
ADD EVENT sqlserver.query_post_execution_showplan(
	ACTION(sqlserver.plan_handle)
	WHERE ([sqlserver].[database_name]=N'AdventureWorks2012'))
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- After the event session is created, you can start it using the ALTER EVENT SESSION statement
ALTER EVENT SESSION [test]
ON SERVER
STATE=START

-- You can also run the following code to see this data:
SELECT
	event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
	event_data.value('(event/action[@name="plan_handle"]/value)[1]',
		'varchar(max)') as plan_handle,
	event_data.query('event/data[@name="showplan_xml"]/value/*') as showplan_xml,
	event_data.value('(event/action[@name="sql_text"]/value)[1]',
		'varchar(max)') AS sql_text
FROM( SELECT evnt.query('.') AS event_data
FROM
( SELECT CAST(target_data AS xml) AS target_data
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t
ON s.address = t.event_session_address
WHERE s.name = 'test'
AND t.target_name = 'ring_buffer'
) AS data
CROSS APPLY target_data.nodes('RingBufferTarget/event') AS xevent(evnt)
) AS xevent(event_data)

-- Run the following statements:
ALTER EVENT SESSION [test]
ON SERVER
STATE=STOP
GO
DROP EVENT SESSION [test] ON SERVER

-- For example, run
SET STATISTICS TIME ON

-- and then run the following query:
SELECT DISTINCT(CustomerID)
FROM Sales.SalesOrderHeader

-- You can disable it like so:
SET STATISTICS TIME OFF

-- To enable it, run the following statement:
SET STATISTICS IO ON

-- Run this next statement to clean all the buffers from the buffer pool 
DBCC DROPCLEANBUFFERS

-- Then run the following query:
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 870

-- The only case when scan count will return 0 is when you’re seeking for only one value on a unique index
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 51119

-- If you try the following query
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 51119

-- Finally, in the following example, scan count is 4 because SQL Server has to perform four seeks:
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID IN (51119, 43664, 63371, 75119)

