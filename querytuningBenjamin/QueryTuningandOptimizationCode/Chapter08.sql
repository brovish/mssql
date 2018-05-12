
-- Chapter 8

-- run the following code:
DBCC FREEPROCCACHE
GO
CREATE PROCEDURE test
AS
CREATE TABLE #table1 (name varchar(40))
SELECT * FROM #table1
GO
EXEC test

-- you can find the other documented values by running the following query:
SELECT map_key, map_value FROM sys.dm_xe_map_values
WHERE name = 'statement_recompile_cause'

-- the following query provides a quick summary of what you can see in detail on the sys.dm_exec_cached_plans DMV:
SELECT * FROM sys.dm_os_memory_cache_counters
WHERE type IN ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR',
	'CACHESTORE_XPROC')

-- let’s take a look at the following query:
DBCC FREEPROCCACHE
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 79
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 59
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

-- the query will return the query text along with a link that you can click to show the graphical plan.
SELECT text, query_plan FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
WHERE text like '%Person%'

-- however, if we use the second version of the queries, like in
DBCC FREEPROCCACHE
GO
SELECT * FROM Person.Address
WHERE AddressID = 12
GO
SELECT * FROM Person.Address
WHERE AddressID = 37
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

-- let’s look at an example using sp_configure to enable this option
EXEC sp_configure 'optimize for ad hoc workloads', 1
RECONFIGURE
DBCC FREEPROCCACHE
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 79
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

-- now execute the following statements:
SELECT * FROM Person.Address
WHERE StateProvinceID = 79
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

-- finally, although it is recommended to keep this configuration option enabled
EXEC sp_configure 'optimize for ad hoc workloads', 0
RECONFIGURE

-- enable forced parameterization at the database level by running the following statement:
ALTER DATABASE AdventureWorks2012 SET PARAMETERIZATION FORCED

-- then run the following queries again:
DBCC FREEPROCCACHE
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 79
GO
SELECT * FROM Person.Address
WHERE StateProvinceID = 59
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

--- don’t forget to disable forced parameterization by running the following statement
ALTER DATABASE AdventureWorks2012 SET PARAMETERIZATION SIMPLE

-- create the following stored procedure:
CREATE PROCEDURE test (@stateid int)
AS
SELECT * FROM Person.Address
WHERE StateProvinceID = @stateid

-- and run the following code:
DBCC FREEPROCCACHE
GO
exec test @stateid = 79
GO
exec test @stateid = 59
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

-- you can run the following code, where the parameter 59 is used first
DBCC FREEPROCCACHE
GO
exec test @stateid = 59
GO
exec test @stateid = 79
GO
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text like '%Person%'

-- however, the StateProvinceID is not part of a unique index and has a wide data distribution
SELECT StateProvinceID, COUNT(*) AS cnt
FROM Person.Address
GROUP BY StateProvinceID
ORDER BY cnt

-- to see an example, let’s write a simple stored procedure
CREATE PROCEDURE test (@pid int)
AS
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @pid

-- run the following statement to execute the stored procedure:
EXEC test @pid = 897

-- try the following query, including a SET STATISTICS IO ON statement
SET STATISTICS IO ON
GO
EXEC test @pid = 870
GO

-- now clear the plan cache to remove the execution plan currently held in memory and then run the stored procedure again
DBCC FREEPROCCACHE
GO
EXEC test @pid = 870
GO

-- to take advantage of that, you could write the stored procedure as shown next:
ALTER PROCEDURE test (@pid int)
AS
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @pid
OPTION (OPTIMIZE FOR (@pid = 897))

-- if you want to check, test the case by running the following:
EXEC test @pid = 870

-- to do this, use the RECOMPILE hint, as shown next:
ALTER PROCEDURE test (@pid int)
AS
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @pid
OPTION (RECOMPILE)

-- the first version uses local variables, and the second one uses the OPTIMIZE FOR UNKNOWN hint
ALTER PROCEDURE test (@pid int)
AS
DECLARE @p int = @pid
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @p
GO
ALTER PROCEDURE test (@pid int)
AS
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @pid
OPTION (OPTIMIZE FOR UNKNOWN)

-- note that the OPTIMIZE FOR UNKNOWN query hint will apply to all the parameters used in a query 
-- unless you use the following syntax to target only a specific parameter:
ALTER PROCEDURE test (@pid int)
AS
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @pid
OPTION (OPTIMIZE FOR (@pid UNKNOWN))

-- for example, let’s use the following code with both local variables and the OPTION (RECOMPILE) hint:
ALTER PROCEDURE test (@pid int)
AS
DECLARE @p int = @pid
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = @p
OPTION (RECOMPILE)

-- and then run the following:
EXEC test @pid = 897

-- run the following code to do that:
CREATE DATABASE Test
GO
USE Test
GO
SELECT * INTO dbo.SalesOrderDetail
FROM AdventureWorks2012.Sales.SalesOrderDetail
GO
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID
ON dbo.SalesOrderDetail(ProductID)
GO
CREATE PROCEDURE test (@pid int)
AS
SELECT * FROM dbo.SalesOrderDetail
WHERE ProductID = @pid

-- start with a clean plan cache by running the following command:
DBCC FREEPROCCACHE

-- run the following script from the Test database
SELECT plan_handle, usecounts, pvt.set_options
FROM (
	SELECT plan_handle, usecounts, epa.attribute, epa.value
	FROM sys.dm_exec_cached_plans
	OUTER APPLY sys.dm_exec_plan_attributes(plan_handle) AS epa
	WHERE cacheobjtype = 'Compiled Plan') AS ecpa
PIVOT (MAX(ecpa.value) FOR ecpa.attribute IN ("set_options", "objectid")) AS pvt
WHERE pvt.objectid = OBJECT_ID('dbo.test')

-- in a real production database, this second execution may not perform as expected
EXEC test @pid = 898

-- select the plan_handle of the first plan created and use it to run the following query:
SELECT * FROM sys.dm_exec_query_plan(0x050007002255970FB049B8FB0200000001000000000000000000000000000000000000000000000000000000)

-- try this:
sp_recompile test

-- you could optionally use the following script to display the configured SET options for a specific set_options value:
DECLARE @set_options int = 4347
IF ((1 & @set_options) = 1) PRINT 'ANSI_PADDING'
IF ((4 & @set_options) = 4) PRINT 'FORCEPLAN'
IF ((8 & @set_options) = 8) PRINT 'CONCAT_NULL_YIELDS_NULL'
IF ((16 & @set_options) = 16) PRINT 'ANSI_WARNINGS'
IF ((32 & @set_options) = 32) PRINT 'ANSI_NULLS'
IF ((64 & @set_options) = 64) PRINT 'QUOTED_IDENTIFIER'
IF ((128 & @set_options) = 128) PRINT 'ANSI_NULL_DFLT_ON'
IF ((256 & @set_options) = 256) PRINT 'ANSI_NULL_DFLT_OFF'
IF ((512 & @set_options) = 512) PRINT 'NoBrowseTable'
IF ((4096 & @set_options) = 4096) PRINT 'ARITH_ABORT'
IF ((8192 & @set_options) = 8192) PRINT 'NUMERIC_ROUNDABORT'
IF ((16384 & @set_options) = 16384) PRINT 'DATEFIRST'
IF ((32768 & @set_options) = 32768) PRINT 'DATEFORMAT'
IF ((65536 & @set_options) = 65536) PRINT 'LanguageID'

-- c# code for SET options test
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
			Console.Write("Enter ProductID: ");
			string pid = Console.ReadLine();
			cnn = new SqlConnection("Data Source=(local);Initial Catalog=Test;
				Integrated Security=SSPI");
			SqlCommand cmd = new SqlCommand();
			cmd.Connection = cnn;
			cmd.CommandText = "dbo.test";
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.Add("@pid", SqlDbType.Int).Value = pid;
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

