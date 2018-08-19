----------------------------------------------------------------------
-- High-Performance T-SQL: Set-based Solutions using Microsoft SQL Server 2012 Window Functions
-- Chapter 05 - T-SQL Solutions using Window Functions
-- © Itzik Ben-Gan
----------------------------------------------------------------------

SET NOCOUNT ON;
USE TSQL2012;

----------------------------------------------------------------------
-- Virtual Auxiliary Table of Numbers
----------------------------------------------------------------------

-- two rows
SELECT c FROM (VALUES(1),(1)) AS D(c);

c
-----------
1
1

-- four rows
WITH
  L0   AS (SELECT c FROM (VALUES(1),(1)) AS D(c))
SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B;

c
-----------
1
1
1
1

-- 16 rows
WITH
  L0   AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
  L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B)
SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B;

c
-----------
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1

-- definition of GetNums function, SQL Server 2012 version
USE TSQL2012;
IF OBJECT_ID('dbo.GetNums', 'IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
            FROM L5)
  SELECT @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum
  OFFSET 0 ROWS FETCH FIRST @high - @low + 1 ROWS ONLY;
GO

-- definition of GetNums function, pre-SQL Server 2012 version
IF OBJECT_ID('dbo.GetNums', 'IF') IS NOT NULL
  DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
            FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO

-- test function
SELECT n FROM dbo.GetNums(11, 20);

/*
n
--------------------
11
12
13
14
15
16
17
18
19
20
*/

-- 6 seconds for 10,000,000 rows, both versions, with results discarded
SELECT n FROM dbo.GetNums(1, 10000000);
GO

----------------------------------------------------------------------
-- Sequences of Date and Time Values
----------------------------------------------------------------------

DECLARE 
  @start AS DATE = '20120201',
  @end   AS DATE = '20120212';

SELECT DATEADD(day, n, @start) AS dt
FROM dbo.GetNums(0, DATEDIFF(day, @start, @end)) AS Nums;
GO

/*
dt
----------
2012-02-01
2012-02-02
2012-02-03
2012-02-04
2012-02-05
2012-02-06
2012-02-07
2012-02-08
2012-02-09
2012-02-10
2012-02-11
2012-02-12
*/

DECLARE 
  @start AS DATETIME2 = '2012-02-12 00:00:00.0000000',
  @end   AS DATETIME2 = '2012-02-18 12:00:00.0000000';

SELECT DATEADD(hour, n*12, @start) AS dt
FROM dbo.GetNums(0, DATEDIFF(hour, @start, @end)/12) AS Nums;
GO

/*
dt
---------------------------
2012-02-12 00:00:00.0000000
2012-02-12 12:00:00.0000000
2012-02-13 00:00:00.0000000
2012-02-13 12:00:00.0000000
2012-02-14 00:00:00.0000000
2012-02-14 12:00:00.0000000
2012-02-15 00:00:00.0000000
2012-02-15 12:00:00.0000000
2012-02-16 00:00:00.0000000
2012-02-16 12:00:00.0000000
2012-02-17 00:00:00.0000000
2012-02-17 12:00:00.0000000
2012-02-18 00:00:00.0000000
2012-02-18 12:00:00.0000000
*/

----------------------------------------------------------------------
-- Sequences of Keys
----------------------------------------------------------------------

-- assign unique keys

-- sample data
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
  DROP TABLE Sales.MyOrders;
GO

SELECT 0 AS orderid, custid, empid, orderdate
INTO Sales.MyOrders
FROM Sales.Orders;

SELECT * FROM Sales.MyOrders;

/*
orderid     custid      empid       orderdate
----------- ----------- ----------- -----------------------
0           85          5           2006-07-04 00:00:00.000
0           79          6           2006-07-05 00:00:00.000
0           34          4           2006-07-08 00:00:00.000
0           84          3           2006-07-08 00:00:00.000
0           76          4           2006-07-09 00:00:00.000
0           34          3           2006-07-10 00:00:00.000
0           14          5           2006-07-11 00:00:00.000
0           68          9           2006-07-12 00:00:00.000
0           88          3           2006-07-15 00:00:00.000
0           35          4           2006-07-16 00:00:00.000
...
*/

-- assign keys
WITH C AS
(
  SELECT orderid, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
  FROM Sales.MyOrders
)
UPDATE C
  SET orderid = rownum;

SELECT * FROM Sales.MyOrders;

/*
orderid     custid      empid       orderdate
----------- ----------- ----------- -----------------------
1           85          5           2006-07-04 00:00:00.000
2           79          6           2006-07-05 00:00:00.000
3           34          4           2006-07-08 00:00:00.000
4           84          3           2006-07-08 00:00:00.000
5           76          4           2006-07-09 00:00:00.000
6           34          3           2006-07-10 00:00:00.000
7           14          5           2006-07-11 00:00:00.000
8           68          9           2006-07-12 00:00:00.000
9           88          3           2006-07-15 00:00:00.000
10          35          4           2006-07-16 00:00:00.000
...
*/

-- apply a range of sequence values obtained from a sequence table
IF OBJECT_ID('dbo.MySequence', 'U') IS NOT NULL DROP TABLE dbo.MySequence;
CREATE TABLE dbo.MySequence(val INT);
INSERT INTO dbo.MySequence VALUES(0);

-- single sequence value

-- sequence proc
IF OBJECT_ID('dbo.GetSequence', 'P') IS NOT NULL DROP PROC dbo.GetSequence;
GO

CREATE PROC dbo.GetSequence
  @val AS INT OUTPUT
AS
UPDATE dbo.MySequence
  SET @val = val += 1;
GO

-- get next sequence (run twice)
DECLARE @key AS INT;
EXEC dbo.GetSequence @val = @key OUTPUT;
SELECT @key;
GO

-- range of sequence values

-- alter sequence proc to support a block of sequence values
ALTER PROC dbo.GetSequence
  @val AS INT OUTPUT,
  @n   AS INT = 1
AS
UPDATE dbo.MySequence
  SET @val = val + 1,
       val += @n;
GO

-- assign sequence values to multiple rows

-- need to assign surrogate keys to the following customers from MySequence
SELECT custid
FROM Sales.Customers
WHERE country = N'UK';

/*
custid
-----------
4
11
16
19
38
53
72
*/

-- solution
DECLARE @firstkey AS INT, @rc AS INT;

DECLARE @CustsStage AS TABLE
(
  custid INT,
  rownum INT
);

INSERT INTO @CustsStage(custid, rownum)
  SELECT custid, ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
  FROM Sales.Customers
  WHERE country = N'UK';

SET @rc = @@rowcount;

EXEC dbo.GetSequence @val = @firstkey OUTPUT, @n = @rc;

SELECT custid, @firstkey + rownum - 1 AS keycol
FROM @CustsStage;
GO

/*
custid      keycol
----------- -----------
4           3
11          4
16          5
19          6
38          7
53          8
72          9
*/

-- this time with customers from France
DECLARE @firstkey AS INT, @rc AS INT;

DECLARE @CustsStage AS TABLE
(
  custid INT,
  rownum INT
);

INSERT INTO @CustsStage(custid, rownum)
  SELECT custid, ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
  FROM Sales.Customers
  WHERE country = N'France';

SET @rc = @@rowcount;

EXEC dbo.GetSequence @val = @firstkey OUTPUT, @n = @rc;

SELECT custid, @firstkey + rownum - 1 AS keycol
FROM @CustsStage;
GO

/*
custid      keycol
----------- -----------
7           10
9           11
18          12
23          13
26          14
40          15
41          16
57          17
74          18
84          19
85          20
*/

-- cleanup
IF OBJECT_ID('dbo.GetSequence', 'P') IS NOT NULL DROP PROC dbo.GetSequence;
IF OBJECT_ID('dbo.MySequence', 'U') IS NOT NULL DROP TABLE dbo.MySequence;

----------------------------------------------------------------------
-- Paging
----------------------------------------------------------------------

-- create index
CREATE UNIQUE INDEX idx_od_oid_i_cid_eid
  ON Sales.Orders(orderdate, orderid)
  INCLUDE(custid, empid);
GO

-- with ROW_NUMBER
DECLARE
  @pagenum  AS INT = 3,
  @pagesize AS INT = 25;

WITH C AS
(
  SELECT ROW_NUMBER() OVER( ORDER BY orderdate, orderid ) AS rownum,
    orderid, orderdate, custid, empid
  FROM Sales.Orders
)
SELECT orderid, orderdate, custid, empid
FROM C
WHERE rownum BETWEEN (@pagenum - 1) * @pagesize + 1
                 AND @pagenum * @pagesize
ORDER BY rownum;
GO

/*
orderid     orderdate               custid      empid
----------- ----------------------- ----------- -----------
10298       2006-09-05 00:00:00.000 37          6
10299       2006-09-06 00:00:00.000 67          4
10300       2006-09-09 00:00:00.000 49          2
10301       2006-09-09 00:00:00.000 86          8
10302       2006-09-10 00:00:00.000 76          4
10303       2006-09-11 00:00:00.000 30          7
10304       2006-09-12 00:00:00.000 80          1
10305       2006-09-13 00:00:00.000 55          8
10306       2006-09-16 00:00:00.000 69          1
10307       2006-09-17 00:00:00.000 48          2
10308       2006-09-18 00:00:00.000 2           7
10309       2006-09-19 00:00:00.000 37          3
10310       2006-09-20 00:00:00.000 77          8
10311       2006-09-20 00:00:00.000 18          1
10312       2006-09-23 00:00:00.000 86          2
10313       2006-09-24 00:00:00.000 63          2
10314       2006-09-25 00:00:00.000 65          1
10315       2006-09-26 00:00:00.000 38          4
10316       2006-09-27 00:00:00.000 65          1
10317       2006-09-30 00:00:00.000 48          6
10318       2006-10-01 00:00:00.000 38          8
10319       2006-10-02 00:00:00.000 80          7
10320       2006-10-03 00:00:00.000 87          5
10321       2006-10-03 00:00:00.000 38          3
10322       2006-10-04 00:00:00.000 58          7
*/

-- with OFFSET/FETCH
DECLARE
  @pagenum  AS INT = 3,
  @pagesize AS INT = 25;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

-- cleanup
DROP INDEX idx_od_oid_i_cid_eid ON Sales.Orders;

----------------------------------------------------------------------
-- Removing Duplicates
----------------------------------------------------------------------

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO

SELECT * INTO Sales.MyOrders FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders;
GO

-- small number of duplicates

-- mark duplicates
SELECT orderid,
  ROW_NUMBER() OVER(PARTITION BY orderid
                    ORDER BY (SELECT NULL)) AS n
FROM Sales.MyOrders;

/*
orderid     n
----------- --------------------
10248       1
10248       2
10248       3
10249       1
10249       2
10249       3
10250       1
10250       2
10250       3
*/

-- remove duplicates
WITH C AS
(
  SELECT orderid,
    ROW_NUMBER() OVER(PARTITION BY orderid
                      ORDER BY (SELECT NULL)) AS n
  FROM Sales.MyOrders
)
DELETE FROM C
WHERE n > 1;

-- Large number of duplicates
WITH C AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY orderid
                      ORDER BY (SELECT NULL)) AS n
  FROM Sales.MyOrders
)
SELECT orderid, custid, empid, orderdate, requireddate, shippeddate, 
  shipperid, freight, shipname, shipaddress, shipcity, shipregion, 
  shippostalcode, shipcountry
INTO Sales.OrdersTmp
FROM C
WHERE n = 1;

DROP TABLE Sales.MyOrders;
EXEC sp_rename 'Sales.OrdersTmp', 'MyOrders';
-- recreate indexes, constraints, triggers

-- another solution
-- mark row numbers and ranks
SELECT orderid,
  ROW_NUMBER() OVER(ORDER BY orderid) AS rownum,
  RANK() OVER(ORDER BY orderid) AS rnk
FROM Sales.MyOrders;

/*
orderid     rownum               rnk
----------- -------------------- --------------------
10248       1                    1
10248       2                    1
10248       3                    1
10249       4                    4
10249       5                    4
10249       6                    4
10250       7                    7
10250       8                    7
10250       9                    7
*/

-- remove duplicates
WITH C AS
(
  SELECT orderid,
    ROW_NUMBER() OVER(ORDER BY orderid) AS rownum,
    RANK() OVER(ORDER BY orderid) AS rnk
  FROM Sales.MyOrders
)
DELETE FROM C
WHERE rownum <> rnk;

-- cleanup
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;

----------------------------------------------------------------------
-- Pivoting
----------------------------------------------------------------------

-- total order values for each year and month
-- show years on rows, months on columns, and total order values in data
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, MONTH(orderdate) AS ordermonth, val
  FROM Sales.OrderValues
)
SELECT *
FROM C
  PIVOT(SUM(val)
    FOR ordermonth IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS P;

/*
orderyear  1         2         3          4           5         6         
---------- --------- --------- ---------- ----------- --------- --------- 
2007       61258.08  38483.64  38547.23   53032.95    53781.30  36362.82  
2008       94222.12  99415.29  104854.18  123798.70   18333.64  NULL      
2006       NULL      NULL      NULL       NULL        NULL      NULL      

orderyear  7         8         9         10        11        12
---------- --------- --------- --------- --------- --------- ---------
2007       51020.86  47287.68  55629.27  66749.23  43533.80  71398.44
2008       NULL      NULL      NULL      NULL      NULL      NULL
2006       27861.90  25485.28  26381.40  37515.73  45600.05  45239.63
*/

-- order values of 5 most recent orders per customer
-- show customer IDs on rows, ordinals on columns, and total order values in data

-- generate row numbers
SELECT custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY orderdate DESC, orderid DESC) AS rownum
FROM Sales.OrderValues;

/*
custid  val      rownum
------- -------- -------
1       933.50   1
1       471.20   2
1       845.80   3
1       330.00   4
1       878.00   5
1       814.50   6
2       514.40   1
2       320.00   2
2       479.75   3
2       88.80    4
3       660.00   1
3       375.50   2
3       813.37   3
3       2082.00  4
3       1940.85  5
3       749.06   6
3       403.20   7
...
*/

-- handle pivoting
WITH C AS
(
  SELECT custid, val,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rownum
  FROM Sales.OrderValues
)
SELECT *
FROM C
  PIVOT(MAX(val) FOR rownum IN ([1],[2],[3],[4],[5])) AS P;

/*
custid  1        2        3        4        5
------- -------- -------- -------- -------- ---------
1       933.50   471.20   845.80   330.00   878.00
2       514.40   320.00   479.75   88.80    NULL
3       660.00   375.50   813.37   2082.00  1940.85
4       491.50   4441.25  390.00   282.00   191.10
5       1835.70  709.55   1096.20  2048.21  1064.50
6       858.00   677.00   625.00   464.00   330.00
7       730.00   660.00   450.00   593.75   1761.00
8       224.00   3026.85  982.00   NULL     NULL
9       792.75   360.00   1788.63  917.00   1979.23
10      525.00   1309.50  877.73   1014.00  717.50
...
*/

-- concatenate order IDs of 5 most recent orders per customer
WITH C AS
(
  SELECT custid, CAST(orderid AS VARCHAR(11)) AS sorderid,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rownum
  FROM Sales.OrderValues
)
SELECT custid, CONCAT([1], ','+[2], ','+[3], ','+[4], ','+[5]) AS orderids
FROM C
  PIVOT(MAX(sorderid) FOR rownum IN ([1],[2],[3],[4],[5])) AS P;

/*
custid      orderids
----------- -----------------------------------------------------------
1           11011,10952,10835,10702,10692
2           10926,10759,10625,10308
3           10856,10682,10677,10573,10535
4           11016,10953,10920,10864,10793
5           10924,10875,10866,10857,10837
6           11058,10956,10853,10614,10582
7           10826,10679,10628,10584,10566
8           10970,10801,10326
9           11076,10940,10932,10876,10871
10          11048,11045,11027,10982,10975
...
*/

-- pre-SQL Server 2012 solution
WITH C AS
(
  SELECT custid, CAST(orderid AS VARCHAR(11)) AS sorderid,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rownum
  FROM Sales.OrderValues
)
SELECT custid, 
  [1] + COALESCE(','+[2], '')
      + COALESCE(','+[3], '')
      + COALESCE(','+[4], '')
      + COALESCE(','+[5], '') AS orderids
FROM C
  PIVOT(MAX(sorderid) FOR rownum IN ([1],[2],[3],[4],[5])) AS P;
GO

----------------------------------------------------------------------
-- TOP N Per Group
----------------------------------------------------------------------

-- TOP OVER (unsupported)
SELECT
  TOP (3) OVER(
    PARTITION BY custid
    ORDER BY orderdate DESC, orderid DESC)
  custid, orderdate, orderid, empid
FROM Sales.Orders;
GO

-- POC index
CREATE UNIQUE INDEX idx_cid_odD_oidD_i_empid
  ON Sales.Orders(custid, orderdate DESC, orderid DESC)
  INCLUDE(empid);

-- low density of partitioning element
WITH C AS
(
  SELECT custid, orderdate, orderid, empid,
    ROW_NUMBER() OVER(
      PARTITION BY custid
      ORDER BY orderdate DESC, orderid DESC) AS rownum
  FROM Sales.Orders
)
SELECT *
FROM C
WHERE rownum <= 3
ORDER BY custid, rownum;

-- high density of partitioning column
SELECT C.custid, A.*
FROM Sales.Customers AS C
  CROSS APPLY (SELECT orderdate, orderid, empid
               FROM Sales.Orders AS O
               WHERE O.custid = C.custid
               ORDER BY orderdate DESC, orderid DESC
               OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY) AS A;

-- pre-SQL Server 2012 alternative
SELECT C.custid, A.*
FROM Sales.Customers AS C
  CROSS APPLY (SELECT TOP (3) orderdate, orderid, empid
               FROM Sales.Orders AS O
               WHERE O.custid = C.custid
               ORDER BY orderdate DESC, orderid DESC) AS A;
               
-- cleanup
DROP INDEX idx_cid_odD_oidD_i_empid ON Sales.Orders;

-- carry-along-sort technique
WITH C AS
(
  SELECT custid, 
    MAX(CONVERT(CHAR(8), orderdate, 112)
        + STR(orderid, 10)
        + STR(empid, 10) COLLATE Latin1_General_BIN2) AS mx
  FROM Sales.Orders
  GROUP BY custid
)
SELECT custid,
  CAST(SUBSTRING(mx,  1,  8) AS DATETIME) AS orderdate,
  CAST(SUBSTRING(mx,  9, 10) AS INT)      AS custid,
  CAST(SUBSTRING(mx, 19, 10) AS INT)      AS empid
FROM C;

----------------------------------------------------------------------
-- Mode
----------------------------------------------------------------------

-- index
CREATE INDEX idx_custid_empid ON Sales.Orders(custid, empid);

-- first step: calculate the count of orders for each customer and employee
SELECT custid, empid, COUNT(*) AS cnt
FROM Sales.Orders
GROUP BY custid, empid;

/*
custid      empid       cnt
----------- ----------- -----------
1           1           2
3           1           1
4           1           3
5           1           4
9           1           3
10          1           2
11          1           1
14          1           1
15          1           1
17          1           2
...
*/

-- second step: add calculation of row numbers:
SELECT custid, empid, COUNT(*) AS cnt,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY COUNT(*) DESC, empid DESC) AS rn
FROM Sales.Orders
GROUP BY custid, empid;

/*
custid      empid       cnt         rn
----------- ----------- ----------- --------------------
1           4           2           1
1           1           2           2
1           6           1           3
1           3           1           4
2           3           2           1
2           7           1           2
2           4           1           3
3           3           3           1
3           7           2           2
3           4           1           3
3           1           1           4
...
*/

-- solution based on window functions, using a tiebreaker
WITH C AS
(
  SELECT custid, empid, COUNT(*) AS cnt,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY COUNT(*) DESC, empid DESC) AS rn
  FROM Sales.Orders
  GROUP BY custid, empid
)
SELECT custid, empid, cnt
FROM C
WHERE rn = 1;

/*
custid      empid       cnt
----------- ----------- -----------
1           4           2
2           3           2
3           3           3
4           4           4
5           3           6
6           9           3
7           4           3
8           4           2
9           4           4
10          3           4
...
*/

-- solution based on ranking calculations, no tiebreaker
WITH C AS
(
  SELECT custid, empid, COUNT(*) AS cnt,
    RANK() OVER(PARTITION BY custid
                ORDER BY COUNT(*) DESC) AS rn
  FROM Sales.Orders
  GROUP BY custid, empid
)
SELECT custid, empid, cnt
FROM C
WHERE rn = 1;

/*
custid      empid       cnt
----------- ----------- -----------
1           1           2
1           4           2
2           3           2
3           3           3
4           4           4
5           3           6
6           9           3
7           4           3
8           4           2
9           4           4
10          3           4
11          6           2
11          4           2
11          3           2
...
*/

-- solution based on carry-along-sort

-- first, create the concatenated string
SELECT custid,
  STR(COUNT(*), 10) + STR(empid, 10) COLLATE Latin1_General_BIN2 AS cntemp
FROM Sales.Orders
GROUP BY custid, empid;

/*
custid      cntemp
----------- --------------------
1                    2         1
3                    1         1
4                    3         1
5                    4         1
9                    3         1
10                   2         1
11                   1         1
14                   1         1
15                   1         1
17                   2         1
...
*/

-- complete solution
WITH C AS
(
  SELECT custid,
    STR(COUNT(*), 10) + STR(empid, 10) COLLATE Latin1_General_BIN2 AS cntemp
  FROM Sales.Orders
  GROUP BY custid, empid
)
SELECT custid,
  CAST(SUBSTRING(MAX(cntemp), 11, 10) AS INT) AS empid,
  CAST(SUBSTRING(MAX(cntemp),  1, 10) AS INT) AS cnt
FROM C
GROUP BY custid;

/*
custid      empid       cnt
----------- ----------- -----------
1           4           2
2           3           2
3           3           3
4           4           4
5           3           6
6           9           3
7           4           3
8           4           2
9           4           4
10          3           4
...
*/

-- cleanup
DROP INDEX idx_custid_empid ON Sales.Orders;

----------------------------------------------------------------------
-- Running Totals
----------------------------------------------------------------------

-- DDL for Transactions Table
SET NOCOUNT ON;
USE TSQL2012;

IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;

CREATE TABLE dbo.Transactions
(
  actid  INT   NOT NULL,                -- partitioning column
  tranid INT   NOT NULL,                -- ordering column
  val    MONEY NOT NULL,                -- measure
  CONSTRAINT PK_Transactions PRIMARY KEY(actid, tranid)
);
GO

-- small set of sample data
INSERT INTO dbo.Transactions(actid, tranid, val) VALUES
  (1,  1,  4.00),
  (1,  2, -2.00),
  (1,  3,  5.00),
  (1,  4,  2.00),
  (1,  5,  1.00),
  (1,  6,  3.00),
  (1,  7, -4.00),
  (1,  8, -1.00),
  (1,  9, -2.00),
  (1, 10, -3.00),
  (2,  1,  2.00),
  (2,  2,  1.00),
  (2,  3,  5.00),
  (2,  4,  1.00),
  (2,  5, -5.00),
  (2,  6,  4.00),
  (2,  7,  2.00),
  (2,  8, -4.00),
  (2,  9, -5.00),
  (2, 10,  4.00),
  (3,  1, -3.00),
  (3,  2,  3.00),
  (3,  3, -2.00),
  (3,  4,  1.00),
  (3,  5,  4.00),
  (3,  6, -1.00),
  (3,  7,  5.00),
  (3,  8,  3.00),
  (3,  9,  5.00),
  (3, 10, -3.00);
GO

-- desired results
/*
actid       tranid      val                   balance
----------- ----------- --------------------- ---------------------
1           1           4.00                  4.00
1           2           -2.00                 2.00
1           3           5.00                  7.00
1           4           2.00                  9.00
1           5           1.00                  10.00
1           6           3.00                  13.00
1           7           -4.00                 9.00
1           8           -1.00                 8.00
1           9           -2.00                 6.00
1           10          -3.00                 3.00
2           1           2.00                  2.00
2           2           1.00                  3.00
2           3           5.00                  8.00
2           4           1.00                  9.00
2           5           -5.00                 4.00
2           6           4.00                  8.00
2           7           2.00                  10.00
2           8           -4.00                 6.00
2           9           -5.00                 1.00
2           10          4.00                  5.00
3           1           -3.00                 -3.00
3           2           3.00                  0.00
3           3           -2.00                 -2.00
3           4           1.00                  -1.00
3           5           4.00                  3.00
3           6           -1.00                 2.00
3           7           5.00                  7.00
3           8           3.00                  10.00
3           9           5.00                  15.00
3           10          -3.00                 12.00
*/

-- large set of sample data (change inputs as needed)
DECLARE
  @num_partitions     AS INT = 10,
  @rows_per_partition AS INT = 10000;

TRUNCATE TABLE dbo.Transactions;

INSERT INTO dbo.Transactions WITH (TABLOCK) (actid, tranid, val)
  SELECT NP.n, RPP.n,
    (ABS(CHECKSUM(NEWID())%2)*2-1) * (1 + ABS(CHECKSUM(NEWID())%5))
  FROM dbo.GetNums(1, @num_partitions) AS NP
    CROSS JOIN dbo.GetNums(1, @rows_per_partition) AS RPP;

-- Set-Based Solution Using Window Functions
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS balance
FROM dbo.Transactions;

-- Set-Based Solution Using Subqueries
SELECT actid, tranid, val,
  (SELECT SUM(T2.val)
   FROM dbo.Transactions AS T2
   WHERE T2.actid = T1.actid
     AND T2.tranid <= T1.tranid) AS balance
FROM dbo.Transactions AS T1;

-- Set-Based Solution Using Joins
SELECT T1.actid, T1.tranid, T1.val,
  SUM(T2.val) AS balance
FROM dbo.Transactions AS T1
  JOIN dbo.Transactions AS T2
    ON T2.actid = T1.actid
   AND T2.tranid <= T1.tranid
GROUP BY T1.actid, T1.tranid, T1.val;

-- Cursor-Based Solution
DECLARE @Result AS TABLE
(
  actid   INT,
  tranid  INT,
  val     MONEY,
  balance MONEY
);

DECLARE
  @actid    AS INT,
  @prvactid AS INT,
  @tranid   AS INT,
  @val      AS MONEY,
  @balance  AS MONEY;

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT actid, tranid, val
  FROM dbo.Transactions
  ORDER BY actid, tranid;

OPEN C

FETCH NEXT FROM C INTO @actid, @tranid, @val;

SELECT @prvactid = @actid, @balance = 0;

WHILE @@fetch_status = 0
BEGIN
  IF @actid <> @prvactid
    SELECT @prvactid = @actid, @balance = 0;

  SET @balance = @balance + @val;

  INSERT INTO @Result VALUES(@actid, @tranid, @val, @balance);
  
  FETCH NEXT FROM C INTO @actid, @tranid, @val;
END

CLOSE C;

DEALLOCATE C;

SELECT * FROM @Result;

-- CLR-Based Solution (C#)
/*
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void AccountBalances()
    {
        using (SqlConnection conn = new SqlConnection("context connection=true;"))
        {
            SqlCommand comm = new SqlCommand();
            comm.Connection = conn;
            comm.CommandText = @"" +
                "SELECT actid, tranid, val " +
                "FROM dbo.Transactions " +
                "ORDER BY actid, tranid;";

            SqlMetaData[] columns = new SqlMetaData[4];
            columns[0] = new SqlMetaData("actid"  , SqlDbType.Int);
            columns[1] = new SqlMetaData("tranid" , SqlDbType.Int);
            columns[2] = new SqlMetaData("val"    , SqlDbType.Money);
            columns[3] = new SqlMetaData("balance", SqlDbType.Money);

            SqlDataRecord record = new SqlDataRecord(columns);

            SqlContext.Pipe.SendResultsStart(record);

            conn.Open();

            SqlDataReader reader = comm.ExecuteReader();

            SqlInt32 prvactid = 0;
            SqlMoney balance = 0;

            while (reader.Read())
            {
                SqlInt32 actid = reader.GetSqlInt32(0);
                SqlMoney val = reader.GetSqlMoney(2);

                if (actid == prvactid)
                {
                    balance += val;
                }
                else
                {
                    balance = val;
                }

                prvactid = actid;

                record.SetSqlInt32(0, reader.GetSqlInt32(0));
                record.SetSqlInt32(1, reader.GetSqlInt32(1));
                record.SetSqlMoney(2, val);
                record.SetSqlMoney(3, balance);

                SqlContext.Pipe.SendResultsRow(record);
            }

            SqlContext.Pipe.SendResultsEnd();
        }
    }
};
*/

CREATE ASSEMBLY AccountBalances 
  FROM 'C:\Temp\AccountBalances\AccountBalances\bin\Debug\AccountBalances.dll';
GO

CREATE PROCEDURE dbo.AccountBalances
AS EXTERNAL NAME AccountBalances.StoredProcedures.AccountBalances;
GO

EXEC dbo.AccountBalances;

-- cleanup
DROP PROCEDURE dbo.AccountBalances;
DROP ASSEMBLY AccountBalances;
GO

-- Nested Iterations, Using Recursive Queries
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY tranid) AS rownum
INTO #Transactions
FROM dbo.Transactions;

CREATE UNIQUE CLUSTERED INDEX idx_rownum_actid ON #Transactions(rownum, actid);

WITH C AS
(
  SELECT 1 AS rownum, actid, tranid, val, val AS sumqty
  FROM #Transactions
  WHERE rownum = 1
  
  UNION ALL
  
  SELECT PRV.rownum + 1, PRV.actid, CUR.tranid, CUR.val, PRV.sumqty + CUR.val
  FROM C AS PRV
    JOIN #Transactions AS CUR
      ON CUR.rownum = PRV.rownum + 1
      AND CUR.actid = PRV.actid
)
SELECT actid, tranid, val, sumqty
FROM C
OPTION (MAXRECURSION 0);

DROP TABLE #Transactions;
GO

-- Nested Iterations, Using Loops
SELECT ROW_NUMBER() OVER(PARTITION BY actid ORDER BY tranid) AS rownum,
  actid, tranid, val, CAST(val AS BIGINT) AS sumqty
INTO #Transactions
FROM dbo.Transactions;

CREATE UNIQUE CLUSTERED INDEX idx_rownum_actid ON #Transactions(rownum, actid);

DECLARE @rownum AS INT;
SET @rownum = 1;

WHILE 1 = 1
BEGIN
  SET @rownum = @rownum + 1;
  
  UPDATE CUR
    SET sumqty = PRV.sumqty + CUR.val
  FROM #Transactions AS CUR
    JOIN #Transactions AS PRV
      ON CUR.rownum = @rownum
     AND PRV.rownum = @rownum - 1
     AND CUR.actid = PRV.actid;

  IF @@rowcount = 0 BREAK;
END

SELECT actid, tranid, val, sumqty
FROM #Transactions;

DROP TABLE #Transactions;
GO

-- Multi-Row UPDATE with Variables (undocumented/unsupported)
CREATE TABLE #Transactions
(
  actid          INT,
  tranid         INT,
  val            MONEY,
  balance        MONEY
);

CREATE CLUSTERED INDEX idx_actid_tranid ON #Transactions(actid, tranid);

INSERT INTO #Transactions WITH (TABLOCK) (actid, tranid, val, balance)
  SELECT actid, tranid, val, 0.00
  FROM dbo.Transactions
  ORDER BY actid, tranid;

DECLARE @prevaccount AS INT, @prevbalance AS MONEY;

UPDATE #Transactions
  SET @prevbalance = balance = CASE
                                 WHEN actid = @prevaccount
                                   THEN @prevbalance + val
                                 ELSE val
                               END,
      @prevaccount = actid
FROM #Transactions WITH(INDEX(1), TABLOCKX)
OPTION (MAXDOP 1);

SELECT * FROM #Transactions;

DROP TABLE #Transactions;
GO

----------------------------------------------------------------------
-- Max Concurrent Sessions
----------------------------------------------------------------------

-- Creating and Populating Sessions
SET NOCOUNT ON;
USE TSQL2012;

IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL DROP TABLE dbo.Sessions;

CREATE TABLE dbo.Sessions
(
  keycol    INT         NOT NULL,
  app       VARCHAR(10) NOT NULL,
  usr       VARCHAR(10) NOT NULL,
  host      VARCHAR(10) NOT NULL,
  starttime DATETIME    NOT NULL,
  endtime   DATETIME    NOT NULL,
  CONSTRAINT PK_Sessions PRIMARY KEY(keycol),
  CHECK(endtime > starttime)
);
GO

CREATE UNIQUE INDEX idx_nc_app_st_et ON dbo.Sessions(app, starttime, keycol) INCLUDE(endtime);
CREATE UNIQUE INDEX idx_nc_app_et_st ON dbo.Sessions(app, endtime, keycol) INCLUDE(starttime);

-- small set of sample data
TRUNCATE TABLE dbo.Sessions;

INSERT INTO dbo.Sessions(keycol, app, usr, host, starttime, endtime) VALUES
  (2,  'app1', 'user1', 'host1', '20120212 08:30', '20120212 10:30'),
  (3,  'app1', 'user2', 'host1', '20120212 08:30', '20120212 08:45'),
  (5,  'app1', 'user3', 'host2', '20120212 09:00', '20120212 09:30'),
  (7,  'app1', 'user4', 'host2', '20120212 09:15', '20120212 10:30'),
  (11, 'app1', 'user5', 'host3', '20120212 09:15', '20120212 09:30'),
  (13, 'app1', 'user6', 'host3', '20120212 10:30', '20120212 14:30'),
  (17, 'app1', 'user7', 'host4', '20120212 10:45', '20120212 11:30'),
  (19, 'app1', 'user8', 'host4', '20120212 11:00', '20120212 12:30'),
  (23, 'app2', 'user8', 'host1', '20120212 08:30', '20120212 08:45'),
  (29, 'app2', 'user7', 'host1', '20120212 09:00', '20120212 09:30'),
  (31, 'app2', 'user6', 'host2', '20120212 11:45', '20120212 12:00'),
  (37, 'app2', 'user5', 'host2', '20120212 12:30', '20120212 14:00'),
  (41, 'app2', 'user4', 'host3', '20120212 12:45', '20120212 13:30'),
  (43, 'app2', 'user3', 'host3', '20120212 13:00', '20120212 14:00'),
  (47, 'app2', 'user2', 'host4', '20120212 14:00', '20120212 16:30'),
  (53, 'app2', 'user1', 'host4', '20120212 15:30', '20120212 17:00');
GO

/*
app        mx
---------- -----------
app1       3
app2       4
*/

-- large set of sample data
TRUNCATE TABLE dbo.Sessions;

DECLARE 
  @numrows AS INT = 100000, -- total number of rows 
  @numapps AS INT = 10;     -- number of applications

INSERT INTO dbo.Sessions WITH(TABLOCK)
    (keycol, app, usr, host, starttime, endtime)
  SELECT
    ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS keycol, 
    D.*,
    DATEADD(
      second,
      1 + ABS(CHECKSUM(NEWID())) % (20*60),
      starttime) AS endtime
  FROM
  (
    SELECT 
      'app' + CAST(1 + ABS(CHECKSUM(NEWID())) % @numapps AS VARCHAR(10)) AS app,
      'user1' AS usr,
      'host1' AS host,
      DATEADD(
        second,
        1 + ABS(CHECKSUM(NEWID())) % (30*24*60*60),
        '20120101') AS starttime
    FROM dbo.GetNums(1, @numrows) AS Nums
  ) AS D;
GO

-- Traditional set-based solution
WITH TimePoints AS 
(
  SELECT app, starttime AS ts FROM dbo.Sessions
),
Counts AS
(
  SELECT app, ts,
    (SELECT COUNT(*)
     FROM dbo.Sessions AS S
     WHERE P.app = S.app
       AND P.ts >= S.starttime
       AND P.ts < S.endtime) AS concurrent
  FROM TimePoints AS P
)      
SELECT app, MAX(concurrent) AS mx
FROM Counts
GROUP BY app;

-- query used by cursor solution
SELECT app, starttime AS ts, +1 AS type
FROM dbo.Sessions
  
UNION ALL
  
SELECT app, endtime, -1
FROM dbo.Sessions
  
ORDER BY app, ts, type;

/*
app        ts                      type
---------- ----------------------- -----------
app1       2012-02-12 08:30:00.000 1
app1       2012-02-12 08:30:00.000 1
app1       2012-02-12 08:45:00.000 -1
app1       2012-02-12 09:00:00.000 1
app1       2012-02-12 09:15:00.000 1
app1       2012-02-12 09:15:00.000 1
app1       2012-02-12 09:30:00.000 -1
app1       2012-02-12 09:30:00.000 -1
app1       2012-02-12 10:30:00.000 -1
app1       2012-02-12 10:30:00.000 -1
...
*/

-- cursor-based solution
DECLARE
  @app AS varchar(10), 
  @prevapp AS varchar (10),
  @ts AS datetime,
  @type AS int,
  @concurrent AS int, 
  @mx AS int;

DECLARE @AppsMx TABLE
(
  app varchar (10) NOT NULL PRIMARY KEY,
  mx int NOT NULL
);

DECLARE sessions_cur CURSOR FAST_FORWARD FOR
  SELECT app, starttime AS ts, +1 AS type
  FROM dbo.Sessions
  
  UNION ALL
  
  SELECT app, endtime, -1
  FROM dbo.Sessions
  
  ORDER BY app, ts, type;

OPEN sessions_cur;

FETCH NEXT FROM sessions_cur
  INTO @app, @ts, @type;

SET @prevapp = @app;
SET @concurrent = 0;
SET @mx = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @app <> @prevapp
  BEGIN
    INSERT INTO @AppsMx VALUES(@prevapp, @mx);
    SET @concurrent = 0;
    SET @mx = 0;
    SET @prevapp = @app;
  END

  SET @concurrent = @concurrent + @type;
  IF @concurrent > @mx SET @mx = @concurrent;
  
  FETCH NEXT FROM sessions_cur
    INTO @app, @ts, @type;
END

IF @prevapp IS NOT NULL
  INSERT INTO @AppsMx VALUES(@prevapp, @mx);

CLOSE sessions_cur;

DEALLOCATE sessions_cur;

SELECT * FROM @AppsMx;
GO

-- solution using window aggregate function
WITH C1 AS
(
  SELECT app, starttime AS ts, +1 AS type
  FROM dbo.Sessions

  UNION ALL

  SELECT app, endtime, -1
  FROM dbo.Sessions
),
C2 AS
(
  SELECT *,
    SUM(type) OVER(PARTITION BY app ORDER BY ts, type
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cnt
  FROM C1
)
SELECT app, MAX(cnt) AS mx
FROM C2
GROUP BY app;

-- solution using ROW_NUMBER
WITH C1 AS
(
  SELECT app, starttime AS ts, +1 AS type, keycol,
    ROW_NUMBER() OVER(PARTITION BY app ORDER BY starttime, keycol) AS start_ordinal
  FROM dbo.Sessions

  UNION ALL

  SELECT app, endtime, -1, keycol, NULL
  FROM dbo.Sessions
),
C2 AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY app ORDER BY ts, type, keycol) AS start_or_end_ordinal
  FROM C1
)
SELECT app, MAX(start_ordinal - (start_or_end_ordinal - start_ordinal)) AS mx
FROM C2
GROUP BY app;

----------------------------------------------------------------------
-- Packing Intervals
----------------------------------------------------------------------

-- code to create and populate Sessions and Users tables
SET NOCOUNT ON;
USE TSQL2012;

IF OBJECT_ID('dbo.Sessions') IS NOT NULL DROP TABLE dbo.Sessions;
IF OBJECT_ID('dbo.Users') IS NOT NULL DROP TABLE dbo.Users;

CREATE TABLE dbo.Users
(
  username  VARCHAR(14)  NOT NULL,
  CONSTRAINT PK_Users PRIMARY KEY(username)
);
GO

INSERT INTO dbo.Users(username) VALUES('User1'), ('User2'), ('User3');

CREATE TABLE dbo.Sessions
(
  id        INT          NOT NULL IDENTITY(1, 1),
  username  VARCHAR(14)  NOT NULL,
  starttime DATETIME2(3) NOT NULL,
  endtime   DATETIME2(3) NOT NULL,
  CONSTRAINT PK_Sessions PRIMARY KEY(id),
  CONSTRAINT CHK_endtime_gteq_starttime
    CHECK (endtime >= starttime)
);
GO

INSERT INTO dbo.Sessions(username, starttime, endtime) VALUES
  ('User1', '20121201 08:00:00.000', '20121201 08:30:00.000'),
  ('User1', '20121201 08:30:00.000', '20121201 09:00:00.000'),
  ('User1', '20121201 09:00:00.000', '20121201 09:30:00.000'),
  ('User1', '20121201 10:00:00.000', '20121201 11:00:00.000'),
  ('User1', '20121201 10:30:00.000', '20121201 12:00:00.000'),
  ('User1', '20121201 11:30:00.000', '20121201 12:30:00.000'),
  ('User2', '20121201 08:00:00.000', '20121201 10:30:00.000'),
  ('User2', '20121201 08:30:00.000', '20121201 10:00:00.000'),
  ('User2', '20121201 09:00:00.000', '20121201 09:30:00.000'),
  ('User2', '20121201 11:00:00.000', '20121201 11:30:00.000'),
  ('User2', '20121201 11:32:00.000', '20121201 12:00:00.000'),
  ('User2', '20121201 12:04:00.000', '20121201 12:30:00.000'),
  ('User3', '20121201 08:00:00.000', '20121201 09:00:00.000'),
  ('User3', '20121201 08:00:00.000', '20121201 08:30:00.000'),
  ('User3', '20121201 08:30:00.000', '20121201 09:00:00.000'),
  ('User3', '20121201 09:30:00.000', '20121201 09:30:00.000');
GO

-- desired results
/*
username  starttime               endtime
--------- ----------------------- -----------------------
User1     2012-12-01 08:00:00.000 2012-12-01 09:30:00.000
User1     2012-12-01 10:00:00.000 2012-12-01 12:30:00.000
User2     2012-12-01 08:00:00.000 2012-12-01 10:30:00.000
User2     2012-12-01 11:00:00.000 2012-12-01 11:30:00.000
User2     2012-12-01 11:32:00.000 2012-12-01 12:00:00.000
User2     2012-12-01 12:04:00.000 2012-12-01 12:30:00.000
User3     2012-12-01 08:00:00.000 2012-12-01 09:00:00.000
User3     2012-12-01 09:30:00.000 2012-12-01 09:30:00.000
*/

-- Large Set of Sample Data
-- 2,000 users, 5,000,000 intervals
DECLARE 
  @num_users          AS INT          = 2000,
  @intervals_per_user AS INT          = 2500,
  @start_period       AS DATETIME2(3) = '20120101',
  @end_period         AS DATETIME2(3) = '20120107',
  @max_duration_in_ms AS INT  = 3600000; -- 60 minutes
  
TRUNCATE TABLE dbo.Sessions;
TRUNCATE TABLE dbo.Users;

INSERT INTO dbo.Users(username)
  SELECT 'User' + RIGHT('000000000' + CAST(U.n AS VARCHAR(10)), 10) AS username
  FROM dbo.GetNums(1, @num_users) AS U;

WITH C AS
(
  SELECT 'User' + RIGHT('000000000' + CAST(U.n AS VARCHAR(10)), 10) AS username,
      DATEADD(ms, ABS(CHECKSUM(NEWID())) % 86400000,
        DATEADD(day, ABS(CHECKSUM(NEWID())) % DATEDIFF(day, @start_period, @end_period), @start_period)) AS starttime
  FROM dbo.GetNums(1, @num_users) AS U
    CROSS JOIN dbo.GetNums(1, @intervals_per_user) AS I
)
INSERT INTO dbo.Sessions WITH (TABLOCK) (username, starttime, endtime)
  SELECT username, starttime,
    DATEADD(ms, ABS(CHECKSUM(NEWID())) % (@max_duration_in_ms + 1), starttime) AS endtime
  FROM C;
GO

-- indexes for traditional solution
/*
CREATE INDEX idx_user_start_end ON dbo.Sessions(username, starttime, endtime);
CREATE INDEX idx_user_end_start ON dbo.Sessions(username, endtime, starttime);
*/

-- traditional solution
-- run time: several hours (need to test again in SQL Server 2012)

-- traditional solution
WITH StartTimes AS
(
  SELECT DISTINCT username, starttime
  FROM dbo.Sessions AS S1
  WHERE NOT EXISTS
    (SELECT * FROM dbo.Sessions AS S2
     WHERE S2.username = S1.username
       AND S2.starttime < S1.starttime
       AND S2.endtime >= S1.starttime)
),
EndTimes AS
(
  SELECT DISTINCT username, endtime
  FROM dbo.Sessions AS S1
  WHERE NOT EXISTS
    (SELECT * FROM dbo.Sessions AS S2
     WHERE S2.username = S1.username
       AND S2.endtime > S1.endtime
       AND S2.starttime <= S1.endtime)
)
SELECT username, starttime,
  (SELECT MIN(endtime) FROM EndTimes AS E
   WHERE E.username = S.username
     AND endtime >= starttime) AS endtime
FROM StartTimes AS S;

-- cleanup indexes for traditional solution
/*
DROP INDEX idx_user_start_end ON dbo.Sessions;
DROP INDEX idx_user_end_start ON dbo.Sessions;
*/

-- indexes for solutions based on window functions
CREATE UNIQUE INDEX idx_user_start_id ON dbo.Sessions(username, starttime, id);
CREATE UNIQUE INDEX idx_user_end_id ON dbo.Sessions(username, endtime, id);

-- Listing 5-1: Packing Intervals Using Row Numbers
-- run time: 47 seconds

WITH C1 AS
-- let e = end ordinals, let s = start ordinals
(
  SELECT id, username, starttime AS ts, +1 AS type, NULL AS e,
    ROW_NUMBER() OVER(PARTITION BY username ORDER BY starttime, id) AS s
  FROM dbo.Sessions

  UNION ALL

  SELECT id, username, endtime AS ts, -1 AS type, 
    ROW_NUMBER() OVER(PARTITION BY username ORDER BY endtime, id) AS e,
    NULL AS s
  FROM dbo.Sessions
),
C2 AS
-- let se = start or end ordinal, namely, how many events (start or end) happened so far
(
  SELECT C1.*, ROW_NUMBER() OVER(PARTITION BY username ORDER BY ts, type DESC, id) AS se
  FROM C1
),
C3 AS
-- For start events, the expression s - (se - s) - 1 represents how many sessions were active
-- just before the current (hence - 1)
--
-- For end events, the expression (se - e) - e represents how many sessions are active
-- right after this one
--
-- The above two expressions are 0 exactly when a group of packed intervals 
-- either starts or ends, respectively
--
-- After filtering only events when a group of packed intervals either starts or ends,
-- group each pair of adjacent start/end events
(
  SELECT username, ts, 
    FLOOR((ROW_NUMBER() OVER(PARTITION BY username ORDER BY ts) - 1) / 2 + 1) AS grpnum
  FROM C2
  WHERE COALESCE(s - (se - s) - 1, (se - e) - e) = 0
)
SELECT username, MIN(ts) AS starttime, max(ts) AS endtime
FROM C3
GROUP BY username, grpnum;

-- solution using row numbers and APPLY to exploit parallelism

-- inline table function encapsulating logic from solution in listing 2 for single user
IF OBJECT_ID('dbo.UserIntervals', 'IF') IS NOT NULL DROP FUNCTION dbo.UserIntervals;
GO

CREATE FUNCTION dbo.UserIntervals(@user AS VARCHAR(14)) RETURNS TABLE
AS
RETURN
  WITH C1 AS
  (
    SELECT id, starttime AS ts, +1 AS type, NULL AS e,
      ROW_NUMBER() OVER(ORDER BY starttime, id) AS s
    FROM dbo.Sessions
    WHERE username = @user

    UNION ALL

    SELECT id, endtime AS ts, -1 AS type, 
      ROW_NUMBER() OVER(ORDER BY endtime, id) AS e,
      NULL AS s
    FROM dbo.Sessions
    WHERE username = @user
  ),
  C2 AS
  (
    SELECT C1.*, ROW_NUMBER() OVER(ORDER BY ts, type DESC, id) AS se
    FROM C1
  ),
  C3 AS
  (
    SELECT ts, 
      FLOOR((ROW_NUMBER() OVER(ORDER BY ts) - 1) / 2 + 1) AS grpnum
    FROM C2
    WHERE COALESCE(s - (se - s) - 1, (se - e) - e) = 0
  )
  SELECT MIN(ts) AS starttime, max(ts) AS endtime
  FROM C3
  GROUP BY grpnum;
GO

-- Solution Using APPLY and Row Numbers
-- run time: 6 seconds
SELECT U.username, A.starttime, A.endtime
FROM dbo.Users AS U
  CROSS APPLY dbo.UserIntervals(U.username) AS A;

-- Listing 5-2: Solution Using Window Aggregate
-- run time: 83 seconds
WITH C1 AS
(
  SELECT username, starttime AS ts, +1 AS type, 1 AS sub
  FROM dbo.Sessions

  UNION ALL

  SELECT username, endtime AS ts, -1 AS type, 0 AS sub
  FROM dbo.Sessions
),
C2 AS
(
  SELECT C1.*,
    SUM(type) OVER(PARTITION BY username ORDER BY ts, type DESC
                   ROWS BETWEEN UNBOUNDED PRECEDING
                            AND CURRENT ROW) - sub AS cnt
  FROM C1
),
C3 AS
(
  SELECT username, ts, 
    FLOOR((ROW_NUMBER() OVER(PARTITION BY username ORDER BY ts) - 1) / 2 + 1) AS grpnum
  FROM C2
  WHERE cnt = 0
)
SELECT username, MIN(ts) AS starttime, max(ts) AS endtime
FROM C3
GROUP BY username, grpnum;

-- inline table function encapsulating logic from solution in listing 1 for single user
IF OBJECT_ID('dbo.UserIntervals', 'IF') IS NOT NULL DROP FUNCTION dbo.UserIntervals;
GO

CREATE FUNCTION dbo.UserIntervals(@user AS VARCHAR(14)) RETURNS TABLE
AS
RETURN
  WITH C1 AS
  (
    SELECT starttime AS ts, +1 AS type, 1 AS sub
    FROM dbo.Sessions
    WHERE username = @user

    UNION ALL

    SELECT endtime AS ts, -1 AS type, 0 AS sub
    FROM dbo.Sessions
    WHERE username = @user
  ),
  C2 AS
  (
    SELECT C1.*,
      SUM(type) OVER(ORDER BY ts, type DESC
                     ROWS BETWEEN UNBOUNDED PRECEDING
                              AND CURRENT ROW) - sub AS cnt
    FROM C1
  ),
  C3 AS
  (
    SELECT ts, 
      FLOOR((ROW_NUMBER() OVER(ORDER BY ts) - 1) / 2 + 1) AS grpnum
    FROM C2
    WHERE cnt = 0
  )
  SELECT MIN(ts) AS starttime, max(ts) AS endtime
  FROM C3
  GROUP BY grpnum;
GO

-- Solution Using APPLY and Window Aggregate
-- run time: 13 seconds
SELECT U.username, A.starttime, A.endtime
FROM dbo.Users AS U
  CROSS APPLY dbo.UserIntervals(U.username) AS A;

----------------------------------------------------------------------
-- Gaps and Islands
----------------------------------------------------------------------

-- sample data for gaps and islands problems
SET NOCOUNT ON;
USE TSQL2012;

-- dbo.T1 (numeric sequence with unique values, interval: 1)
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  col1 INT NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY
);
GO

INSERT INTO dbo.T1(col1)
  VALUES(2),(3),(7),(8),(9),(11),(15),(16),(17),(28);

-- dbo.T2 (temporal sequence with unique values, interval: 1 day)
IF OBJECT_ID('dbo.T2', 'U') IS NOT NULL DROP TABLE dbo.T2;

CREATE TABLE dbo.T2
(
  col1 DATE NOT NULL
    CONSTRAINT PK_T2 PRIMARY KEY
);
GO

INSERT INTO dbo.T2(col1) VALUES
  ('20120202'),
  ('20120203'),
  ('20120207'),
  ('20120208'),
  ('20120209'),
  ('20120211'),
  ('20120215'),
  ('20120216'),
  ('20120217'),
  ('20120228');

-- Gaps

-- desired results for numeric sequence
/*
rangestart  rangeend
----------- -----------
4           6
10          10
12          14
18          27
*/

-- desired results for temporal sequence
/*
rangestart rangeend
---------- ----------
2012-02-04 2012-02-06
2012-02-10 2012-02-10
2012-02-12 2012-02-14
2012-02-18 2012-02-27
*/

-- Numeric
WITH C AS
(
  SELECT col1 AS cur, LEAD(col1) OVER(ORDER BY col1) AS nxt
  FROM dbo.T1
)
SELECT cur + 1 AS rangestart, nxt - 1 AS rangeend
FROM C
WHERE nxt - cur > 1;

-- Temporal
WITH C AS
(
  SELECT col1 AS cur, LEAD(col1) OVER(ORDER BY col1) AS nxt
  FROM dbo.T2
)
SELECT DATEADD(day, 1, cur) AS rangestart, DATEADD(day, -1, nxt) rangeend
FROM C
WHERE DATEDIFF(day, cur, nxt) > 1;

-- Islands

-- desired results for numeric sequence
/*
start_range end_range
----------- -----------
2           3
7           9
11          11
15          17
28          28
*/

-- desired results for temporal sequence
/*
start_range end_range
----------- ----------
2012-02-02  2012-02-03
2012-02-07  2012-02-09
2012-02-11  2012-02-11
2012-02-15  2012-02-17
2012-02-28  2012-02-28
*/

-- Numeric

-- diff between col1 and dense rank
SELECT col1,
  DENSE_RANK() OVER(ORDER BY col1) AS drnk,
  col1 - DENSE_RANK() OVER(ORDER BY col1) AS diff
FROM dbo.T1;

/*
col1  drnk  diff
----- ----- -----
2     1     1
3     2     1
7     3     4
8     4     4
9     5     4
11    6     5
15    7     8
16    8     8
17    9     8
28    10    18
*/

WITH C AS
(
  SELECT col1, col1 - DENSE_RANK() OVER(ORDER BY col1) AS grp
  FROM dbo.T1
)
SELECT MIN(col1) AS start_range, MAX(col1) AS end_range
FROM C
GROUP BY grp;

-- Temporal
WITH C AS
(
  SELECT col1, DATEADD(day, -1 * DENSE_RANK() OVER(ORDER BY col1), col1) AS grp
  FROM dbo.T2
)
SELECT MIN(col1) AS start_range, MAX(col1) AS end_range
FROM C
GROUP BY grp;

-- example for practical use

-- packing date intervals
IF OBJECT_ID('dbo.Intervals', 'U') IS NOT NULL DROP TABLE dbo.Intervals;

CREATE TABLE dbo.Intervals
(
  id        INT  NOT NULL,
  startdate DATE NOT NULL,
  enddate   DATE NOT NULL
);

INSERT INTO dbo.Intervals(id, startdate, enddate) VALUES
  (1, '20120212', '20120220'),
  (2, '20120214', '20120312'),
  (3, '20120124', '20120201');

-- desired results
/*
rangestart rangeend
---------- ----------
2012-01-24 2012-02-01
2012-02-12 2012-03-12
*/

-- solution  
DECLARE
  @from AS DATE = '20120101',
  @to   AS DATE = '20121231';

WITH Dates AS
(
  SELECT DATEADD(day, n-1, @from) AS dt
  FROM dbo.GetNums(1, DATEDIFF(day, @from, @to) + 1) AS Nums
),
Groups AS
(
  SELECT D.dt, 
    DATEADD(day, -1 * DENSE_RANK() OVER(ORDER BY D.dt), D.dt) AS grp
  FROM dbo.Intervals AS I
    JOIN Dates AS D
	  ON D.dt BETWEEN I.startdate AND I.enddate
)
SELECT MIN(dt) AS rangestart, MAX(dt) AS rangeend
FROM Groups
GROUP BY grp;

-- ignore gaps of up to 2

-- desired results
/*
rangestart  rangeend
----------- -----------
2           3
7           11
15          17
28          28
*/

WITH C1 AS
(
  SELECT col1,
    CASE WHEN col1 - LAG(col1) OVER(ORDER BY col1)  <= 2 THEN 0 ELSE 1 END AS isstart, 
    CASE WHEN LEAD(col1) OVER(ORDER BY col1) - col1 <= 2 THEN 0 ELSE 1 END AS isend
  FROM dbo.T1
),
C2 AS
(
  SELECT col1 AS rangestart, LEAD(col1, 1-isend) OVER(ORDER BY col1) AS rangeend, isstart
  FROM C1
  WHERE isstart = 1 OR isend = 1
)
SELECT rangestart, rangeend
FROM C2
WHERE isstart = 1;

-- variation of islands problem
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  id  INT         NOT NULL PRIMARY KEY,
  val VARCHAR(10) NOT NULL
);
GO

INSERT INTO dbo.T1(id, val) VALUES
  (2, 'a'),
  (3, 'a'),
  (5, 'a'),
  (7, 'b'),
  (11, 'b'),
  (13, 'a'),
  (17, 'a'),
  (19, 'a'),
  (23, 'c'),
  (29, 'c'),
  (31, 'a'),
  (37, 'a'),
  (41, 'a'),
  (43, 'a'),
  (47, 'c'),
  (53, 'c'),
  (59, 'c');

-- desired results
/*
mn          mx          val
----------- ----------- ----------
2           5           a
7           11          b
13          19          a
23          29          c
31          43          a
47          59          c
*/

-- computing island identifier per val
SELECT id, val,
  ROW_NUMBER() OVER(ORDER BY id)
    - ROW_NUMBER() OVER(ORDER BY val, id) AS grp
FROM dbo.T1;

/*
id          val        grp
----------- ---------- --------------------
2           a          0
3           a          0
5           a          0
13          a          2
17          a          2
19          a          2
31          a          4
37          a          4
41          a          4
43          a          4
7           b          -7
11          b          -7
23          c          -4
29          c          -4
47          c          0
53          c          0
59          c          0
*/

-- solution
WITH C AS
(
  SELECT id, val,
    ROW_NUMBER() OVER(ORDER BY id)
      - ROW_NUMBER() OVER(ORDER BY val, id) AS grp
  FROM dbo.T1
)
SELECT MIN(id) AS mn, MAX(id) AS mx, val
FROM C
GROUP BY val, grp
ORDER BY mn;

----------------------------------------------------------------------
-- Median
----------------------------------------------------------------------

-- desired results
/*
testid     median
---------- -------
Test ABC   75
Test XYZ   77.5
*/

-- solution in SQL Server 2012
WITH C AS
(
  SELECT testid,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY (SELECT NULL)) AS rownum,
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS median
  FROM Stats.Scores
)
SELECT testid, median
FROM C
WHERE rownum = 1;

-- pre-SQL Server 2012 solution 1
WITH C AS
(
  SELECT testid, score,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score) AS pos,
    COUNT(*) OVER(PARTITION BY testid) AS cnt
  FROM Stats.Scores
)
SELECT testid, AVG(1. * score) AS median
FROM C
WHERE pos IN( (cnt + 1) / 2, (cnt + 2) / 2 )
GROUP BY testid;

-- pre-SQL Server 2012 solution 2

-- step 1: compute row numbers
SELECT testid, score,
  ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score, studentid) AS rna,
  ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score DESC, studentid DESC) AS rnd
FROM Stats.Scores;

/*
testid     score rna  rnd
---------- ----- ---- ----
Test ABC   95    9    1
Test ABC   95    8    2
Test ABC   80    7    3
Test ABC   80    6    4
Test ABC   75    5    5
Test ABC   65    4    6
Test ABC   55    3    7
Test ABC   55    2    8
Test ABC   50    1    9
Test XYZ   95    10   1
Test XYZ   95    9    2
Test XYZ   95    8    3
Test XYZ   80    7    4
Test XYZ   80    6    5
Test XYZ   75    5    6
Test XYZ   65    4    7
Test XYZ   55    3    8
Test XYZ   55    2    9
Test XYZ   50    1    10
*/

-- complete solution
WITH C AS
(
  SELECT testid, score,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score, studentid) AS rna,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score DESC, studentid DESC) AS rnd
  FROM Stats.Scores
)
SELECT testid, AVG(1. * score) AS median
FROM C
WHERE ABS(rna - rnd) <= 1
GROUP BY testid;

----------------------------------------------------------------------
-- Conditional Aggregate
----------------------------------------------------------------------

USE TSQL2012;

IF OBJECT_ID('dbo.T1') IS NOT NULL DROP TABLE dbo.T1;
GO

CREATE TABLE dbo.T1
(
  ordcol  INT NOT NULL PRIMARY KEY,
  datacol INT NOT NULL
);

INSERT INTO dbo.T1 VALUES
  (1,   10),
  (4,  -15),
  (5,    5),
  (6,  -10),
  (8,  -15),
  (10,  20),
  (17,  10),
  (18, -10),
  (20, -30),
  (31,  20); 

-- calculate a non-negative sum of datacol based on ordcol ordering (courtacy of gordon linoff)
-- unsupported

-- desired results
/*
ordcol      datacol     nonnegativesum
----------- ----------- --------------
1           10          10
4           -15         0
5           5           5
6           -10         0
8           -15         0
10          20          20
17          10          30
18          -10         20
20          -30         0
31          20          20
*/

WITH C1 AS
(
  SELECT ordcol, datacol,
    SUM(datacol) OVER (ORDER BY ordcol
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS partsum
  FROM dbo.T1
),
C2 AS
(
  SELECT *,
    MIN(partsum) OVER (ORDER BY ordcol
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as adjust
  FROM C1
)
SELECT *,
  partsum - CASE WHEN adjust < 0 THEN adjust ELSE 0 END
    AS nonnegativesum
FROM C2;

/*
ordcol      datacol     partsum     adjust      nonnegativesum
----------- ----------- ----------- ----------- --------------
1           10          10          10          10
4           -15         -5          -5          0
5           5           0           -5          5
6           -10         -10         -10         0
8           -15         -25         -25         0
10          20          -5          -25         20
17          10          5           -25         30
18          -10         -5          -25         20
20          -30         -35         -35         0
31          20          -15         -35         20
*/

----------------------------------------------------------------------
-- Used with Hierarchical Data
----------------------------------------------------------------------

-- ddl & sample data for dbo.employees
USE TSQL2012;

IF OBJECT_ID('dbo.Employees') IS NOT NULL DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL PRIMARY KEY,
  mgrid   INT         NULL     REFERENCES dbo.Employees,
  empname VARCHAR(25) NOT NULL,
  salary  MONEY       NOT NULL,
  CHECK (empid <> mgrid)
);

INSERT INTO dbo.Employees(empid, mgrid, empname, salary) VALUES
  (1,  NULL, 'David'  , $10000.00),
  (2,  1,    'Eitan'  ,  $7000.00),
  (3,  1,    'Ina'    ,  $7500.00),
  (4,  2,    'Seraph' ,  $5000.00),
  (5,  2,    'Jiru'   ,  $5500.00),
  (6,  2,    'Steve'  ,  $4500.00),
  (7,  3,    'Aaron'  ,  $5000.00),
  (8,  5,    'Lilach' ,  $3500.00),
  (9,  7,    'Rita'   ,  $3000.00),
  (10, 5,    'Sean'   ,  $3000.00),
  (11, 7,    'Gabriel',  $3000.00),
  (12, 9,    'Emilia' ,  $2000.00),
  (13, 9,    'Michael',  $2000.00),
  (14, 9,    'Didi'   ,  $1500.00);

CREATE UNIQUE INDEX idx_unc_mgrid_empid ON dbo.Employees(mgrid, empid);
GO

-- sorting hierarchy by empname

-- row numbers ordered by empname
WITH EmpsRN AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY mgrid ORDER BY empname, empid) AS n
  FROM dbo.Employees
)
SELECT * FROM EmpsRN;

/*
empid  mgrid  empname  salary    n
------ ------ -------- --------- ---
1      NULL   David    10000.00  1
2      1      Eitan    7000.00   1
3      1      Ina      7500.00   2
5      2      Jiru     5500.00   1
4      2      Seraph   5000.00   2
6      2      Steve    4500.00   3
7      3      Aaron    5000.00   1
8      5      Lilach   3500.00   1
10     5      Sean     3000.00   2
11     7      Gabriel  3000.00   1
9      7      Rita     3000.00   2
14     9      Didi     1500.00   1
12     9      Emilia   2000.00   2
13     9      Michael  2000.00   3
*/

-- computing sort path and level
WITH EmpsRN AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY mgrid ORDER BY empname, empid) AS n
  FROM dbo.Employees
),
EmpsPath
AS
(
  SELECT empid, empname, salary, 0 AS lvl,
    CAST(0x AS VARBINARY(MAX)) AS sortpath
  FROM dbo.Employees
  WHERE mgrid IS NULL

  UNION ALL

  SELECT C.empid, C.empname, C.salary, P.lvl + 1, P.sortpath + CAST(n AS BINARY(2))
  FROM EmpsPath AS P
    JOIN EmpsRN AS C
      ON C.mgrid = P.empid
)
SELECT *
FROM EmpsPath;

/*
empid  empname  salary    lvl  sortpath
------ -------- --------- ---- -------------------
1      David    10000.00  0    0x
2      Eitan    7000.00   1    0x0001
3      Ina      7500.00   1    0x0002
7      Aaron    5000.00   2    0x00020001
11     Gabriel  3000.00   3    0x000200010001
9      Rita     3000.00   3    0x000200010002
14     Didi     1500.00   4    0x0002000100020001
12     Emilia   2000.00   4    0x0002000100020002
13     Michael  2000.00   4    0x0002000100020003
5      Jiru     5500.00   2    0x00010001
4      Seraph   5000.00   2    0x00010002
6      Steve    4500.00   2    0x00010003
8      Lilach   3500.00   3    0x000100010001
10     Sean     3000.00   3    0x000100010002
*/

-- complete solution
WITH EmpsRN AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY mgrid ORDER BY empname, empid) AS n
  FROM dbo.Employees
),
EmpsPath
AS
(
  SELECT empid, empname, salary, 0 AS lvl,
    CAST(0x AS VARBINARY(MAX)) AS sortpath
  FROM dbo.Employees
  WHERE mgrid IS NULL

  UNION ALL

  SELECT C.empid, C.empname, C.salary, P.lvl + 1, P.sortpath + CAST(n AS BINARY(2))
  FROM EmpsPath AS P
    JOIN EmpsRN AS C
      ON C.mgrid = P.empid
)
SELECT empid, salary, REPLICATE(' | ', lvl) + empname AS empname
FROM EmpsPath
ORDER BY sortpath;

/*
empid       salary                empname
----------- --------------------- --------------------
1           10000.00              David
2           7000.00                | Eitan
5           5500.00                |  | Jiru
8           3500.00                |  |  | Lilach
10          3000.00                |  |  | Sean
4           5000.00                |  | Seraph
6           4500.00                |  | Steve
3           7500.00                | Ina
7           5000.00                |  | Aaron
11          3000.00                |  |  | Gabriel
9           3000.00                |  |  | Rita
14          1500.00                |  |  |  | Didi
12          2000.00                |  |  |  | Emilia
13          2000.00                |  |  |  | Michael
*/

-- sorting hierarchy by salary
WITH EmpsRN AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY mgrid ORDER BY salary, empid) AS n
  FROM dbo.Employees
),
EmpsPath
AS
(
  SELECT empid, empname, salary, 0 AS lvl,
    CAST(0x AS VARBINARY(MAX)) AS sortpath
  FROM dbo.Employees
  WHERE mgrid IS NULL

  UNION ALL

  SELECT C.empid, C.empname, C.salary, P.lvl + 1, P.sortpath + CAST(n AS BINARY(2))
  FROM EmpsPath AS P
    JOIN EmpsRN AS C
      ON C.mgrid = P.empid
)
SELECT empid, salary, REPLICATE(' | ', lvl) + empname AS empname
FROM EmpsPath
ORDER BY sortpath;

/*
empid       salary                empname
----------- --------------------- --------------------
1           10000.00              David
2           7000.00                | Eitan
6           4500.00                |  | Steve
4           5000.00                |  | Seraph
5           5500.00                |  | Jiru
10          3000.00                |  |  | Sean
8           3500.00                |  |  | Lilach
3           7500.00                | Ina
7           5000.00                |  | Aaron
9           3000.00                |  |  | Rita
14          1500.00                |  |  |  | Didi
12          2000.00                |  |  |  | Emilia
13          2000.00                |  |  |  | Michael
11          3000.00                |  |  | Gabriel
*/
