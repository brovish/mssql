---------------------------------------------------------------------
-- T-SQL Querying (Microsoft Press, 2015)
-- Chapter 02 - Query Tuning
-- © Itzik Ben-Gan, SolidQ 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Internals
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Pages and Extents
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Table Organization
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Tools to Measure Query Performance
---------------------------------------------------------------------

-- Connect to the database PerformanceV3
SET NOCOUNT ON;
USE PerformanceV3;

-- Sample query
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 10000;

-- Clear cache for cold cache test
CHECKPOINT;
DBCC DROPCLEANBUFFERS;

-- Statistics IO and time information
SET STATISTICS IO, TIME ON;

-- Extended Events session with sql_statement_completed event
CREATE EVENT SESSION query_performance ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(
    WHERE (sqlserver.session_id=(53))); -- replace with your session ID;

ALTER EVENT SESSION query_performance ON SERVER STATE = START;

---------------------------------------------------------------------
-- Access Methods
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Table Scan/Unordered Clustered Index Scan
---------------------------------------------------------------------

-- Copy data from dbo.Orders to dbo.Orders2
IF OBJECT_ID(N'dbo.Orders2', N'U') IS NOT NULL DROP TABLE dbo.Orders2;
SELECT * INTO dbo.Orders2 FROM dbo.Orders;
ALTER TABLE dbo.Orders2 ADD CONSTRAINT PK_Orders2 PRIMARY KEY NONCLUSTERED (orderid);
GO

-- Heap scan
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders2;

-- B-tree scan
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders;

---------------------------------------------------------------------
-- Unordered Covering Nonclustered Index Scan
---------------------------------------------------------------------

SELECT orderid
FROM dbo.Orders;

-- Add orderdate to query; PK_Orders index still covering
SELECT orderid, orderdate
FROM dbo.Orders;

---------------------------------------------------------------------
-- Ordered Clustered Index Scan
---------------------------------------------------------------------

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
ORDER BY orderdate;

---------------------------------------------------------------------
-- Ordered Covering Nonclustered Index Scan
---------------------------------------------------------------------

SELECT orderid, orderdate
FROM dbo.Orders
ORDER BY orderid;

-- With segmentation
SELECT orderid, custid, empid, orderdate
FROM dbo.Orders AS O1
WHERE orderid = 
  (SELECT MAX(orderid)
   FROM dbo.Orders AS O2
   WHERE O2.orderdate = O1.orderdate);

---------------------------------------------------------------------
-- The Storage Engine’s Treatment of Scans
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Allocation Order Scans
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Allocation Order Scan: Getting Multiple Occurrences of Rows
---------------------------------------------------------------------

SET NOCOUNT ON;
USE tempdb;
GO

-- Create table T1
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  clcol UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
  filler CHAR(2000) NOT NULL DEFAULT('a')
);
GO
CREATE UNIQUE CLUSTERED INDEX idx_clcol ON dbo.T1(clcol);
GO

-- Insert rows (run for a few seconds then stop)
SET NOCOUNT ON;
USE tempdb;

TRUNCATE TABLE dbo.T1;

WHILE 1 = 1
  INSERT INTO dbo.T1 DEFAULT VALUES;
GO

-- Observe level of fragmentation
SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
( 
  DB_ID(N'tempdb'),
  OBJECT_ID(N'dbo.T1'),
  1,
  NULL,
  NULL
);

-- Get index linked list info
DBCC IND(N'tempdb', N'dbo.T1', 0);
GO

CREATE TABLE #DBCCIND
(
  PageFID INT,
  PagePID INT,
  IAMFID INT,
  IAMPID INT,
  ObjectID INT,
  IndexID INT,
  PartitionNumber INT,
  PartitionID BIGINT,
  iam_chain_type VARCHAR(100),
  PageType INT,
  IndexLevel INT,
  NextPageFID INT,
  NextPagePID INT,
  PrevPageFID INT,
  PrevPagePID INT
);

INSERT INTO #DBCCIND
  EXEC (N'DBCC IND(N''tempdb'', N''dbo.T1'', 0)');

CREATE CLUSTERED INDEX idx_cl_prevpage ON #DBCCIND(PrevPageFID, PrevPagePID);

WITH LinkedList
AS
(
  SELECT 1 AS RowNum, PageFID, PagePID
  FROM #DBCCIND
  WHERE IndexID = 1
    AND IndexLevel = 0
    AND PrevPageFID = 0
    AND PrevPagePID = 0

  UNION ALL

  SELECT PrevLevel.RowNum + 1,
    CurLevel.PageFID, CurLevel.PagePID
  FROM LinkedList AS PrevLevel
    JOIN #DBCCIND AS CurLevel
      ON CurLevel.PrevPageFID = PrevLevel.PageFID
      AND CurLevel.PrevPagePID = PrevLevel.PagePID
)
SELECT
  CAST(PageFID AS VARCHAR(MAX)) + ':'
  + CAST(PagePID AS VARCHAR(MAX)) + ' ' AS [text()]
FROM LinkedList
ORDER BY RowNum
FOR XML PATH('')
OPTION (MAXRECURSION 0);

DROP TABLE #DBCCIND;
GO

-- Query T1

-- Index order scan
SELECT SUBSTRING(CAST(clcol AS BINARY(16)), 11, 6) AS segment1, *
FROM dbo.T1;

-- Allocation order scan
SELECT SUBSTRING(CAST(clcol AS BINARY(16)), 11, 6) AS segment1, *
FROM dbo.T1 WITH (NOLOCK);

-- Allocation order scan
SELECT SUBSTRING(CAST(clcol AS BINARY(16)), 11, 6) AS segment1, *
FROM dbo.T1 WITH (TABLOCK);

-- Connection 1: insert rows (run for a few seconds then stop)
SET NOCOUNT ON;
USE tempdb;

TRUNCATE TABLE dbo.T1;

WHILE 1 = 1
  INSERT INTO dbo.T1 DEFAULT VALUES;
GO

-- Connection 2: read
SET NOCOUNT ON;
USE tempdb;

WHILE 1 = 1
BEGIN
  SELECT * INTO #T1 FROM dbo.T1 WITH(NOLOCK);

  IF EXISTS(
    SELECT clcol
    FROM #T1 
    GROUP BY clcol 
    HAVING COUNT(*) > 1) BREAK;

  DROP TABLE #T1;
END

SELECT clcol, COUNT(*) AS cnt
FROM #T1 
GROUP BY clcol
HAVING COUNT(*) > 1;

DROP TABLE #T1;
GO

-- Stop execution in connection 1

---------------------------------------------------------------------
-- Allocation Order Scan: Skipping Rows
---------------------------------------------------------------------

-- Create table T1
SET NOCOUNT ON;
USE tempdb;

IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  clcol UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
  seqval INT NOT NULL,
  filler CHAR(2000) NOT NULL DEFAULT('a')
);
CREATE UNIQUE CLUSTERED INDEX idx_clcol ON dbo.T1(clcol);

-- Create table MySequence 
IF OBJECT_ID(N'dbo.MySequence', N'U') IS NOT NULL DROP TABLE dbo.MySequence;

CREATE TABLE dbo.MySequence(val INT NOT NULL);
INSERT INTO dbo.MySequence(val) VALUES(0);
GO

-- Connection 1: insert rows
SET NOCOUNT ON;
USE tempdb;

UPDATE dbo.MySequence SET val = 0;
TRUNCATE TABLE dbo.T1;

DECLARE @nextval AS INT;

WHILE 1 = 1
BEGIN
  UPDATE dbo.MySequence SET @nextval = val += 1;
  INSERT INTO dbo.T1(seqval) VALUES(@nextval);
END

-- Connection 2: read
SET NOCOUNT ON;
USE tempdb;

DECLARE @max AS INT;
WHILE 1 = 1
BEGIN
  SET @max = (SELECT MAX(seqval) FROM dbo.T1);
  SELECT * INTO #T1 FROM dbo.T1 WITH(NOLOCK);
  CREATE NONCLUSTERED INDEX idx_seqval ON #T1(seqval);

  IF EXISTS(
    SELECT *
    FROM (SELECT seqval AS cur, 
            (SELECT MIN(seqval)
             FROM #T1 AS N
             WHERE N.seqval > C.seqval) AS nxt
          FROM #T1 AS C
          WHERE seqval <= @max) AS D
    WHERE nxt - cur > 1) BREAK;

  DROP TABLE #T1;
END

SELECT *
FROM (SELECT seqval AS cur, 
        (SELECT MIN(seqval)
         FROM #T1 AS N
         WHERE N.seqval > C.seqval) AS nxt
      FROM #T1 AS C      
      WHERE seqval <= @max) AS D
WHERE nxt - cur > 1;

DROP TABLE #T1;
GO

---------------------------------------------------------------------
-- Index Order Scans
---------------------------------------------------------------------

-- Create table Employees
SET NOCOUNT ON;
USE tempdb;

IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;

CREATE TABLE dbo.Employees
(
  empid VARCHAR(10) NOT NULL,
  salary MONEY NOT NULL,
  filler CHAR(2500) NOT NULL DEFAULT('a')
);

CREATE CLUSTERED INDEX idx_cl_salary ON dbo.Employees(salary);
ALTER TABLE dbo.Employees
  ADD CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED(empid);

INSERT INTO dbo.Employees(empid, salary) VALUES
  ('D', 1000.00),('A', 2000.00),('C', 3000.00),('B', 4000.00);
GO

-- Connection 1: update a row
SET NOCOUNT ON;
USE tempdb;

WHILE 1=1
  UPDATE dbo.Employees
    SET salary = 6000.00 - salary
  WHERE empid = 'D';

-- Connection 2: read
SET NOCOUNT ON;
USE tempdb;

WHILE 1 = 1
BEGIN
  SELECT * INTO #Employees FROM dbo.Employees;

  IF @@rowcount <> 4 BREAK; -- use < 4 for skipping, > 4 for multi occur

  DROP TABLE #Employees;
END

SELECT * FROM #Employees;

DROP TABLE #Employees;
GO

---------------------------------------------------------------------
-- Nonclustered Index Seek + Range Scan + Lookups
---------------------------------------------------------------------

-- Heap
USE PerformanceV3;

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders2
WHERE orderid <= 25;

-- B-tree
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 25;

-- Histogram
DBCC SHOW_STATISTICS (N'dbo.Orders', N'PK_Orders') WITH HISTOGRAM;

-- WithUnorderedPrefetch: True
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 26;

-- WithOrderedPrefetch: True
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 26
ORDER BY orderid;

-- No prefetch property
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 26
OPTION(QUERYTRACEON 8744);

-- Tipping point
-- Following query gets a parallel scan
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 10000;

-- Following query gets a serial scan
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 300000;

-- Try above query after changing number of CPUs to 16
DBCC OPTIMIZER_WHATIF(CPUs, 16);

-- Parallel plan
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 300000
OPTION(RECOMPILE);

-- Revert to default
DBCC OPTIMIZER_WHATIF(CPUs, 0);

-- Plan for following query is parallel
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 300000
OPTION(QUERYTRACEON 8649);

---------------------------------------------------------------------
-- Unordered Nonclustered Index Scan + Lookups
---------------------------------------------------------------------

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000001';

---------------------------------------------------------------------
-- Clustered Index Seek + Range Scan
---------------------------------------------------------------------

SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE orderdate = '20140212';

---------------------------------------------------------------------
-- Covering Nonclustered Index Seek + Range Scan
---------------------------------------------------------------------

-- Query
SELECT orderid, shipperid, orderdate, custid
FROM dbo.Orders
WHERE shipperid = 'C'
  AND orderdate >= '20140101'
  AND orderdate < '20150101';

-- Create supporting index
CREATE INDEX idx_nc_sid_od_i_cid_orderid
  ON dbo.Orders(shipperid, orderdate) INCLUDE(custid, orderid);

-- Run query

-- Cleanup
DROP INDEX idx_nc_sid_od_i_cid_orderid ON dbo.Orders;
GO

---------------------------------------------------------------------
-- Cardinality Estimates
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Legacy versus 2014 Cardinality Estimators
---------------------------------------------------------------------

USE PerformanceV3;
ALTER DATABASE PerformanceV3 SET COMPATIBILITY_LEVEL = 120;

---------------------------------------------------------------------
-- Implications of Under and Over Estimations
---------------------------------------------------------------------

-- Underestimation
DECLARE @i AS INT = 500000;

SELECT empid, COUNT(*) AS numorders
FROM dbo.Orders
WHERE orderid > @i
GROUP BY empid
OPTION(OPTIMIZE FOR (@i = 999900));

-- Overestimation
DECLARE @i AS INT = 999900;

SELECT empid, COUNT(*) AS numorders
FROM dbo.Orders
WHERE orderid > @i
GROUP BY empid;

---------------------------------------------------------------------
-- Statistics
---------------------------------------------------------------------

-- Create index
CREATE INDEX idx_nc_cid_eid ON dbo.Orders(custid, empid);

-- Show statistics
DBCC SHOW_STATISTICS(N'dbo.Orders', N'idx_nc_cid_eid');

-- Use of histogram on single column; equal RANGE_HI_KEY
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000001';

-- Based on average in range
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000002';

-- Use of density vector
DECLARE @cid AS VARCHAR(11) = 'C0000000001';

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = @cid;

---------------------------------------------------------------------
-- Estimates for Multiple Predicates
---------------------------------------------------------------------

-- Product versus exponential backoff

-- Filter based on custid
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid <= 'C0000001000';

-- Filter based on empid
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE empid <= 100;

-- Conjunction

-- Pre-2014
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid <= 'C0000001000'
  AND empid <= 100
OPTION(QUERYTRACEON 9481);

-- 2014
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid <= 'C0000001000'
  AND empid <= 100;

-- Disjunction

-- Pre-2014
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid <= 'C0000001000'
  OR empid <= 100
OPTION(QUERYTRACEON 9481);

-- 2014
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid <= 'C0000001000'
  OR empid <= 100;

-- Cleanup
DROP INDEX idx_nc_cid_eid ON dbo.Orders;

---------------------------------------------------------------------
-- Ascending key problem
---------------------------------------------------------------------

IF OBJECT_ID(N'dbo.Orders2', N'U') IS NOT NULL DROP TABLE dbo.Orders2;
SELECT * INTO dbo.Orders2 FROM dbo.Orders WHERE orderid <= 900000;
ALTER TABLE dbo.Orders2 ADD CONSTRAINT PK_Orders2 PRIMARY KEY NONCLUSTERED(orderid);
GO

DBCC SHOW_STATISTICS('dbo.Orders2', 'PK_Orders2');

-- Add 100,000 more rows
INSERT INTO dbo.Orders2
  SELECT *
  FROM dbo.Orders
  WHERE orderid > 900000 AND orderid <= 1000000;

-- Show statistics again
DBCC SHOW_STATISTICS('dbo.Orders2', 'PK_Orders2');

-- Query showing ascending key problem with legacy cardinality estimator
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders2
WHERE orderid > 900000
ORDER BY orderdate
OPTION(QUERYTRACEON 9481);

-- Query showing ascending key problem solved with legacy cardinality estimator
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders2
WHERE orderid > 900000
ORDER BY orderdate;

---------------------------------------------------------------------
-- Unknowns
---------------------------------------------------------------------

-- Check indexing on Orders
EXEC sp_helpindex N'dbo.Orders';

-- Turn off auto collection of statistics
ALTER DATABASE PerformanceV3 SET AUTO_CREATE_STATISTICS OFF;

-- Identify automatically created statistics
SELECT S.name AS stats_name,
   QUOTENAME(OBJECT_SCHEMA_NAME(S.object_id)) + N'.' + QUOTENAME(OBJECT_NAME(S.object_id)) AS object,
   C.name AS column_name
FROM sys.stats AS S
  INNER JOIN sys.stats_columns AS SC
    ON S.object_id = SC.object_id
   AND S.stats_id = SC.stats_id
  INNER JOIN sys.columns AS C
    ON SC.object_id = C.object_id
   AND SC.column_id = C.column_id
WHERE S.object_id = OBJECT_ID(N'dbo.Orders')
  AND auto_created = 1;

-- Replace with the statistics names that you get
DROP STATISTICS dbo.Orders._WA_Sys_00000002_38EE7070;
DROP STATISTICS dbo.Orders._WA_Sys_00000003_38EE7070;
GO

-- >, >=, <, <= : 30%
-- Query 1
DECLARE @i AS INT = 999900;

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid > @i;

-- Query 2
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid <= 'C0000000010';
GO

-- BETWEEN/LIKE: 9% (Exception: in 2014 BETWEEN with variables/parameters with sniffing disabled the estimate is 16.4317%)
-- Query 1
DECLARE @i AS INT = 999901, @j AS INT = 1000000;

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid BETWEEN @i AND @j;

-- Query 2
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid BETWEEN @i AND @j
OPTION(QUERYTRACEON 9481);

-- Query 3
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid BETWEEN 'C0000000001' AND 'C0000000010';

-- Query 4
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid LIKE '%9999';
GO

-- = with a unique column : 1 row
-- = with a nonunique column pre-2014 : C^3/4 (C = table cardinality)
-- = with a nonunique column 2014 : C^1/2
-- Query 1
DECLARE @i AS INT = 1000000;

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid = @i;

-- Query 2
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000001';

-- Query 3
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000001'
OPTION(QUERYTRACEON 9481);

-- Turn automatic creation of statistics back on
ALTER DATABASE PerformanceV3 SET AUTO_CREATE_STATISTICS ON;

-- Query using LIKE with string statistics available
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid LIKE '%9999';

---------------------------------------------------------------------
-- Indexing Features
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Descending Indexes
---------------------------------------------------------------------

-- No parallel backward scans

-- Query 1, parallel
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 100000
ORDER BY orderdate;

-- Query 2, serial
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 100000
ORDER BY orderdate DESC;

-- Force parallelism
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 100000
ORDER BY orderdate DESC
OPTION(QUERYTRACEON 8649);

-- Window functions with a window partition clause
-- Query 1, no sort
SELECT shipperid, orderdate, custid,
  ROW_NUMBER() OVER(PARTITION BY shipperid ORDER BY orderdate) AS rownum
FROM dbo.Orders;

-- Query 2, sort
SELECT shipperid, orderdate, custid,
  ROW_NUMBER() OVER(PARTITION BY shipperid ORDER BY orderdate DESC) AS rownum
FROM dbo.Orders;

-- Query 3, no sort
SELECT shipperid, orderdate, custid,
  ROW_NUMBER() OVER(PARTITION BY shipperid ORDER BY orderdate DESC) AS rownum
FROM dbo.Orders
ORDER BY shipperid DESC;

---------------------------------------------------------------------
-- Included Non-key Columns
---------------------------------------------------------------------

-- Earlier query
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000001';

CREATE INDEX idx_nc_cid_i_oid_eid_sid_od_flr ON dbo.Orders(custid)
  INCLUDE(orderid, empid, shipperid, orderdate, filler);

-- Query again
SELECT orderid, custid, empid, orderdate, filler
FROM dbo.Orders
WHERE custid = 'C0000000001';

DROP INDEX dbo.Orders.idx_nc_cid_i_oid_eid_sid_od_flr;

---------------------------------------------------------------------
-- Filtered Indexes and Statistics
---------------------------------------------------------------------

-- Create filtered index
USE TSQLV3;

CREATE NONCLUSTERED INDEX idx_USA_orderdate
  ON Sales.Orders(orderdate)
  INCLUDE(orderid, custid, requireddate)
  WHERE shipcountry = N'USA';

-- Query
SELECT orderid, custid, orderdate, requireddate
FROM Sales.Orders
WHERE shipcountry = N'USA'
  AND orderdate >= '20140101';

-- Add shipcountry to index
CREATE NONCLUSTERED INDEX idx_USA_orderdate
  ON Sales.Orders(orderdate)
  INCLUDE(orderid, custid, requireddate, shipcountry)
  WHERE shipcountry = N'USA'
WITH ( DROP_EXISTING = ON );

-- Query
SELECT orderid, custid, orderdate, requireddate
FROM Sales.Orders
WHERE shipcountry = N'USA'
  AND orderdate >= '20140101';

-- Unique with Multiple NULLs
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1(col1 INT NULL, col2 VARCHAR(10) NOT NULL);
GO
CREATE UNIQUE NONCLUSTERED INDEX idx_col1_notnull ON dbo.T1(col1) WHERE col1 IS NOT NULL;
GO
  
-- Fails
INSERT INTO dbo.T1(col1, col2) VALUES(1, 'a'), (1, 'b');

-- Succeeds
INSERT INTO dbo.T1(col1, col2) VALUES(NULL, 'c'), (NULL, 'd');

-- Cleanup
USE TSQLV3;
DROP INDEX idx_USA_orderdate ON Sales.Orders;
DROP TABLE dbo.T1;

---------------------------------------------------------------------
-- Columnstore Indexes
---------------------------------------------------------------------

-- Query demonstrating star join against rowstore
USE PerformanceV3;
SET STATISTICS IO, TIME ON; -- turn on performance statistics

SELECT D1.attr1 AS x, D2.attr1 AS y, D3.attr1 AS z, 
  COUNT(*) AS cnt, SUM(F.measure1) AS total
FROM dbo.Fact AS F
  INNER JOIN dbo.Dim1 AS D1
    ON F.key1 = D1.key1
  INNER JOIN dbo.Dim2 AS D2
    ON F.key2 = D2.key2
  INNER JOIN dbo.Dim3 AS D3
    ON F.key3 = D3.key3
WHERE D1.attr1 <= 10
  AND D2.attr1 <= 15
  AND D3.attr1 <= 10
GROUP BY D1.attr1, D2.attr1, D3.attr1;

-- Create a nonclustered columnstore index on Fact
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_nc_cs
  ON dbo.Fact(key1, key2, key3, measure1, measure2, measure3, measure4);

-- Query again
SELECT D1.attr1 AS x, D2.attr1 AS y, D3.attr1 AS z, 
  COUNT(*) AS cnt, SUM(F.measure1) AS total
FROM dbo.Fact AS F
  INNER JOIN dbo.Dim1 AS D1
    ON F.key1 = D1.key1
  INNER JOIN dbo.Dim2 AS D2
    ON F.key2 = D2.key2
  INNER JOIN dbo.Dim3 AS D3
    ON F.key3 = D3.key3
WHERE D1.attr1 <= 10
  AND D2.attr1 <= 15
  AND D3.attr1 <= 10
GROUP BY D1.attr1, D2.attr1, D3.attr1;
GO

-- Create a clustered columnstore index on FactCS
CREATE TABLE dbo.FactCS
(
  key1     INT NOT NULL,
  key2     INT NOT NULL,
  key3     INT NOT NULL,
  measure1 INT NOT NULL,
  measure2 INT NOT NULL,
  measure3 INT NOT NULL,
  measure4 NVARCHAR(50) NULL,
  filler   BINARY(100) NOT NULL DEFAULT (0x)
);

CREATE CLUSTERED COLUMNSTORE INDEX idx_cl_cs ON dbo.FactCS;

INSERT INTO dbo.FactCS WITH (TABLOCK) SELECT * FROM dbo.Fact;
GO

-- Rebuild index after trickled changes (for partition level add PARTITION = <partition_number>)
ALTER TABLE dbo.FactCS REBUILD;

-- Query again twice (first run will cause statistics to be created so it will take longer)
SELECT D1.attr1 AS x, D2.attr1 AS y, D3.attr1 AS z, 
  COUNT(*) AS cnt, SUM(F.measure1) AS total
FROM dbo.FactCS AS F
  INNER JOIN dbo.Dim1 AS D1
    ON F.key1 = D1.key1
  INNER JOIN dbo.Dim2 AS D2
    ON F.key2 = D2.key2
  INNER JOIN dbo.Dim3 AS D3
    ON F.key3 = D3.key3
WHERE D1.attr1 <= 10
  AND D2.attr1 <= 15
  AND D3.attr1 <= 10
GROUP BY D1.attr1, D2.attr1, D3.attr1;

-- Examine metadata

-- Row groups
SELECT * FROM sys.column_store_row_groups;

-- Column segments
SELECT * FROM sys.column_store_segments;

-- Dictionaries
SELECT * FROM sys.column_store_dictionaries;

-- Cleanup
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
DROP INDEX idx_nc_cs ON dbo.Fact;
DROP TABLE dbo.FactCS;
GO

---------------------------------------------------------------------
-- Inline Index Definition
---------------------------------------------------------------------

DECLARE @T1 AS TABLE
(
  col1 INT NOT NULL
    INDEX idx_cl_col1 CLUSTERED, -- column index
  col2 INT NOT NULL,
  col3 INT NOT NULL,
  INDEX idx_nc_col2_col3 NONCLUSTERED (col2, col3) -- table index
);
GO

---------------------------------------------------------------------
-- Prioritizing Queries for Tuning with Extended Events
---------------------------------------------------------------------

-- Drop session if exists
DROP EVENT SESSION query_perf ON SERVER;
GO

-- Create session
CREATE EVENT SESSION query_perf ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.query_hash)
    WHERE (sqlserver.session_id=(54))),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.query_hash)
    WHERE (sqlserver.session_id=(54))) 
ADD TARGET package0.event_file(SET filename=N'C:\Temp\query_perf.xel');
GO

-- Start session
ALTER EVENT SESSION query_perf ON SERVER STATE = START;

-- Run workload a few times
SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE orderid >= 1000000;

SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE custid = 'C0000000001';

SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE orderdate = '20140101';

SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE orderid >= 1000001;

SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE custid = 'C0000001000';

SELECT orderid, custid, empid, shipperid, orderdate
FROM dbo.Orders
WHERE orderdate = '20140201';

-- Stop session
ALTER EVENT SESSION query_perf ON SERVER STATE = STOP;

-- Copy event data into temp table #Events
SELECT CAST(event_data AS XML) AS event_data_XML
INTO #Events
FROM sys.fn_xe_file_target_read_file('C:\Temp\query_perf*.xel', null, null, null) AS F;

-- Extract query perf info temp table #Queries
SELECT
  event_data_XML.value ('(/event/action[@name=''query_hash''    ]/value)[1]', 'NUMERIC(38, 0)')
    AS query_hash,
  event_data_XML.value ('(/event/data  [@name=''duration''      ]/value)[1]', 'BIGINT'        )
    AS duration,
  event_data_XML.value ('(/event/data  [@name=''cpu_time''      ]/value)[1]', 'BIGINT'        )
    AS cpu_time,
  event_data_XML.value ('(/event/data  [@name=''physical_reads'']/value)[1]', 'BIGINT'        )
    AS physical_reads,
  event_data_XML.value ('(/event/data  [@name=''logical_reads'' ]/value)[1]', 'BIGINT'        )
    AS logical_reads,
  event_data_XML.value ('(/event/data  [@name=''writes''        ]/value)[1]', 'BIGINT'        )
    AS writes,
  event_data_XML.value ('(/event/data  [@name=''row_count''     ]/value)[1]', 'BIGINT'        )
    AS row_count,
  event_data_XML.value ('(/event/data  [@name=''statement''     ]/value)[1]', 'NVARCHAR(4000)')
   AS statement
INTO #Queries
FROM #Events;

CREATE CLUSTERED INDEX idx_cl_query_hash ON #Queries(query_hash);
GO

-- Examine query info
SELECT query_hash, duration, cpu_time, physical_reads AS physreads,
  logical_reads AS logreads, writes, row_count AS rowcnt, statement
FROM #Queries;

-- Prioritize queries for tuning
SELECT 
  query_hash, SUM(duration) AS sumduration,
  CAST(100. * SUM(duration) / SUM(SUM(duration)) OVER() AS NUMERIC(5, 2)) AS pct,
  (SELECT TOP (1) statement
   FROM #Queries AS Q2
   WHERE Q2.query_hash = Q1.query_hash) AS queryexample
FROM #Queries AS Q1
GROUP BY query_hash
ORDER BY SUM(duration) DESC;

-- Cleanup
DROP TABLE #Events, #Queries;
DROP EVENT SESSION query_perf ON SERVER;

---------------------------------------------------------------------
-- Index and Query Information and Statistics
---------------------------------------------------------------------

-- Fragmentation
SELECT database_id, object_id, index_id, partition_number,
  avg_fragmentation_in_percent, avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats( DB_ID('PerformanceV3'), NULL, NULL, NULL, 'SAMPLED' );
GO

-- Rebuild Index
ALTER INDEX <index_name> ON <table_name> REBUILD WITH (FILLFACTOR = 70 /*, ONLINE = ON */);

-- Reorganize Index
ALTER INDEX <index_name> ON <table_name> REORGANIZE;
GO

-- Index operational statistics
SELECT *  FROM sys.dm_db_index_operational_stats( DB_ID('PerformanceV3'), null, null, null );

-- Index usage statistics
SELECT * FROM sys.dm_db_index_usage_stats;

-- Missing Indexes

-- Detail
SELECT * FROM sys.dm_db_missing_index_details;

-- Group statistics
SELECT * FROM sys.dm_db_missing_index_group_stats;

-- Group to index connection
SELECT * FROM sys.dm_db_missing_index_groups;

-- Columns for missing index based on handle
SELECT * FROM sys.dm_db_missing_index_columns(<handle>);

-- Query Stats
SELECT * FROM sys.dm_exec_query_stats;

-- Procedure and trigger stats
SELECT * FROM sys.dm_exec_procedure_stats;
SELECT * FROM sys.dm_exec_trigger_stats;

-- TOP queries with highest elapsed time
SELECT TOP (5)
  MAX(query) AS sample_query,
  SUM(execution_count) AS cnt,
  SUM(total_worker_time) AS cpu,
  SUM(total_physical_reads) AS reads,
  SUM(total_logical_reads) AS logical_reads,
  SUM(total_elapsed_time) AS duration
FROM (SELECT 
        QS.*,
        SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
           ((CASE statement_end_offset 
              WHEN -1 THEN DATALENGTH(ST.text)
              ELSE QS.statement_end_offset END 
                  - QS.statement_start_offset)/2) + 1
        ) AS query
      FROM sys.dm_exec_query_stats AS QS
        CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST
        CROSS APPLY sys.dm_exec_plan_attributes(QS.plan_handle) AS PA
      WHERE PA.attribute = 'dbid'
        AND PA.value = DB_ID('PerformanceV3')) AS D
GROUP BY query_hash
ORDER BY duration DESC;

-- Run this query in one window with include actual execution plan enabled
SELECT O1.orderid, O1.orderdate, MAX(O2.orderdate) AS mxdate
FROM dbo.Orders AS O1
  INNER JOIN dbo.Orders AS O2
    ON O2.orderid <= O1.orderid
GROUP BY O1.orderid, O1.orderdate;

-- Run this query in another window
SELECT * FROM sys.dm_exec_query_profiles;

---------------------------------------------------------------------
-- Temporary Objects
---------------------------------------------------------------------

-- Multiple references

-- Turn on statistics collection
SET STATISTICS IO, TIME ON;

-- Grouped query
SELECT YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM dbo.Orders
GROUP BY YEAR(orderdate);

-- For each year return the year with the closest count of orders

-- With a CTE
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
  FROM dbo.Orders
  GROUP BY YEAR(orderdate)
)
SELECT C1.orderyear, C1.numorders,
  A.orderyear AS otheryear, C1.numorders - A.numorders AS diff
FROM C AS C1 CROSS APPLY
  (SELECT TOP (1) C2.orderyear, C2.numorders
   FROM C AS C2
   WHERE C2.orderyear <> C1.orderyear
   ORDER BY ABS(C1.numorders - C2.numorders)) AS A
ORDER BY C1.orderyear;
GO

-- With a table variable
DECLARE @T AS TABLE
(
  orderyear INT,
  numorders INT
);

INSERT INTO @T(orderyear, numorders)
  SELECT YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
  FROM dbo.Orders
  GROUP BY YEAR(orderdate)

SELECT T1.orderyear, T1.numorders,
  A.orderyear AS otheryear, T1.numorders - A.numorders AS diff
FROM @T AS T1 CROSS APPLY
  (SELECT TOP (1) T2.orderyear, T2.numorders
   FROM @T AS T2
   WHERE T2.orderyear <> T1.orderyear
   ORDER BY ABS(T1.numorders - T2.numorders)) AS A
ORDER BY T1.orderyear;
GO

-- Lack of histograms can lead to suboptimal plans

-- Queries with table variable
DECLARE @T AS TABLE
(
  col1 INT NOT NULL PRIMARY KEY NONCLUSTERED,
  col2 INT NOT NULL,
  filler CHAR(200) NOT NULL
);

INSERT INTO @T(col1, col2, filler)
  SELECT n AS col1, n AS col2, 'a' AS filler
  FROM TSQLV3.dbo.GetNums(1, 100000) AS Nums;

-- Query 1
SELECT col1, col2, filler
FROM @T
WHERE col1 <= 100
ORDER BY col2;

-- Query 2
SELECT col1, col2, filler
FROM @T
WHERE col1 <= 100
ORDER BY col2
OPTION(RECOMPILE);

-- Query 3
SELECT col1, col2, filler
FROM @T
WHERE col1 >= 100
ORDER BY col2
OPTION(RECOMPILE);
GO

-- Queries with temp table
CREATE TABLE #T
(
  col1 INT NOT NULL PRIMARY KEY NONCLUSTERED,
  col2 INT NOT NULL,
  filler CHAR(200) NOT NULL
);
GO

INSERT INTO #T(col1, col2, filler)
  SELECT n AS col1, n AS col2, 'a' AS filler
  FROM TSQLV3.dbo.GetNums(1, 100000) AS Nums
OPTION(MAXDOP 1);

-- Query 1
SELECT col1, col2, filler
FROM #T
WHERE col1 <= 100
ORDER BY col2;

-- Query 2
SELECT col1, col2, filler
FROM #T
WHERE col1 >= 100
ORDER BY col2;
GO

-- Cleanup
DROP TABLE #T;
GO

---------------------------------------------------------------------
-- Set-Based versus Iterative Solutions
---------------------------------------------------------------------

-- Add a few rows to Shippers and Orders
SET NOCOUNT ON;
USE PerformanceV3;

INSERT INTO dbo.Shippers(shipperid, shippername)
  VALUES ('B', 'Shipper_B'),
         ('D', 'Shipper_D'),
         ('F', 'Shipper_F'),
         ('H', 'Shipper_H'),
         ('X', 'Shipper_X'),
         ('Y', 'Shipper_Y'),
         ('Z', 'Shipper_Z');

INSERT INTO dbo.Orders(orderid, custid, empid, shipperid, orderdate)
  VALUES (1000001, 'C0000000001', 1, 'B', '20090101'),
         (1000002, 'C0000000001', 1, 'D', '20090101'),
         (1000003, 'C0000000001', 1, 'F', '20090101'),
         (1000004, 'C0000000001', 1, 'H', '20090101');
GO

-- Create covering index for problem
CREATE NONCLUSTERED INDEX idx_nc_sid_od ON dbo.Orders(shipperid, orderdate);
GO

-- Clear data cache before running each solution
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

-- Cursor Solution
DECLARE
  @sid     AS VARCHAR(5),
  @od      AS DATETIME,
  @prevsid AS VARCHAR(5),
  @prevod  AS DATETIME;

DECLARE ShipOrdersCursor CURSOR FAST_FORWARD FOR
  SELECT shipperid, orderdate
  FROM dbo.Orders
  ORDER BY shipperid, orderdate;

OPEN ShipOrdersCursor;

FETCH NEXT FROM ShipOrdersCursor INTO @sid, @od;

SELECT @prevsid = @sid, @prevod = @od;

WHILE @@fetch_status = 0
BEGIN
  IF @prevsid <> @sid AND @prevod < '20100101' PRINT @prevsid;
  SELECT @prevsid = @sid, @prevod = @od;
  FETCH NEXT FROM ShipOrdersCursor INTO @sid, @od;
END

IF @prevod < '20100101' PRINT @prevsid;

CLOSE ShipOrdersCursor;

DEALLOCATE ShipOrdersCursor;
GO

-- Turn on statistics
SET STATISTICS IO, TIME ON;

-- Set-based solution 1
SELECT shipperid
FROM dbo.Orders
GROUP BY shipperid
HAVING MAX(orderdate) < '20100101';

---------------------------------------------------------------------
-- Query Tuning with Query Revisions
---------------------------------------------------------------------

-- Get maximum date for a particular shipper
SELECT MAX(orderdate) FROM dbo.Orders WHERE shipperid = 'A';

-- Set-based solution 2
SELECT shipperid
FROM dbo.Shippers AS S
WHERE (SELECT MAX(orderdate)
       FROM dbo.Orders AS O
       WHERE O.shipperid = S.shipperid) < '20100101';

-- Set-based solution 3
SELECT shipperid
FROM dbo.Shippers AS S
WHERE (SELECT TOP (1) orderdate
       FROM dbo.Orders AS O
       WHERE O.shipperid = S.shipperid
       ORDER BY orderdate DESC) < '20100101';

-- Set-based solution 4
SELECT shipperid
FROM dbo.Shippers AS S
WHERE NOT EXISTS
  (SELECT * FROM dbo.Orders AS O
   WHERE O.shipperid = S.shipperid
     AND O.orderdate >= '20100101')
  AND EXISTS
  (SELECT * FROM dbo.Orders AS O
   WHERE O.shipperid = S.shipperid);

-- Turn off statistics
SET STATISTICS IO, TIME OFF;

-- Cleanup
-- Recreate PerformanceV3

---------------------------------------------------------------------
-- Parallel query execution
---------------------------------------------------------------------

USE AdventureWorks2014;
GO

---------------------------------------------------------------------
-- Parallel Sort and Merging Exchange
---------------------------------------------------------------------

SELECT TOP(1000)
    UnitPrice
FROM Sales.SalesOrderDetail
ORDER BY
    UnitPrice DESC;
GO

---------------------------------------------------------------------
-- Partial Aggregation
---------------------------------------------------------------------

SELECT 
    th.ProductID,
    th.TransactionDate,
    MAX(th.ActualCost) AS MaxCost
FROM
(
    SELECT
        tha.ProductID,
        tha.TransactionDate,
        tha.ActualCost
    FROM Production.TransactionHistoryArchive AS tha
    CROSS JOIN Production.TransactionHistory AS th
) AS th
GROUP BY
    th.ProductID,
    th.TransactionDate;
GO

---------------------------------------------------------------------
-- Parallel Scan
---------------------------------------------------------------------

SELECT
    ActualCost
FROM Production.TransactionHistory AS th
ORDER BY
    ActualCost DESC;
GO

---------------------------------------------------------------------
-- Few Outer Rows
---------------------------------------------------------------------

SELECT
    p.ProductId,
    th0.TransactionID
FROM Production.Product AS p
CROSS APPLY
(
    SELECT TOP(1000)
        th.TransactionId
    FROM Production.TransactionHistory AS th
    WHERE
        th.ProductID = p.ProductID
    ORDER BY
        th.TransactionID
) AS th0
ORDER BY
    th0.TransactionId;
GO

---------------------------------------------------------------------
-- Parallel Hash Join and Bitmap
---------------------------------------------------------------------

SELECT
    *
FROM
(
    SELECT
        sh.*,
        sd.ProductId
    FROM
    (
        SELECT TOP(1000) 
            *
        FROM Sales.SalesOrderDetail
        ORDER BY
            SalesOrderDetailId
    ) AS sd
    INNER JOIN Sales.SalesOrderHeader AS sh ON
        sh.SalesOrderId = sd.SalesOrderId
) AS s;
GO

---------------------------------------------------------------------
-- Parallelism and Partitioned Tables
---------------------------------------------------------------------

USE tempdb;
GO

CREATE PARTITION FUNCTION pf_1 (INT)
AS RANGE LEFT FOR VALUES 
(
    25000, 50000, 75000, 100000,
    125000, 150000, 175000, 200000,
    225000, 250000, 275000, 300000,
    325000, 350000, 375000, 400000,
    425000, 450000, 475000, 500000,
    525000, 550000, 575000, 600000,
    625000, 650000, 675000, 700000,
    725000, 750000, 775000, 800000,
    825000, 850000, 875000, 900000,
    925000, 950000, 975000, 1000000
);
GO

CREATE PARTITION SCHEME ps_1
AS PARTITION pf_1 ALL TO ([PRIMARY]);
GO

CREATE TABLE dbo.partitioned_table
(
  col1 INT NOT NULL,
  col2 INT NOT NULL,
  some_stuff CHAR(200) NOT NULL DEFAULT('')
) ON ps_1(col1);
GO

CREATE UNIQUE CLUSTERED INDEX ix_col1 
ON dbo.partitioned_table
(
    col1
) ON ps_1(col1);
GO

WITH 
n1 AS (SELECT 1 a UNION ALL SELECT 1),
n2 AS (SELECT 1 a FROM n1 b, n1 c),
n3 AS (SELECT 1 a FROM n2 b, n2 c),
n4 AS (SELECT 1 a FROM n3 b, n3 c),
n5 AS (SELECT 1 a FROM n4 b, n4 c),
n6 AS (SELECT 1 a FROM n5 b, n5 c)
INSERT INTO dbo.partitioned_table WITH (TABLOCK)
(
    col1, 
    col2
)
SELECT TOP(1000000)
    ROW_NUMBER() OVER
    (
        ORDER BY
            (SELECT NULL)
    ) AS col1,
    CHECKSUM(NEWID()) AS col2
FROM n6;
GO

SELECT 
    COUNT(*)
FROM partitioned_table AS pt1
INNER JOIN partitioned_table AS pt2 ON 
    pt1.col1 = pt2.col1
WHERE
    pt1.col1 BETWEEN 25000 AND 500000;
GO 

---------------------------------------------------------------------
-- Parallel SELECT INTO
---------------------------------------------------------------------

WITH 
n1 AS (SELECT 1 a UNION ALL SELECT 1),
n2 AS (SELECT 1 a FROM n1 b, n1 c),
n3 AS (SELECT 1 a FROM n2 b, n2 c),
n4 AS (SELECT 1 a FROM n3 b, n3 c),
n5 AS (SELECT 1 a FROM n4 b, n4 c),
n6 AS (SELECT 1 a FROM n5 b, n5 c)
SELECT TOP(10000000)
    ROW_NUMBER() OVER
    (
        ORDER BY
            (SELECT NULL)
    ) AS col1,
    CHECKSUM(NEWID()) AS col2
INTO #test_table
FROM n6;
GO

---------------------------------------------------------------------
-- Parallelism Inhibitors
---------------------------------------------------------------------

USE AdventureWorks2014;
GO

SELECT TOP(1000)
    OrderQty
FROM Sales.SalesOrderDetail
ORDER BY
    OrderQty DESC;
GO

CREATE FUNCTION dbo.ReturnInput(@input INT)
RETURNS INT
AS
BEGIN
    RETURN(@input)
END
GO

SELECT TOP(1000)
    dbo.ReturnInput(OrderQty)
FROM Sales.SalesOrderDetail
ORDER BY
    OrderQty DESC;
GO

---------------------------------------------------------------------
-- An Example Query
---------------------------------------------------------------------

SELECT
    p.Name,
    p.ProductID + x.v AS ProductID 
INTO #bigger_products
FROM Production.Product AS p
CROSS JOIN
(
    VALUES
        (0),(1000),(2000),(3000),(4000)
) AS x(v);

CREATE CLUSTERED INDEX i_ProductID
ON #bigger_products (ProductID);
GO

SELECT
    th.ProductID + x.v AS ProductID,
    th.ActualCost,
    th.TransactionDate
INTO #bigger_transactions
FROM Production.TransactionHistory AS th
CROSS JOIN 
(
    SELECT
        (NTILE(5) OVER (ORDER BY p.ProductId) - 1) * 1000
    FROM Production.Product AS p
) AS x(v);

CREATE CLUSTERED INDEX i_ProductID
ON #bigger_transactions (ProductID);
GO

SELECT
    p.Name,
    x.TransactionDate,
    x.ActualCost
FROM
(
    SELECT
        th.ProductID,
        th.TransactionDate,
        th.ActualCost,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                th.ProductId
            ORDER BY
                th.ActualCost DESC
        ) AS rn
    FROM #bigger_transactions AS th
) AS x
INNER JOIN #bigger_products AS p ON
    p.ProductID = x.ProductID
WHERE
    x.rn <= 10;
GO

---------------------------------------------------------------------
-- Reducing Parallel Plan Overhead
---------------------------------------------------------------------

SELECT
    p.Name,
    x.TransactionDate,
    x.ActualCost
FROM #bigger_products AS p
CROSS APPLY
(
    SELECT
        th.TransactionDate,
        th.ActualCost,
        ROW_NUMBER() OVER
        (
            ORDER BY
                th.ActualCost DESC
        ) AS rn
    FROM #bigger_transactions AS th
    WHERE
        th.ProductID = p.ProductID
) AS x
WHERE
    x.rn <= 10;
GO
