---------------------------------------------------------------------
-- T-SQL Querying (Microsoft Press, 2015)
-- Chapter 09 - Programmable Objects
-- © Itzik Ben-Gan, Adam Machanic
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Dynamic SQL
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Using the EXEC Command
---------------------------------------------------------------------

-- Simple example with EXEC
SET NOCOUNT ON;
USE TSQLV3;

DECLARE @s AS NVARCHAR(200);
SET @s = N'Davis'; -- originates in user input

DECLARE @sql AS NVARCHAR(1000);
SET @sql = N'SELECT empid, firstname, lastname, hiredate
FROM HR.Employees WHERE lastname = N''' + @s + N''';';

PRINT @sql; -- for debug purposes
EXEC (@sql);
GO

-- SQL Injection

-- Try with
-- SET @s = N'abc''; PRINT ''SQL injection!''; --';

-- Try with
-- SET @s = N'abc'' UNION ALL SELECT object_id, SCHEMA_NAME(schema_id), name, NULL FROM sys.objects WHERE type IN (''U'', ''V''); --';

-- Try with
-- SET @s = N'abc'' UNION ALL SELECT NULL, name, NULL, NULL FROM sys.columns WHERE object_id = 485576768; --';

-- Try with
-- SET @s = N'abc'' UNION ALL SELECT NULL, companyname, phone, NULL FROM Sales.Customers; --';

---------------------------------------------------------------------
-- Using EXEC AT
---------------------------------------------------------------------

-- Create a linked server
EXEC sp_addlinkedserver
  @server = N'YourServer',
  @srvproduct = N'SQL Server';
GO

-- Construct and execute code
DECLARE @sql AS NVARCHAR(1000), @pid AS INT;

SET @sql = 
N'SELECT productid, productname, unitprice
FROM TSQLV3.Production.Products
WHERE productid = ?;';

SET @pid = 3;

EXEC(@sql, @pid) AT [YourServer];
GO

---------------------------------------------------------------------
-- Using the sp_executesql Procedure
---------------------------------------------------------------------

-- Has Interface

-- Input Parameters
DECLARE @s AS NVARCHAR(200);
SET @s = N'Davis';

DECLARE @sql AS NVARCHAR(1000);
SET @sql = 'SELECT empid, firstname, lastname, hiredate
FROM HR.Employees WHERE lastname = @lastname;';

PRINT @sql; -- For debug purposes

EXEC sp_executesql
  @stmt = @sql,
  @params = N'@lastname AS NVARCHAR(200)',
  @lastname = @s;
GO

---------------------------------------------------------------------
-- Dynamic Pivot
---------------------------------------------------------------------

-- Example for dynamic pivot from Chapter 4
USE TSQLV3;

DECLARE
  @cols AS NVARCHAR(1000),
  @sql  AS NVARCHAR(4000);

SET @cols = --Ramneek: generating the column list like such is not readable and looks unnecessarily complex using XML path(although XML path might be faster. Benchmark the results). No need to use it. See my version below
  STUFF(
    (SELECT N',' + QUOTENAME(orderyear) AS [text()]
     FROM (SELECT DISTINCT YEAR(orderdate) AS orderyear
           FROM Sales.Orders) AS Years
     ORDER BY orderyear
     FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

SET @sql = N'SELECT custid, ' + @cols + N'
FROM (SELECT custid, YEAR(orderdate) AS orderyear, val
      FROM Sales.OrderValues) AS D
  PIVOT(SUM(val) FOR orderyear IN(' + @cols + N')) AS P;';

EXEC sys.sp_executesql @stmt = @sql;

--ramneek:
declare @cols_r as nvarchar(max)='';

select @cols_r += concat(',',  quotename(DATEPART(yy,orderdate)) )
		--@cols_r += concat(',', '[', DATEPART(yy,orderdate), ']')--use quotename instead
from Sales.OrderValues
group by DATEPART(yy,orderdate)

----out of the comma separated list of quoted values, extract columns in this format: [2013],[2014],[2015] by removing the leading comma. you can use either stuff or substring
--select IIF(len(@cols_r)>0, SUBSTRING(@cols_r,2,len(@cols_r)), null)
--	   ,STUFF(@cols_r, 1, 1, '')

declare @sql_r as nvarchar(max) = 'select * 
from (select custid, val, DATEPART(yy,orderdate) as yr
		from Sales.OrderValues) as src
	pivot(sum(val) for yr in ('+ IIF(len(@cols_r)>0, SUBSTRING(@cols_r,2,len(@cols_r)), null) + ')) as pvt';--works with STUFF(@cols_r, 1, 1, '') as well

exec(@sql_r);
--ramneek:end

-- Creation script for the sp_pivot stored procedure
USE master;
GO
IF OBJECT_ID(N'dbo.sp_pivot', N'P') IS NOT NULL DROP PROC dbo.sp_pivot;
GO

CREATE PROC dbo.sp_pivot
  @query    AS NVARCHAR(MAX),
  @on_rows  AS NVARCHAR(MAX),
  @on_cols  AS NVARCHAR(MAX),
  @agg_func AS NVARCHAR(257) = N'MAX',
  @agg_col  AS NVARCHAR(MAX)
AS
BEGIN TRY
  -- Input validation
  IF @query IS NULL OR @on_rows IS NULL OR @on_cols IS NULL
      OR @agg_func IS NULL OR @agg_col IS NULL
    THROW 50001, 'Invalid input parameters.', 1;

  -- Additional input validation goes here (SQL injection attempts, etc.)

  DECLARE 
    @sql     AS NVARCHAR(MAX),
    @cols    AS NVARCHAR(MAX),
    @newline AS NVARCHAR(2) = NCHAR(13) + NCHAR(10);

  -- If input is a valid table or view
  -- construct a SELECT statement against it
  IF COALESCE(OBJECT_ID(@query, N'U'), OBJECT_ID(@query, N'V')) IS NOT NULL
    SET @query = N'SELECT * FROM ' + @query;

  -- Make the query a derived table
  SET @query = N'(' + @query + N') AS Query';

  -- Handle * input in @agg_col
  IF @agg_col = N'*' SET @agg_col = N'1';

  -- Construct column list
  SET @sql =
    N'SET @result = '                                    + @newline +
    N'  STUFF('                                          + @newline +
    N'    (SELECT N'',['' + '
             + 'CAST(pivot_col AS sysname) + '
             + 'N'']'' AS [text()]'                      + @newline +
    N'     FROM (SELECT DISTINCT('
             + @on_cols + N') AS pivot_col'              + @newline +
    N'           FROM' + @query + N') AS DistinctCols'   + @newline +
    N'     ORDER BY pivot_col'+ @newline +
    N'     FOR XML PATH('''')),'+ @newline +
    N'    1, 1, N'''');'

  EXEC sp_executesql
    @stmt   = @sql,
    @params = N'@result AS NVARCHAR(MAX) OUTPUT',
    @result = @cols OUTPUT;

  -- Create the PIVOT query
  SET @sql = 
    N'SELECT *'                                          + @newline +
    N'FROM (SELECT '
              + @on_rows
              + N', ' + @on_cols + N' AS pivot_col'
              + N', ' + @agg_col + N' AS agg_col'        + @newline +
    N'      FROM ' + @query + N')' +
              + N' AS PivotInput'                        + @newline +
    N'  PIVOT(' + @agg_func + N'(agg_col)'               + @newline +
    N'    FOR pivot_col IN(' + @cols + N')) AS PivotOutput;'

  EXEC sp_executesql @sql;

END TRY
BEGIN CATCH
  ;THROW;
END CATCH;
GO

-- Count of orders per employee and order year pivoted by order month
EXEC TSQLV3.dbo.sp_pivot
  @query    = N'Sales.Orders',
  @on_rows  = N'empid, YEAR(orderdate) AS orderyear',
  @on_cols  = N'MONTH(orderdate)',
  @agg_func = N'COUNT',
  @agg_col  = N'*';

-- Sum of value (quantity * unit price) per employee pivoted by order year
EXEC TSQLV3.dbo.sp_pivot
  @query    = N'SELECT O.orderid, empid, orderdate, qty, unitprice
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid',
  @on_rows  = N'empid',
  @on_cols  = N'YEAR(orderdate)',
  @agg_func = N'SUM',
  @agg_col  = N'qty * unitprice';

-- Cleanup
USE master;

IF OBJECT_ID(N'dbo.sp_pivot', N'P') IS NOT NULL DROP PROC dbo.sp_pivot;
GO

---------------------------------------------------------------------
-- Dynamic Search Conditions
---------------------------------------------------------------------

-- Code to create the Orders table and supporting indexes
SET NOCOUNT ON;
USE tempdb;

IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
GO

SELECT orderid, custid, empid, orderdate,
  CAST('A' AS CHAR(200)) AS filler
INTO dbo.Orders
FROM TSQLV3.Sales.Orders;

CREATE CLUSTERED INDEX idx_orderdate ON dbo.Orders(orderdate);
CREATE UNIQUE INDEX idx_orderid ON dbo.Orders(orderid);
CREATE INDEX idx_custid_empid ON dbo.Orders(custid, empid) INCLUDE(orderid, orderdate, filler);
GO

-- Solution using static query
IF OBJECT_ID(N'dbo.GetOrders', N'P') IS NOT NULL DROP PROC dbo.GetOrders;
GO
CREATE PROC dbo.GetOrders
  @orderid   AS INT  = NULL,
  @custid    AS INT  = NULL,
  @empid     AS INT  = NULL,
  @orderdate AS DATE = NULL
AS

SELECT orderid, custid, empid, orderdate, filler
FROM dbo.Orders
WHERE (orderid   = @orderid   OR @orderid   IS NULL)
  AND (custid    = @custid    OR @custid    IS NULL)
  AND (empid     = @empid     OR @empid     IS NULL)
  AND (orderdate = @orderdate OR @orderdate IS NULL);
GO

-- Test procedure
EXEC dbo.GetOrders @orderdate = '20140101';

-- Solution using static query with OPTION(RECOMPILE)
IF OBJECT_ID(N'dbo.GetOrders', N'P') IS NOT NULL DROP PROC dbo.GetOrders;
GO
CREATE PROC dbo.GetOrders
  @orderid   AS INT  = NULL,
  @custid    AS INT  = NULL,
  @empid     AS INT  = NULL,
  @orderdate AS DATE = NULL
AS

SELECT orderid, custid, empid, orderdate, filler
FROM dbo.Orders
WHERE (orderid   = @orderid   OR @orderid   IS NULL)
  AND (custid    = @custid    OR @custid    IS NULL)
  AND (empid     = @empid     OR @empid     IS NULL)
  AND (orderdate = @orderdate OR @orderdate IS NULL)
OPTION (RECOMPILE);
GO

-- Test procedure
EXEC dbo.GetOrders @orderdate = '20140101';
EXEC dbo.GetOrders @orderid   = 10248;

-- Solution using dynamic SQL with parameters.
IF OBJECT_ID(N'dbo.GetOrders', N'P') IS NOT NULL DROP PROC dbo.GetOrders;
GO
CREATE PROC dbo.GetOrders
  @orderid   AS INT  = NULL,
  @custid    AS INT  = NULL,
  @empid     AS INT  = NULL,
  @orderdate AS DATE = NULL
AS

DECLARE @sql AS NVARCHAR(1000);

SET @sql = 
    N'SELECT orderid, custid, empid, orderdate, filler'
  + N' /* 27702431-107C-478C-8157-6DFCECC148DD */'
  + N' FROM dbo.Orders'
  + N' WHERE 1 = 1'
  + CASE WHEN @orderid IS NOT NULL THEN
      N' AND orderid = @oid' ELSE N'' END
  + CASE WHEN @custid IS NOT NULL THEN
      N' AND custid = @cid' ELSE N'' END
  + CASE WHEN @empid IS NOT NULL THEN
      N' AND empid = @eid' ELSE N'' END
  + CASE WHEN @orderdate IS NOT NULL THEN
      N' AND orderdate = @dt' ELSE N'' END;

EXEC sp_executesql
  @stmt = @sql,
  @params = N'@oid AS INT, @cid AS INT, @eid AS INT, @dt AS DATE',
  @oid = @orderid,
  @cid = @custid,
  @eid = @empid,
  @dt  = @orderdate;
GO

-- Test procedure
EXEC dbo.GetOrders @orderdate = '20140101';
EXEC dbo.GetOrders @orderdate = '20140102';
EXEC dbo.GetOrders @orderid   = 10248;

-- To see plan reuse
SELECT usecounts, text
FROM sys.dm_exec_cached_plans AS CP
  CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS ST
WHERE ST.text LIKE '%27702431-107C-478C-8157-6DFCECC148DD%'
  AND ST.text NOT LIKE '%sys.dm_exec_cached_plans%'
  AND CP.objtype = 'Prepared';

---------------------------------------------------------------------
-- Dynamic Sorting
---------------------------------------------------------------------

-- Solution based on static query with OPTION(RECOMPILE)
USE TSQLV3;

IF OBJECT_ID(N'dbo.GetSortedShippers', N'P') IS NOT NULL DROP PROC dbo.GetSortedShippers;
GO
CREATE PROC dbo.GetSortedShippers
  @colname AS sysname, @sortdir AS CHAR(1) = 'A'
AS

SELECT shipperid, companyname, phone
FROM Sales.Shippers
ORDER BY
  CASE WHEN @colname = N'shipperid'   AND @sortdir = 'A' THEN shipperid   END,
  CASE WHEN @colname = N'companyname' AND @sortdir = 'A' THEN companyname END,
  CASE WHEN @colname = N'phone'       AND @sortdir = 'A' THEN phone       END,
  CASE WHEN @colname = N'shipperid'   AND @sortdir = 'D' THEN shipperid   END DESC,
  CASE WHEN @colname = N'companyname' AND @sortdir = 'D' THEN companyname END DESC,
  CASE WHEN @colname = N'phone'       AND @sortdir = 'D' THEN phone       END DESC
OPTION (RECOMPILE);
GO

-- Test proc
EXEC dbo.GetSortedShippers N'shipperid', N'D';

-- Solution based on dynamic SQL
IF OBJECT_ID(N'dbo.GetSortedShippers', N'P') IS NOT NULL DROP PROC dbo.GetSortedShippers;
GO
CREATE PROC dbo.GetSortedShippers
  @colname AS sysname, @sortdir AS CHAR(1) = 'A'
AS

IF @colname NOT IN(N'shipperid', N'companyname', N'phone')
  THROW 50001, 'Column name not supported. Possibly a SQL injection attempt.', 1;
  
DECLARE @sql AS NVARCHAR(1000);

SET @sql = N'SELECT shipperid, companyname, phone
FROM Sales.Shippers
ORDER BY '
  + QUOTENAME(@colname) + CASE @sortdir WHEN 'D' THEN N' DESC' ELSE '' END + ';';

EXEC sys.sp_executesql @stmt = @sql;
GO

-- Test proc
EXEC dbo.GetSortedShippers N'shipperid', N'D';

-- Easy to extend
IF OBJECT_ID(N'dbo.GetSortedShippers', N'P') IS NOT NULL DROP PROC dbo.GetSortedShippers;
GO
CREATE PROC dbo.GetSortedShippers
  @colname1 AS sysname, @sortdir1 AS CHAR(1) = 'A',
  @colname2 AS sysname = NULL, @sortdir2 AS CHAR(1) = 'A',
  @colname3 AS sysname = NULL, @sortdir3 AS CHAR(1) = 'A'
AS

IF @colname1 NOT IN(N'shipperid', N'companyname', N'phone')
   OR @colname2 IS NOT NULL AND @colname2 NOT IN(N'shipperid', N'companyname', N'phone')
   OR @colname3 IS NOT NULL AND @colname3 NOT IN(N'shipperid', N'companyname', N'phone')
  THROW 50001, 'Column name not supported. Possibly a SQL injection attempt.', 1;
  
DECLARE @sql AS NVARCHAR(1000);

SET @sql = N'SELECT shipperid, companyname, phone
FROM Sales.Shippers
ORDER BY '
  + QUOTENAME(@colname1) + CASE @sortdir1 WHEN 'D' THEN N' DESC' ELSE '' END
  + ISNULL(N',' + QUOTENAME(@colname2) + CASE @sortdir2 WHEN 'D' THEN N' DESC' ELSE '' END, N'')
  + ISNULL(N',' + QUOTENAME(@colname3) + CASE @sortdir3 WHEN 'D' THEN N' DESC' ELSE '' END, N'')
  + ';';

EXEC sys.sp_executesql @stmt = @sql;
GO

---------------------------------------------------------------------
-- User-Defined Functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Scalar UDFs
---------------------------------------------------------------------

-- Inline expression
USE PerformanceV3;

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderdate = DATEADD(year, DATEDIFF(year, '19001231', orderdate), '19001231');

-- Check performance of serial plan
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderdate = DATEADD(year, DATEDIFF(year, '19001231', orderdate), '19001231')
OPTION(MAXDOP 1);

-- Encapsulate logic in a scalar UDF based on a single expression
IF OBJECT_ID(N'dbo.EndOfYear') IS NOT NULL DROP FUNCTION dbo.EndOfYear;
GO
CREATE FUNCTION dbo.EndOfYear(@dt AS DATE) RETURNS DATE
AS
BEGIN
  RETURN DATEADD(year, DATEDIFF(year, '19001231', @dt), '19001231');
END;
GO

-- Query with scalar UDF
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderdate = dbo.EndOfYear(orderdate);

-- Use inline UDF
IF OBJECT_ID(N'dbo.EndOfYear') IS NOT NULL DROP FUNCTION dbo.EndOfYear;
GO
CREATE FUNCTION dbo.EndOfYear(@dt AS DATE) RETURNS TABLE
AS
RETURN
  SELECT DATEADD(year, DATEDIFF(year, '19001231', @dt), '19001231') AS endofyear;
GO

-- Query with inline UDF
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderdate = (SELECT endofyear FROM dbo.EndOfYear(orderdate));

-- Example for a scalar UDF with multiple statements
USE TSQLV3;
IF OBJECT_ID(N'dbo.RemoveChars', N'FN') IS NOT NULL DROP FUNCTION dbo.RemoveChars;
GO
CREATE FUNCTION dbo.RemoveChars(@string AS NVARCHAR(4000), @pattern AS NVARCHAR(4000))
  RETURNS NVARCHAR(4000)
AS
BEGIN
  DECLARE @pos AS INT;
  SET @pos = PATINDEX(@pattern, @string);

  WHILE @pos > 0
  BEGIN
    SET @string = STUFF(@string, @pos, 1, N'');
    SET @pos = PATINDEX(@pattern, @string);
  END;

  RETURN @string;
END;
GO

-- Test function
SELECT custid, phone, dbo.RemoveChars(phone, N'%[^0-9]%') AS cleanphone
FROM Sales.Customers;

-- Using regex
-- See definition of function dbo.RegExReplace later in the chapter under SQLCLR Programming
-- Paremeters: @pattern, @input, @replacement
SELECT custid, phone, dbo.RegExReplace(N'[^0-9]', phone, N'') AS cleanphone
FROM Sales.Customers;

---------------------------------------------------------------------
-- Multi-Statement TVFs
---------------------------------------------------------------------

-- DDL and sample data for Employees table
SET NOCOUNT ON;
USE tempdb;
GO
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL CONSTRAINT PK_Employees PRIMARY KEY,
  mgrid   INT         NULL     CONSTRAINT FK_Employees_Employees REFERENCES dbo.Employees,
  empname VARCHAR(25) NOT NULL,
  salary  MONEY       NOT NULL,
  CHECK (empid <> mgrid)
);

INSERT INTO dbo.Employees(empid, mgrid, empname, salary)
  VALUES(1, NULL, 'David', $10000.00),
        (2, 1, 'Eitan', $7000.00),
        (3, 1, 'Ina', $7500.00),
        (4, 2, 'Seraph', $5000.00),
        (5, 2, 'Jiru', $5500.00),
        (6, 2, 'Steve', $4500.00),
        (7, 3, 'Aaron', $5000.00),
        (8, 5, 'Lilach', $3500.00),
        (9, 7, 'Rita', $3000.00),
        (10, 5, 'Sean', $3000.00),
        (11, 7, 'Gabriel', $3000.00),
        (12, 9, 'Emilia' , $2000.00),
        (13, 9, 'Michael', $2000.00),
        (14, 9, 'Didi', $1500.00);

CREATE UNIQUE INDEX idx_unc_mgr_emp_i_name_sal ON dbo.Employees(mgrid, empid)
  INCLUDE(empname, salary);
GO

-- Definition of GetSubtree function
IF OBJECT_ID(N'dbo.GetSubtree', N'TF') IS NOT NULL DROP FUNCTION dbo.GetSubtree;
GO
CREATE FUNCTION dbo.GetSubtree (@mgrid AS INT, @maxlevels AS INT = NULL)
RETURNS @Tree TABLE
(
  empid   INT          NOT NULL PRIMARY KEY,
  mgrid   INT          NULL,
  empname VARCHAR(25)  NOT NULL,
  salary  MONEY        NOT NULL,
  lvl     INT          NOT NULL
)
AS
BEGIN
  DECLARE @lvl AS INT = 0;

  -- Insert subtree root node into @Tree
  INSERT INTO @Tree
    SELECT empid, mgrid, empname, salary, @lvl
    FROM dbo.Employees
    WHERE empid = @mgrid;

  WHILE @@ROWCOUNT > 0 AND (@lvl < @maxlevels OR @maxlevels IS NULL)
  BEGIN
    SET @lvl += 1;

    -- Insert children of nodes from prev level into @Tree
    INSERT INTO @Tree
      SELECT E.empid, E.mgrid, E.empname, E.salary, @lvl
      FROM dbo.Employees AS E
        INNER JOIN @Tree AS T
          ON E.mgrid = T.empid AND T.lvl = @lvl - 1;
  END;
  
  RETURN;
END;
GO

-- test
SELECT empid, empname, mgrid, salary, lvl
FROM GetSubtree(3, NULL);
GO

---------------------------------------------------------------------
-- Stored Procedures
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Compilations, Recompilations and Reuse of Execution Plans
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Reuse of Execution Plans and Parameter Sniffing
---------------------------------------------------------------------

-- Make sure to rerun PerformanceV3.sql to start with a clean database

-- Creating GetOrders procedure
USE PerformanceV3;
IF OBJECT_ID(N'dbo.GetOrders', N'P') IS NOT NULL DROP PROC dbo.GetOrders;
GO

CREATE PROC dbo.GetOrders( @orderid AS INT )
AS

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @orderid;
GO

-- Execute first time with high selectivity
EXEC dbo.GetOrders @orderid = 999991;

-- Execute again with high selectivity
EXEC dbo.GetOrders @orderid = 999996;

-- Check plan reuse
SELECT CP.usecounts, CP.cacheobjtype, CP.objtype, CP.plan_handle, ST.text
FROM sys.dm_exec_cached_plans AS CP
  CROSS APPLY sys.dm_exec_sql_text(CP.plan_handle) AS ST
WHERE ST.text LIKE '%703FCFF2-970F-4777-A8B7-8A87B8BE0A4D%'
  AND ST.text NOT LIKE '%sys.dm_exec_cached_plans%';

-- Execute again with medium selectivity
EXEC dbo.GetOrders @orderid = 800001;
GO

-- Add grouping and aggregation
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

SELECT empid, COUNT(*) AS numorders
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @orderid
GROUP BY empid;
GO

---------------------------------------------------------------------
-- Preventing Reuse of Execution Plans
---------------------------------------------------------------------

-- The RECOMPILE query hint
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @orderid
OPTION(RECOMPILE);
GO

-- Execute with both low and high selectivity
EXEC dbo.GetOrders @orderid = 999991;
EXEC dbo.GetOrders @orderid = 800001;
GO

---------------------------------------------------------------------
-- Lack of Variable Sniffing
---------------------------------------------------------------------

-- Using a variable in the procedure
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

DECLARE @i AS INT = @orderid - 1;

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @i;
GO

-- Execute with high selectivity
EXEC dbo.GetOrders @orderid = 999997;
GO

-- If input is typical, solve with OPTIMIZE FOR
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

DECLARE @i AS INT = @orderid - 1;

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @i
OPTION (OPTIMIZE FOR(@i = 2147483647));
GO

-- Test procedure
EXEC dbo.GetOrders @orderid = 999997;
GO

-- If no typical input, solve with RECOMPILE
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

DECLARE @i AS INT = @orderid - 1;

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @i
OPTION (RECOMPILE);
GO

-- Test procedure with high selectivity
EXEC dbo.GetOrders @orderid = 999997;

-- Test procedure with low selectivity
EXEC dbo.GetOrders @orderid = 800002;
  
---------------------------------------------------------------------
-- Preventing Parameter Sniffing
---------------------------------------------------------------------

-- Add 100000 rows to table
INSERT INTO dbo.Orders(orderid, custid, empid, shipperid, orderdate, filler)
  SELECT 2000000 + orderid, custid, empid, shipperid, orderdate, filler
  FROM dbo.Orders
  WHERE orderid <= 100000;

-- Show histogram
DBCC SHOW_STATISTICS (N'dbo.Orders', N'PK_Orders') WITH HISTOGRAM;

-- In 2014, new CE takes changes into consideration as shown in Chapter 2
-- Prior to 2014, estimate based just on histogram
SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= 1000001
OPTION(QUERYTRACEON 9481);
GO

-- Solution using variable
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

DECLARE @i AS INT = @orderid;

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @i;
GO

-- Test procedure
EXEC dbo.GetOrders @orderid = 1000001;
GO

-- Solution using OPTIMIZE FOR UNKNOWN hint
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @orderid
OPTION(OPTIMIZE FOR (@orderid UNKNOWN));
GO

-- Test procedure
EXEC dbo.GetOrders @orderid = 1000001;
GO

-- In SQL Server 2014 CE creates a good estimate, taking changes into consideration
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @orderid;
GO

-- Test procedure
EXEC dbo.GetOrders @orderid = 1000001;
GO

-- Delete rows that were added for this test and update statistics
DELETE FROM dbo.Orders WHERE orderid > 1000000;
UPDATE STATISTICS dbo.Orders WITH FULLSCAN;
GO

---------------------------------------------------------------------
-- Recompilations
---------------------------------------------------------------------

-- Force a recompile
EXEC sp_recompile N'dbo.GetOrders';

-- Execute twice, and change a plan-affecting set option in between
EXEC dbo.GetOrders @orderid = 1000000;
SET CONCAT_NULL_YIELDS_NULL OFF;
EXEC dbo.GetOrders @orderid = 1000000;
SET CONCAT_NULL_YIELDS_NULL ON;

-- Check plans in cache
SELECT CP.usecounts, PA.attribute, PA.value
FROM sys.dm_exec_cached_plans AS CP
  CROSS APPLY sys.dm_exec_sql_text(CP.plan_handle) AS ST
  CROSS APPLY sys.dm_exec_plan_attributes(CP.plan_handle) AS PA
WHERE ST.text LIKE '%703FCFF2-970F-4777-A8B7-8A87B8BE0A4D%'
  AND ST.text NOT LIKE '%sys.dm_exec_cached_plans%'
  AND attribute = 'set_options';
GO

-- To avoid plan optimality recompiles, use KEEPFIXED PLAN
ALTER PROC dbo.GetOrders( @orderid AS INT )
AS

SELECT orderid, custid, empid, orderdate, filler
/* 703FCFF2-970F-4777-A8B7-8A87B8BE0A4D */
FROM dbo.Orders
WHERE orderid >= @orderid
OPTION(KEEPFIXED PLAN);
GO

-- Make sure to rerun PerformanceV3.sql

---------------------------------------------------------------------
-- Table Type and Table-Valued Parameters
---------------------------------------------------------------------

-- User defined table type
USE TSQLV3;
IF TYPE_ID('dbo.OrderIDs') IS NOT NULL DROP TYPE dbo.OrderIDs;
GO
CREATE TYPE dbo.OrderIDs AS TABLE 
( 
  pos INT NOT NULL PRIMARY KEY,
  orderid INT NOT NULL UNIQUE
);
GO

-- Use table type with table variable
DECLARE @T AS dbo.OrderIDs;
INSERT INTO @T(pos, orderid) VALUES(1, 10248),(2, 10250),(3, 10249);
SELECT * FROM @T;
GO

-- Create procedure with table-valued parameter
IF OBJECT_ID(N'dbo.GetOrders', N'P') IS NOT NULL DROP PROC dbo.GetOrders;
GO
CREATE PROC dbo.GetOrders( @T AS dbo.OrderIDs READONLY )
AS

SELECT O.orderid, O.orderdate, O.custid, O.empid
FROM Sales.Orders AS O
  INNER JOIN @T AS K
    ON O.orderid = K.orderid
ORDER BY K.pos;
GO

-- Execute procedure
DECLARE @MyOrderIDs AS dbo.OrderIDs;
INSERT INTO @MyOrderIDs(pos, orderid) VALUES(1, 10248),(2, 10250),(3, 10249);
EXEC dbo.GetOrders @T = @MyOrderIDs;
GO

-- cleanup
IF OBJECT_ID(N'dbo.GetOrders', N'P') IS NOT NULL DROP PROC dbo.GetOrders;
IF TYPE_ID('dbo.OrderIDs') IS NOT NULL DROP TYPE dbo.OrderIDs;

---------------------------------------------------------------------
-- EXECUTE WITH RESULT SETS
---------------------------------------------------------------------

-- Create proc GetOrderInfo
IF OBJECT_ID(N'dbo.GetOrderInfo', N'P') IS NOT NULL DROP PROC dbo.GetOrderInfo;
GO
CREATE PROC dbo.GetOrderInfo( @orderid AS INT )
AS
 
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderid = @orderid;
 
SELECT orderid, productid, qty, unitprice
FROM Sales.OrderDetails
WHERE orderid = @orderid;
GO

-- Metadata match, hence the code runs successfully
EXEC dbo.GetOrderInfo @orderid = 10248
WITH RESULT SETS
(
  (
    orderid   INT  NOT NULL, 
    orderdate DATE NOT NULL, 
    custid    INT  NOT NULL,
    empid     INT      NULL
  ),
  (
    orderid   INT            NOT NULL,
    productid INT            NOT NULL,
    qty       SMALLINT       NOT NULL,
    unitprice NUMERIC(19, 3) NOT NULL
  )
);

-- Change column name
EXEC dbo.GetOrderInfo @orderid = 10248
WITH RESULT SETS
(
  (
    id        INT  NOT NULL, 
    orderdate DATE NOT NULL, 
    custid    INT  NOT NULL,
    empid     INT      NULL
  ),
  (
    id        INT            NOT NULL,
    productid INT            NOT NULL,
    qty       SMALLINT       NOT NULL,
    unitprice NUMERIC(19, 3) NOT NULL
  )
);
GO

-- Change number of columns and code fails
EXEC dbo.GetOrderInfo @orderid = 10248
WITH RESULT SETS
(
  (
    orderid   INT  NOT NULL, 
    orderdate DATE NOT NULL, 
    custid    INT  NOT NULL
  ),
  (
    orderid   INT            NOT NULL,
    productid INT            NOT NULL,
    qty       SMALLINT       NOT NULL,
    unitprice NUMERIC(19, 3) NOT NULL
  )
);
GO

-- Cleanup
IF OBJECT_ID(N'dbo.GetOrderInfo', N'P') IS NOT NULL DROP PROC dbo.GetOrderInfo;

---------------------------------------------------------------------
-- Triggers
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Trigger Types and Uses
---------------------------------------------------------------------

---------------------------------------------------------------------
-- AFTER DML Triggers
---------------------------------------------------------------------

-- AFTER trigger example

-- Create table T1
SET NOCOUNT ON; 
USE tempdb; 
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1; 

CREATE TABLE dbo.T1 
( 
  keycol       INT         NOT NULL IDENTITY
    CONSTRAINT PK_T1 PRIMARY KEY, 
  datacol      VARCHAR(10) NOT NULL,
  lastmodified DATETIME2   NOT NULL
    CONSTRAINT DFT_T1_lastmodified DEFAULT(SYSDATETIME())
);
GO

-- Trigger updating lastmodified value
CREATE TRIGGER trg_T1_u ON T1 AFTER UPDATE
AS

UPDATE T1
  SET lastmodified = SYSDATETIME()
FROM dbo.T1
  INNER JOIN inserted AS I
    ON I.keycol = T1.keycol;
GO

-- Disabling nested triggers (on by default)
EXEC sp_configure 'nested triggers', 0;
RECONFIGURE;

-- Enabling nested triggers
EXEC sp_configure 'nested triggers', 1;
RECONFIGURE;

-- Enabling recursive triggers
ALTER DATABASE MyDB SET RECURSIVE_TRIGGERS ON;

---------------------------------------------------------------------
-- AFTER DDL Triggers
---------------------------------------------------------------------

-- DDL trigger example

-- Create database testdb
USE master;
IF DB_ID(N'testdb') IS NOT NULL DROP DATABASE testdb;
CREATE DATABASE testdb;
GO
USE testdb;
GO

-- Create table for audit information
IF OBJECT_ID(N'dbo.AuditDDLEvents', N'U') IS NOT NULL
  DROP TABLE dbo.AuditDDLEvents;

CREATE TABLE dbo.AuditDDLEvents
(
  auditlsn         INT      NOT NULL IDENTITY,
  posttime         DATETIME NOT NULL,
  eventtype        sysname  NOT NULL,
  loginname        sysname  NOT NULL,
  schemaname       sysname  NOT NULL,
  objectname       sysname  NOT NULL,
  targetobjectname sysname  NULL,
  eventdata        XML      NOT NULL,
  CONSTRAINT PK_AuditDDLEvents PRIMARY KEY(auditlsn)
);
GO

-- Audit trigger
CREATE TRIGGER trg_audit_ddl_events ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
SET NOCOUNT ON;

DECLARE @eventdata AS XML = eventdata();

INSERT INTO dbo.AuditDDLEvents(
  posttime, eventtype, loginname, schemaname, objectname, targetobjectname, eventdata)
  VALUES( @eventdata.value('(/EVENT_INSTANCE/PostTime)[1]',         'VARCHAR(23)'),
          @eventdata.value('(/EVENT_INSTANCE/EventType)[1]',        'sysname'),
          @eventdata.value('(/EVENT_INSTANCE/LoginName)[1]',        'sysname'),
          @eventdata.value('(/EVENT_INSTANCE/SchemaName)[1]',       'sysname'),
          @eventdata.value('(/EVENT_INSTANCE/ObjectName)[1]',       'sysname'),
          @eventdata.value('(/EVENT_INSTANCE/TargetObjectName)[1]', 'sysname'),
          @eventdata );
GO

-- Test trigger
CREATE TABLE dbo.T1(col1 INT NOT NULL PRIMARY KEY);
ALTER TABLE dbo.T1 ADD col2 INT NULL;
ALTER TABLE dbo.T1 ALTER COLUMN col2 INT NOT NULL;
CREATE NONCLUSTERED INDEX idx1 ON dbo.T1(col2);
GO

SELECT * FROM dbo.AuditDDLEvents;
GO

-- Cleanup
USE master;
IF DB_ID(N'testdb') IS NOT NULL DROP DATABASE testdb;
GO

---------------------------------------------------------------------
-- Efficient Trigger Programming
---------------------------------------------------------------------

-- Identifying the Number of affected Rows

-- Creation Script for trg_T1_i Trigger on T1 (created earlier for AFTER UPDATE trigger example)
USE tempdb; 
GO
CREATE TRIGGER trg_T1_i ON T1 AFTER INSERT
AS

DECLARE @rc AS INT = (SELECT COUNT(*) FROM (SELECT TOP (2) * FROM inserted) AS D);

IF @rc = 0 RETURN;

DECLARE @keycol AS INT, @datacol AS VARCHAR(10);

IF @rc = 1 -- single row
BEGIN
  SELECT @keycol = keycol, @datacol = datacol FROM inserted;

  PRINT 'Handling keycol: ' + CAST(@keycol AS VARCHAR(10))
    + ', datacol: ' + @datacol;
END;
ELSE -- multi row
BEGIN
  
  DECLARE @C AS CURSOR;

  SET @C = CURSOR FAST_FORWARD FOR SELECT keycol, datacol FROM inserted;

  OPEN @C;
  
  FETCH NEXT FROM @C INTO @keycol, @datacol;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    PRINT 'Handling keycol: ' + CAST(@keycol AS VARCHAR(10))
      + ', datacol: ' + @datacol;

    FETCH NEXT FROM @C INTO @keycol, @datacol;
  END;

END;
GO

-- Test trg_T1_i trigger

-- 0 Rows
INSERT INTO dbo.T1(datacol) SELECT 'A' WHERE 1 = 0;
GO

-- 1 Row
INSERT INTO dbo.T1(datacol) VALUES('A');

-- Multi Rows
INSERT INTO dbo.T1(datacol) VALUES('B'), ('C'), ('D');

-- Cleanup
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
GO

-- Not firing Triggers for Specific Statements

-- Create table T1
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1(col1 INT);
GO

-- Create trg_T1_i trigger using temp table
CREATE TRIGGER trg_T1_i ON dbo.T1 AFTER INSERT
AS

IF OBJECT_ID(N'tempdb..#do_not_fire_trg_T1_i', N'U') IS NOT NULL RETURN;

PRINT 'trg_T1_i in action...';
GO

-- Test trg_T1_i

-- No Signal
INSERT INTO dbo.T1(col1) VALUES(1);
GO

-- Setting signal
CREATE TABLE #do_not_fire_trg_T1_i(col1 INT);
INSERT INTO T1(col1) VALUES(2);
-- Clearing signal
DROP TABLE #do_not_fire_trg_T1_i;
GO

---------------------------------------------------------------------
-- SQLCLR Programming
---------------------------------------------------------------------

-- .cs files listed below are found in the t_sql_querying_project SSDT project
-- Note: Assumes the presence of a database called t_sql_querying

USE t_sql_querying;
GO

---------------------------------------------------------------------
-- CLR Scalar Functions and Creating Your First Assembly
---------------------------------------------------------------------

/*
Deploy 01_SqlFunction1.cs
*/

--Exercise SqlFunction1
SELECT dbo.SqlFunction1() AS result;
GO


/*
Deploy 02_DecimalFunction1.cs
*/

--Exercise DecimalFunction1
SELECT dbo.DecimalFunction1() AS decimalValue;
GO

--Exercise DecimalFunction2
SELECT dbo.DecimalFunction2() AS decimalValue;
GO


/*
Deploy 03_ReturnStringLength.cs
*/


--Test the ReturnStringLength1 function
DECLARE @bigString NVARCHAR(MAX) = 
    REPLICATE(CONVERT(NVARCHAR(MAX), 'a'), 12345);

SELECT 
    LEN(@bigString) AS SQL_Length,
    dbo.ReturnStringLength1(@bigString) AS CLR_Length;
GO


--Test the ReturnStringLength2 function
DECLARE @bigString NVARCHAR(MAX) = 
    REPLICATE(CONVERT(NVARCHAR(MAX), 'a'), 12345);

SELECT 
    LEN(@bigString) AS SQL_Length,
    dbo.ReturnStringLength2(@bigString) AS CLR_Length;
GO

-- String types and case sensitivity

/*
Deploy 05_RegEx.cs
*/

--Test the RegExMatch and RegExReplace functions
SELECT dbo.RegexMatch(
  N'^([\w-]+\.)*?[\w-]+@[\w-]+\.([\w-]+\.)*?[\w]+$',
  N'abc@def.ghi') AS validemail;

SELECT dbo.RegExReplace(N'[^0-9]', N'(171) 456-7890', N'') AS cleanphone;

---------------------------------------------------------------------
-- Streaming Table-Valued Functions
---------------------------------------------------------------------

/*
Deploy 06_StringSplit.cs
*/

--Split a string
SELECT
    *
FROM dbo.StringSplit('abc,def,ghi');
GO

/*
Deploy 06a_FasterStringSplit.cs
*/

--Split a string
SELECT
    *
FROM dbo.SplitString_Multi('abc,def,ghi', ',');

/*
Deploy 07_GetTempValues.cs
*/

--Create a temp table and access it via a CLR function
CREATE TABLE #values 
(col1 INT, col2 FLOAT);

INSERT #values VALUES
(1, 1.123),
(2, 2.234),
(3, 3.345);

SELECT
	*
FROM dbo.GetTempValues();
GO


---------------------------------------------------------------------
-- SQLCLR Stored Procedures and Triggers
---------------------------------------------------------------------

/*
Deploy 08_SqlStoredProcedure1.cs
*/

--Running a CLR stored procedure
EXEC SqlStoredProcedure1;
GO

--A CLR stored procedure with OUTPUT parameters
DECLARE @out1 INT, @out2 INT;

EXEC dbo.AddToInput
    @input = 123,
    @inputPlusOne = @out1 OUTPUT,
    @inputPlusTwo = @out2 OUTPUT;

SELECT @out1 AS out1, @out2 AS out2;
GO


/*
Deploy 09_SendData.cs
*/

--Send a message back to the caller
EXEC dbo.SendMessage
	@message = 'hello!';
GO

--Send some rows back to the caller
EXEC dbo.SendRows 
    @numRows = 3;
GO



/*
Deploy 10_ThrowAnException.cs
*/

--Test a T-SQL exception
SELECT 1/0;
GO

--Throw the same exception in a CLR stored procedure
EXEC dbo.DivideByZero;
GO

--Try the SqlPipe for sending a command back to the calling context
EXEC dbo.ExecuteASelect;
GO

--Use the SqlPipe to send back an exception
EXEC dbo.ThrowAnException_v1;
GO

--Make the exception look a bit nicer
EXEC dbo.ThrowAnException_v2;
GO

--Controlling a divide-by-zero exception
EXEC dbo.DivideByZero_Nicer;
GO

--The trouble with TRY-CATCH
BEGIN TRY
    EXEC dbo.DivideByZero_Nicer;
END TRY
BEGIN CATCH
    SELECT 'you will never see this';
END CATCH;
GO


/*
Create the following table:

CREATE TABLE [dbo].[MyTable]
(
    [i] INT NOT NULL PRIMARY KEY
);

Deploy 12_SqlTrigger1.cs
*/

--Exercise the trigger
INSERT dbo.MyTable
VALUES (123), (456);
GO


---------------------------------------------------------------------
-- SQLCLR User-Defined Types
---------------------------------------------------------------------

/*
Deploy 13_SqlUserDefinedType1.cs
*/

--Instantiate SqlUserDefinedType1
DECLARE @t dbo.SqlUserDefinedType1 = '123';
GO

--What happens when you use the UDT in a SELECT?
DECLARE @t dbo.SqlUserDefinedType1 = '123';

SELECT @t AS typeValue;
GO

--Trying the ToString() method
DECLARE @t dbo.SqlUserDefinedType1 = '123';

SELECT @t.ToString() AS typeValue;
GO


/*
Deploy 14_USAddressLine.cs
*/

--Instantiate the USAddressLine type using a static method
DECLARE @t dbo.USAddressLine = 
	dbo.USAddressLine::StandardLine('123', 'Contoso', 'ST');

SET @t.PostDirectional = 'SW';
GO

--Instantiate the type, set a post-directional, and retrieve some of the data
DECLARE @t dbo.USAddressLine = 
	dbo.USAddressLine::StandardLine('123', 'Contoso', 'ST');
SET @t.PostDirectional = 'SW';

SELECT 
	@t.ToString() AS AddressLine,
	@t.BuildingNumber AS BuildingNumber,
	@t.StreetName AS StreetName,
	@t.StreetType AS StreetType;
GO


---------------------------------------------------------------------
-- SQLCLR User-Defined Aggregates
---------------------------------------------------------------------

/*
Deploy 15_Concatenate.cs
*/

--Concatenate some strings
SELECT dbo.Concatenate(theString) AS CSV
FROM
(
    VALUES
        ('abc'),
        ('def'),
        ('ghi')
) AS x (theString);
GO

---------------------------------------------------------------------
-- Transactions and Concurrency
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Transactions, Described
---------------------------------------------------------------------

-- Creating and Populating Tables T1 and T2
SET NOCOUNT ON;
IF DB_ID(N'testdb') IS NULL CREATE DATABASE testdb;
GO
USE testdb;
GO
IF OBJECT_ID(N'dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
IF OBJECT_ID(N'dbo.T2', 'U') IS NOT NULL DROP TABLE dbo.T2;
GO

CREATE TABLE dbo.T1
(
  keycol INT         NOT NULL PRIMARY KEY,
  col1   INT         NOT NULL,
  col2   VARCHAR(50) NOT NULL
);

INSERT INTO dbo.T1(keycol, col1, col2) VALUES
  (1, 101, 'A'),
  (2, 102, 'B'),
  (3, 103, 'C');

CREATE TABLE dbo.T2
(
  keycol INT         NOT NULL PRIMARY KEY,
  col1   INT         NOT NULL,
  col2   VARCHAR(50) NOT NULL
);

INSERT INTO dbo.T2(keycol, col1, col2) VALUES
  (1, 201, 'X'),
  (2, 202, 'Y'),
  (3, 203, 'Z');
GO

-- Transaction Example

-- First part of transaction
BEGIN TRAN;
  INSERT INTO dbo.T1(keycol, col1, col2) VALUES(4, 101, 'C');

-- Second part of transaction
  INSERT INTO dbo.T2(keycol, col1, col2) VALUES(4, 201, 'X');
COMMIT TRAN;
GO

-- No nested transactions; use savepoint if need to rollback only inner work

-- BEGIN TRAN;

DECLARE @tranexisted AS INT = 0, @allisgood AS INT = 0;

IF @@trancount = 0
  BEGIN TRAN;
ELSE
BEGIN
  SET @tranexisted = 1;
  SAVE TRAN S1;
END;

-- ... some work ...

-- Need to rollback only inner work
IF @allisgood = 1
  COMMIT TRAN;
ELSE
  IF @tranexisted = 1
  BEGIN
    PRINT 'Rolling back to savepoint.';
    ROLLBACK TRAN S1;
  END;
  ELSE
  BEGIN
    PRINT 'Rolling back transaction.';
    ROLLBACK TRAN;
  END;

-- COMMIT TRAN;

---------------------------------------------------------------------
-- Locks and Blocking
---------------------------------------------------------------------

-- Set initial value
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;

-- Connection 1
SET NOCOUNT ON;
USE testdb;
GO
BEGIN TRAN;
  UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;

-- Connection 2
SET NOCOUNT ON;
USE testdb;
GO
SELECT keycol, col1, col2 FROM dbo.T1;

-- Connection 3

-- Lock info
SET NOCOUNT ON;
USE testdb;

SELECT
  request_session_id            AS sid,
  resource_type                 AS restype,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status
FROM sys.dm_tran_locks;

-- Connection info
SELECT * FROM sys.dm_exec_connections
WHERE session_id IN(53, 54);

-- SQL text
SELECT C.session_id, ST.text 
FROM sys.dm_exec_connections AS C
  CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST 
WHERE session_id IN(53, 54);

-- Session info
SELECT * FROM sys.dm_exec_sessions
WHERE session_id IN(53, 54);

-- Blocking
SELECT * FROM sys.dm_exec_requests
WHERE blocking_session_id > 0;

-- Waiting tasks
SELECT * FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id > 0;
GO

-- sp_WhoIsActive by Adam Machanic -- http://tinyurl.com/WhoIsActive

-- Connection 3
KILL 53;
GO

-- Connection 2
-- Stop, then set the LOCK_TIMEOUT, then retry
SET LOCK_TIMEOUT 5000;
SELECT keycol, col1, col2 FROM dbo.T1;
GO

-- Remove timeout
SET LOCK_TIMEOUT -1;
GO

---------------------------------------------------------------------
-- Lock Escalation
---------------------------------------------------------------------

-- Create and populate table TestEscalation
USE testdb;
IF OBJECT_ID(N'dbo.TestEscalation', N'U') IS NOT NULL DROP TABLE dbo.TestEscalation;
GO

SELECT n AS col1, CAST('a' AS CHAR(200)) AS filler
INTO dbo.TestEscalation
FROM TSQLV3.dbo.GetNums(1, 100000) AS Nums;

CREATE UNIQUE CLUSTERED INDEX idx1 ON dbo.TestEscalation(col1);
GO

-- Run transaction and observe only 1 lock reported indicating escalation
BEGIN TRAN;

  DELETE FROM dbo.TestEscalation WHERE col1 <= 20000;

  SELECT COUNT(*)
  FROM sys.dm_tran_locks
  WHERE request_session_id = @@SPID
    AND resource_type <> 'DATABASE';

ROLLBACK TRAN;
GO

-- Disable lock escalation and run transaction again; over 20,000 locks reported
ALTER TABLE dbo.TestEscalation SET (LOCK_ESCALATION = DISABLE);

BEGIN TRAN;

  DELETE FROM dbo.TestEscalation WHERE col1 <= 20000;

  SELECT COUNT(*)
  FROM sys.dm_tran_locks
  WHERE request_session_id = @@SPID;

ROLLBACK TRAN;
GO

-- Cleanup
IF OBJECT_ID(N'dbo.TestEscalation', N'U') IS NOT NULL DROP TABLE dbo.TestEscalation;
GO

---------------------------------------------------------------------
-- Delayed Durability
---------------------------------------------------------------------

-- Create database testdd with DELAYED_DURABILITY = Allowed and a table called T1
SET NOCOUNT ON;
USE master;
GO
IF DB_ID(N'testdd') IS NOT NULL DROP DATABASE testdd;
GO
CREATE DATABASE testdd;
ALTER DATABASE testdd SET DELAYED_DURABILITY = Allowed;
GO
USE testdd;
CREATE TABLE dbo.T1(col1 INT NOT NULL);
GO

-- Make sure table is empty
TRUNCATE TABLE dbo.T1;

-- Many small transactions with full durability, 23 seconds
DECLARE @i AS INT = 1;
WHILE @i <= 100000
BEGIN
  INSERT INTO dbo.T1(col1) VALUES(@i);
  SET @i += 1;
END;
GO

-- Make sure table is empty
TRUNCATE TABLE dbo.T1;

-- Many small transactions with delayed durability, 2 seconds
DECLARE @i AS INT = 1;
WHILE @i <= 100000
BEGIN
  BEGIN TRAN;
    INSERT INTO dbo.T1(col1) VALUES(@i);
  COMMIT TRAN WITH (DELAYED_DURABILITY = ON);
  SET @i += 1;
END;
GO

-- Make sure table is empty
TRUNCATE TABLE dbo.T1;

-- Large transactions with full durability, 1 second
BEGIN TRAN;
  DECLARE @i AS INT = 1;
  WHILE @i <= 100000
  BEGIN
    INSERT INTO dbo.T1(col1) VALUES(@i);
    SET @i += 1;
  END;
COMMIT TRAN;
GO

-- Cleanup
TRUNCATE TABLE dbo.T1;

-- Large transaction with delayed durability, 1 second
BEGIN TRAN;
  DECLARE @i AS INT = 1;
  WHILE @i <= 100000
  BEGIN
    INSERT INTO dbo.T1(col1) VALUES(@i);
    SET @i += 1;
  END;
COMMIT TRAN WITH (DELAYED_DURABILITY = ON);

---------------------------------------------------------------------
-- Isolation Levels
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Read Uncommitted
---------------------------------------------------------------------

-- First initialize the data
USE testdb;
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;

-- Connection 1
BEGIN TRAN;
  UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 1
ROLLBACK TRAN
GO

-- Close both connections

---------------------------------------------------------------------
-- Read Committed
---------------------------------------------------------------------

-- Connection 1
BEGIN TRAN;
  UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 1
COMMIT TRAN;
GO

-- Cleanup
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;
GO

-- Close both connections

---------------------------------------------------------------------
-- Repeatable Read
---------------------------------------------------------------------

-- Connection 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
GO

-- Connection 1
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
COMMIT TRAN;
GO

-- Cleanup
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;
GO

-- Close both connections

---------------------------------------------------------------------
-- Serializable
---------------------------------------------------------------------

-- Create an index
CREATE INDEX idx_col1 ON dbo.T1(col1);
GO

-- Connection 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN;
  SELECT *
  FROM dbo.T1 WITH (INDEX(idx_col1))
  WHERE col1 = 102;
GO

-- Connection 2
INSERT INTO dbo.T1(keycol, col1, col2) VALUES(5, 102, 'D');
GO

-- Connection 1
  SELECT *
  FROM dbo.T1 WITH (INDEX(idx_col1))
  WHERE col1 = 102;
COMMIT TRAN;
GO

-- Cleanup
DELETE FROM dbo.T1 WHERE keycol = 5;
DROP INDEX dbo.T1.idx_col1;

-- Close both connections

---------------------------------------------------------------------
-- Snapshot and Read Committed Snapshot
---------------------------------------------------------------------

-- Allow SNAPSHOT isolation in the database
ALTER DATABASE testdb SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

-- Connection 1
BEGIN TRAN;
  UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Check row versions
SELECT * FROM sys.dm_tran_version_store;
GO

-- Connection 2
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRAN;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 1
COMMIT TRAN;
SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
COMMIT TRAN;
SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Cleanup
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;

---------------------------------------------------------------------
-- Conflict Detection
---------------------------------------------------------------------

-- Connection 1
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRAN;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
GO

-- Connection 1
  UPDATE dbo.T1 SET col2 = 'Version 3' WHERE keycol = 2;
GO

-- Cleanup
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;
GO

-- Close both connections

-- Turn on READ_COMMITTED_SNAPSHOT
ALTER DATABASE testdb SET READ_COMMITTED_SNAPSHOT ON;
GO

-- Connection 1
BEGIN TRAN;
  UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 2
BEGIN TRAN;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- Connection 1
COMMIT TRAN;
GO

-- Connection 2
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
COMMIT TRAN;
GO

-- Cleanup
UPDATE dbo.T1 SET col2 = 'Version 1' WHERE keycol = 2;

-- Close both connections

-- Restore the testdb database to its default settings:
ALTER DATABASE testdb SET ALLOW_SNAPSHOT_ISOLATION OFF;
ALTER DATABASE testdb SET READ_COMMITTED_SNAPSHOT OFF;
GO

---------------------------------------------------------------------
-- Deadlocks
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Simple Deadlock Example
---------------------------------------------------------------------

-- Connection 1
BEGIN TRAN;
  UPDATE dbo.T1 SET col1 = col1 + 1 WHERE keycol = 2;
GO

-- Connection 2
BEGIN TRAN;
  UPDATE dbo.T2 SET col1 = col1 + 1 WHERE keycol = 2;
GO

-- Connection 1
  SELECT col1 FROM dbo.T2 WHERE keycol = 2;
COMMIT TRAN;
GO

-- Connection 2
  SELECT col1 FROM dbo.T1 WHERE keycol = 2;
COMMIT TRAN;
GO

---------------------------------------------------------------------
-- Measures to Reduce Deadlock Occurrences
---------------------------------------------------------------------

-- Deadlock for missing indexes

-- Connection 1
BEGIN TRAN;
  UPDATE dbo.T1 SET col2 = col2 + 'A' WHERE col1 = 101;
GO

-- Connection 2
BEGIN TRAN;
  UPDATE dbo.T2 SET col2 = col2 + 'B' WHERE col1 = 203;
GO

-- Connection 1
  SELECT col2 FROM dbo.T2 WHERE col1 = 201;
COMMIT TRAN;
GO

-- Connection 2
  SELECT col2 FROM dbo.T1 WHERE col1 = 103;
COMMIT TRAN;
GO

-- Create an index on col1 and rerun the activities ( might need to use index hint WITH(INDEX(idx_col1)) )
CREATE INDEX idx_col1 ON dbo.T1(col1);
CREATE INDEX idx_col1 ON dbo.T2(col1);
GO

---------------------------------------------------------------------
-- Deadlock with a Single Table
---------------------------------------------------------------------

-- First make sure row with keycol = 2 has col = 102
UPDATE dbo.T1 SET col1 = 102, col2 = 'B' WHERE keycol = 2;
GO

-- Connection 1
SET NOCOUNT ON;
WHILE 1 = 1
  UPDATE dbo.T1 SET col1 = 203 - col1 WHERE keycol = 2;
GO

-- Connection 2
SET NOCOUNT ON;

DECLARE @i AS VARCHAR(10);
WHILE 1 = 1
  SET @i = (SELECT col2 FROM dbo.T1 WITH (index = idx_col1)
            WHERE col1 = 102);
GO

-- Cleanup
USE testdb; 

IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1; 
IF OBJECT_ID('dbo.T2', 'U') IS NOT NULL DROP TABLE dbo.T2;
GO

---------------------------------------------------------------------
-- Error Handling
---------------------------------------------------------------------

-- Code to create Employees table
USE tempdb;

IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;

CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL,
  empname VARCHAR(25) NOT NULL,
  mgrid   INT         NULL,
  /* other columns */
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT CHK_Employees_empid CHECK(empid > 0),
  CONSTRAINT FK_Employees_Employees
    FOREIGN KEY(mgrid) REFERENCES dbo.Employees(empid)
)
GO

---------------------------------------------------------------------
-- The TRY-CACTH construct
---------------------------------------------------------------------

-- Basic example
SET NOCOUNT ON;

BEGIN TRY
  INSERT INTO dbo.Employees(empid, empname, mgrid)
     VALUES(1, 'Emp1', NULL);
  PRINT 'After INSERT';
END TRY
BEGIN CATCH
  PRINT 'INSERT failed';
  /* handle error */
END CATCH;
GO

-- Detailed example
BEGIN TRY

  INSERT INTO dbo.Employees(empid, empname, mgrid) VALUES(2, 'Emp2', 1);
  -- Also try with empid = 0, 'A', NULL, 10/0
  PRINT 'After INSERT';

END TRY
BEGIN CATCH

  IF ERROR_NUMBER() = 2627
  BEGIN
    PRINT 'Handling PK violation...';
  END;
  ELSE IF ERROR_NUMBER() = 547
  BEGIN
    PRINT 'Handling CHECK/FK constraint violation...';
  END;
  ELSE IF ERROR_NUMBER() = 515
  BEGIN
    PRINT 'Handling NULL violation...';
  END;
  ELSE IF ERROR_NUMBER() = 245
  BEGIN
    PRINT 'Handling conversion error...';
  END;
  ELSE
  BEGIN
    PRINT 'Re-throwing error...';
    THROW;
  END;

  PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
  PRINT 'Error Message : ' + ERROR_MESSAGE();
  PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
  PRINT 'Error State   : ' + CAST(ERROR_STATE() AS VARCHAR(10));
  PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(10));
  PRINT 'Error Proc    : ' + ISNULL(ERROR_PROCEDURE(), 'Not within proc');

END CATCH;
GO

---------------------------------------------------------------------
-- Errors in Transactions
---------------------------------------------------------------------

-- SET XACT_ABORT ON

BEGIN TRY

  BEGIN TRAN;
    INSERT INTO dbo.Employees(empid, empname, mgrid) VALUES(3, 'Emp3', 1);
    /* other activity */
  COMMIT TRAN;

  PRINT 'Code completed successfully.';

END TRY
BEGIN CATCH

  PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' found.';

  IF (XACT_STATE()) = -1
  BEGIN
	  PRINT 'Transaction is open but uncommittable.';
	  /* ...investigate data... */
	  ROLLBACK TRAN; -- can only ROLLBACK
	  /* ...handle the error... */
  END;
  ELSE IF (XACT_STATE()) = 1
  BEGIN
	  PRINT 'Transaction is open and committable.';
	  /* ...handle error... */
	  COMMIT TRAN; -- or ROLLBACK
  END;
  ELSE
  BEGIN
	  PRINT 'No open transaction.';
	  /* ...handle error... */
  END;

END CATCH;

-- SET XACT_ABORT OFF

---------------------------------------------------------------------
-- Retry Logic
---------------------------------------------------------------------

/*
CREATE PROC dbo.MyProcWrapper(<parameters>)
AS
BEGIN
  DECLARE @retry INT = 10;

  WHILE (@retry > 0)
  BEGIN
    BEGIN TRY
      EXEC dbo.MyProc <parameters>;
      
      SET @retry = 0; -- finished successfully
    END TRY
    BEGIN CATCH
      SET @retry -= 1;
  
      IF (@retry > 0 AND ERROR_NUMBER() IN (1205, 3960)) -- errors for retry
      BEGIN
        IF XACT_STATE() <> 0 
          ROLLBACK TRAN;
      END;
      ELSE
      BEGIN
        THROW; -- max # of retries reached or other error
      END;
    END CATCH;
  END;
END;
GO
*/
