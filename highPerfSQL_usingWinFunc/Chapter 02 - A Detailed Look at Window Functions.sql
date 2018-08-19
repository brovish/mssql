----------------------------------------------------------------------
-- High-Performance T-SQL: Set-based Solutions using Microsoft SQL Server 2012 Window Functions
-- Chapter 02 - A Detailed Look at Window Functions
-- © Itzik Ben-Gan
----------------------------------------------------------------------

SET NOCOUNT ON;
USE TSQL2012;

----------------------------------------------------------------------
-- Window Functions Breakdown
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Window Aggregate Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Window Aggregate Functions, Described
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Partitioning
----------------------------------------------------------------------

-- default and explicit partitioning
USE TSQL2012;

SELECT orderid, custid, val,
  SUM(val) OVER() AS sumall,
  SUM(val) OVER(PARTITION BY custid) AS sumcust
FROM Sales.OrderValues AS O1;

/*
orderid  custid  val     sumall      sumcust
-------- ------- ------- ----------- --------
10643    1       814.50  1265793.22  4273.00
10692    1       878.00  1265793.22  4273.00
10702    1       330.00  1265793.22  4273.00
10835    1       845.80  1265793.22  4273.00
10952    1       471.20  1265793.22  4273.00
11011    1       933.50  1265793.22  4273.00
10926    2       514.40  1265793.22  1402.95
10759    2       320.00  1265793.22  1402.95
10625    2       479.75  1265793.22  1402.95
10308    2       88.80   1265793.22  1402.95
...
*/

-- expressions involving base elements and window functions
SELECT orderid, custid, val,
  CAST(100. * val / SUM(val) OVER() AS NUMERIC(5, 2)) AS pctall,
  CAST(100. * val / SUM(val) OVER(PARTITION BY custid) AS NUMERIC(5, 2)) AS pctcust
FROM Sales.OrderValues AS O1;

/*
orderid  custid  val     pctall  pctcust
-------- ------- ------- ------- --------
10643    1       814.50  0.06    19.06
10692    1       878.00  0.07    20.55
10702    1       330.00  0.03    7.72
10835    1       845.80  0.07    19.79
10952    1       471.20  0.04    11.03
11011    1       933.50  0.07    21.85
10926    2       514.40  0.04    36.67
10759    2       320.00  0.03    22.81
10625    2       479.75  0.04    34.20
10308    2       88.80   0.01    6.33
...
*/

----------------------------------------------------------------------
-- Framing
----------------------------------------------------------------------

----------------------------------------------------------------------
-- ROWS
----------------------------------------------------------------------

-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT empid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runqty
FROM Sales.EmpOrders;

/*
empid       ordermonth              qty         runqty
----------- ----------------------- ----------- -----------
1           2006-07-01 00:00:00.000 121         121
1           2006-08-01 00:00:00.000 247         368
1           2006-09-01 00:00:00.000 255         623
1           2006-10-01 00:00:00.000 143         766
1           2006-11-01 00:00:00.000 318         1084
...
2           2006-07-01 00:00:00.000 50          50
2           2006-08-01 00:00:00.000 94          144
2           2006-09-01 00:00:00.000 137         281
2           2006-10-01 00:00:00.000 248         529
2           2006-11-01 00:00:00.000 237         766
...
*/

-- more concise alternative
SELECT empid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS UNBOUNDED PRECEDING) AS runqty
FROM Sales.EmpOrders;

-- ROWS BETWEEN <n> PRECEDING AND <n> FOLLOWING
SELECT empid, ordermonth, 
  MAX(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN 1 PRECEDING
                         AND 1 PRECEDING) AS prvqty,
  qty AS curqty,
  MAX(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN 1 FOLLOWING
                         AND 1 FOLLOWING) AS nxtqty,
  AVG(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN 1 PRECEDING
                         AND 1 FOLLOWING) AS avgqty
FROM Sales.EmpOrders;

/*
empid  ordermonth              prvqty  curqty  nxtqty  avgqty
------ ----------------------- ------- ------- ------- -------
1      2006-07-01 00:00:00.000 NULL    121     247     184
1      2006-08-01 00:00:00.000 121     247     255     207
1      2006-09-01 00:00:00.000 247     255     143     215
1      2006-10-01 00:00:00.000 255     143     318     238
1      2006-11-01 00:00:00.000 143     318     536     332
...
1      2008-01-01 00:00:00.000 583     397     566     515
1      2008-02-01 00:00:00.000 397     566     467     476
1      2008-03-01 00:00:00.000 566     467     586     539
1      2008-04-01 00:00:00.000 467     586     299     450
1      2008-05-01 00:00:00.000 586     299     NULL    442
...
*/

-- determinism

-- Listing 2-1: DDL and Sample Data for T1
SET NOCOUNT ON;
USE TSQL2012;
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
GO
CREATE TABLE dbo.T1
(
  keycol INT         NOT NULL CONSTRAINT PK_T1 PRIMARY KEY,
  col1   VARCHAR(10) NOT NULL
);

INSERT INTO dbo.T1 VALUES
  (2, 'A'),(3, 'A'),
  (5, 'B'),(7, 'B'),(11, 'B'),
  (13, 'C'),(17, 'C'),(19, 'C'),(23, 'C');

-- nondeterministic query using the ROWS option

/*
-- try running the query before and after creating the following index
CREATE UNIQUE INDEX idx_col1D_keycol ON dbo.T1(col1 DESC, keycol);
*/

SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS cnt
FROM dbo.T1;

/*
keycol      col1       cnt
----------- ---------- -----------
2           A          1
3           A          2
5           B          3
7           B          4
11          B          5
13          C          6
17          C          7
19          C          8
23          C          9
*/

SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1, keycol
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS cnt
FROM dbo.T1;

/*
keycol      col1       cnt
----------- ---------- -----------
2           A          1
3           A          2
5           B          3
7           B          4
11          B          5
13          C          6
17          C          7
19          C          8
23          C          9
*/

----------------------------------------------------------------------
-- RANGE
----------------------------------------------------------------------

-- RANGE INTERVAL '2' MONTH PRECEDING
SELECT empid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                RANGE BETWEEN INTERVAL '2' MONTH PRECEDING
                          AND CURRENT ROW) AS sum3month
FROM Sales.EmpOrders;

-- equivalent to
SELECT empid, ordermonth, qty,
  (SELECT SUM(qty)
   FROM Sales.EmpOrders AS O2
   WHERE O2.empid = O1.empid
     AND O2.ordermonth BETWEEN DATEADD(month, -2, O1.ordermonth)
                           AND O1.ordermonth) AS sum3month
FROM Sales.EmpOrders AS O1;

-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT empid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                RANGE BETWEEN UNBOUNDED PRECEDING
                          AND CURRENT ROW) AS runqty
FROM Sales.EmpOrders;

/*
empid       ordermonth              qty         runqty
----------- ----------------------- ----------- -----------
1           2006-07-01 00:00:00.000 121         121
1           2006-08-01 00:00:00.000 247         368
1           2006-09-01 00:00:00.000 255         623
1           2006-10-01 00:00:00.000 143         766
1           2006-11-01 00:00:00.000 318         1084
...
2           2006-07-01 00:00:00.000 50          50
2           2006-08-01 00:00:00.000 94          144
2           2006-09-01 00:00:00.000 137         281
2           2006-10-01 00:00:00.000 248         529
2           2006-11-01 00:00:00.000 237         766
...
*/

SELECT empid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth
                RANGE UNBOUNDED PRECEDING) AS runqty
FROM Sales.EmpOrders;

SELECT empid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY ordermonth) AS runqty
FROM Sales.EmpOrders;

-- ROWS UNBOUNDED PRECEDING when ties exist
SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS cnt
FROM dbo.T1;

/*
keycol      col1       cnt
----------- ---------- -----------
2           A          1
3           A          2
5           B          3
7           B          4
11          B          5
13          C          6
17          C          7
19          C          8
23          C          9
*/

-- RANGE UNBOUNDED PRECEDING when ties exist
SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                RANGE BETWEEN UNBOUNDED PRECEDING
                          AND CURRENT ROW) AS cnt
FROM dbo.T1;

keycol      col1       cnt
----------- ---------- -----------
2           A          2
3           A          2
5           B          5
7           B          5
11          B          5
13          C          9
17          C          9
19          C          9
23          C          9

----------------------------------------------------------------------
-- Window Frame Exclusion
----------------------------------------------------------------------

/*
-- EXCLUDE NO OTHERS (don't exclude rows)
SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
                EXCLUDE NO OTHERS) AS cnt
FROM dbo.T1;

keycol      col1       cnt
----------- ---------- -----------
2           A          1
3           A          2
5           B          3
7           B          4
11          B          5
13          C          6
17          C          7
19          C          8
23          C          9

-- EXCLUDE CURRENT ROW (exclude cur row)
SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
                EXCLUDE CURRENT ROW) AS cnt
FROM dbo.T1;

keycol      col1       cnt
----------- ---------- -----------
2           A          0
3           A          1
5           B          2
7           B          3
11          B          4
13          C          5
17          C          6
19          C          7
23          C          8

-- EXCLUDE GROUP (exclude cur row, exclude peers)
SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
                EXCLUDE EXCLUDE GROUP) AS cnt
FROM dbo.T1;

keycol      col1       cnt
----------- ---------- -----------
2           A          0
3           A          0
5           B          2
7           B          2
11          B          2
13          C          5
17          C          5
19          C          5
23          C          5

-- EXCLUDE TIES (keep cur row, exclude peers)
SELECT keycol, col1,
  COUNT(*) OVER(ORDER BY col1
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
                EXCLUDE TIES) AS cnt
FROM dbo.T1;

keycol      col1       cnt
----------- ---------- -----------
2           A          1
3           A          1
5           B          3
7           B          3
11          B          3
13          C          6
17          C          6
19          C          6
23          C          6
*/

----------------------------------------------------------------------
-- Further Filtering Ideas
----------------------------------------------------------------------

-- using the FILTER clause, filter 3 months before now
SELECT empid, ordermonth, qty,
  qty - AVG(qty)
          FILTER (WHERE ordermonth <= DATEADD(month, -3, CURRENT_TIMESTAMP))
          OVER(PARTITION BY empid) AS diff
FROM Sales.EmpOrders;

-- an altrnative to the FILTER clause, filter 3 months before now
SELECT empid, ordermonth, qty,
  qty - AVG(CASE WHEN ordermonth <= DATEADD(month, -3, CURRENT_TIMESTAMP) THEN qty END)
          OVER(PARTITION BY empid) AS diff
FROM Sales.EmpOrders;

-- using the FILTER clause, filter orders by the same employee but a different customer than the current
SELECT orderid, orderdate, empid, custid, val,
  val - AVG(val)
          FILTER (WHERE custid <> $current_row.custid)
          OVER(PARTITION BY empid) AS diff
FROM Sales.OrderValues;

-- using a CASE expression, filter orders by the same employee but a different customer than the current
SELECT orderid, orderdate, empid, custid, val,
  val - AVG(CASE WHEN custid <> $current_row.custid THEN val END)
          OVER(PARTITION BY empid) AS diff
FROM Sales.OrderValues;

----------------------------------------------------------------------
-- Distinct Aggregates
----------------------------------------------------------------------

-- distinct window aggregate example (unsupported in SQL Server 2012)
SELECT empid, orderdate, orderid, val,
  COUNT(DISTINCT custid) OVER(PARTITION BY empid
                              ORDER BY orderdate) AS numcusts
FROM Sales.OrderValues;

-- query returning only first occurrence of each custid per employee
SELECT empid, orderdate, orderid, custid, val,
  CASE 
    WHEN ROW_NUMBER() OVER(PARTITION BY empid, custid
                           ORDER BY orderdate) = 1
      THEN custid
  END AS distinct_custid
FROM Sales.OrderValues;

/*
empid  orderdate               orderid  custid  val      distinct_custid
------ ----------------------- -------- ------- -------- ---------------
1      2006-07-17 00:00:00.000 10258    20      1614.88  20
1      2006-08-01 00:00:00.000 10270    87      1376.00  87
1      2006-08-07 00:00:00.000 10275    49      291.84   49
1      2006-08-20 00:00:00.000 10285    63      1743.36  63
1      2006-08-28 00:00:00.000 10292    81      1296.00  81
1      2006-08-29 00:00:00.000 10293    80      848.70   80
1      2006-09-12 00:00:00.000 10304    80      954.40   NULL
1      2006-09-16 00:00:00.000 10306    69      498.50   69
1      2006-09-20 00:00:00.000 10311    18      268.80   18
1      2006-09-25 00:00:00.000 10314    65      2094.30  65
1      2006-09-27 00:00:00.000 10316    65      2835.00  NULL
1      2006-10-09 00:00:00.000 10325    39      1497.00  39
1      2006-10-29 00:00:00.000 10340    9       2436.18  9
1      2006-11-11 00:00:00.000 10351    20      5398.73  NULL
1      2006-11-19 00:00:00.000 10357    46      1167.68  46
1      2006-11-22 00:00:00.000 10361    63      2046.24  NULL
1      2006-11-26 00:00:00.000 10364    19      950.00   19
1      2006-12-03 00:00:00.000 10371    41      72.96    41
1      2006-12-05 00:00:00.000 10374    91      459.00   91
1      2006-12-09 00:00:00.000 10377    72      863.60   72
1      2006-12-09 00:00:00.000 10376    51      399.00   51
1      2006-12-17 00:00:00.000 10385    75      691.20   75
1      2006-12-18 00:00:00.000 10387    70      1058.40  70
1      2006-12-25 00:00:00.000 10393    71      2556.95  71
1      2006-12-25 00:00:00.000 10394    36      442.00   36
1      2006-12-27 00:00:00.000 10396    25      1903.80  25
1      2007-01-01 00:00:00.000 10400    19      3063.00  NULL
1      2007-01-01 00:00:00.000 10401    65      3868.60  NULL
...
*/

-- workaround to unsupported distinct window aggregate
WITH C AS
(
  SELECT empid, orderdate, orderid, custid, val,
    CASE 
      WHEN ROW_NUMBER() OVER(PARTITION BY empid, custid
                             ORDER BY orderdate) = 1
        THEN custid
    END AS distinct_custid
  FROM Sales.OrderValues
)
SELECT empid, orderdate, orderid, val,
  COUNT(distinct_custid) OVER(PARTITION BY empid
                              ORDER BY orderdate) AS numcusts
FROM C;

/*
empid  orderdate               orderid  val      numcusts
------ ----------------------- -------- -------- ---------
1      2006-07-17 00:00:00.000 10258    1614.88  1
1      2006-08-01 00:00:00.000 10270    1376.00  2
1      2006-08-07 00:00:00.000 10275    291.84   3
1      2006-08-20 00:00:00.000 10285    1743.36  4
1      2006-08-28 00:00:00.000 10292    1296.00  5
1      2006-08-29 00:00:00.000 10293    848.70   6
1      2006-09-12 00:00:00.000 10304    954.40   6
1      2006-09-16 00:00:00.000 10306    498.50   7
1      2006-09-20 00:00:00.000 10311    268.80   8
1      2006-09-25 00:00:00.000 10314    2094.30  9
1      2006-09-27 00:00:00.000 10316    2835.00  9
1      2006-10-09 00:00:00.000 10325    1497.00  10
1      2006-10-29 00:00:00.000 10340    2436.18  11
1      2006-11-11 00:00:00.000 10351    5398.73  11
1      2006-11-19 00:00:00.000 10357    1167.68  12
1      2006-11-22 00:00:00.000 10361    2046.24  12
1      2006-11-26 00:00:00.000 10364    950.00   13
1      2006-12-03 00:00:00.000 10371    72.96    14
1      2006-12-05 00:00:00.000 10374    459.00   15
1      2006-12-09 00:00:00.000 10377    863.60   17
1      2006-12-09 00:00:00.000 10376    399.00   17
1      2006-12-17 00:00:00.000 10385    691.20   18
1      2006-12-18 00:00:00.000 10387    1058.40  19
1      2006-12-25 00:00:00.000 10393    2556.95  21
1      2006-12-25 00:00:00.000 10394    442.00   21
1      2006-12-27 00:00:00.000 10396    1903.80  22
1      2007-01-01 00:00:00.000 10400    3063.00  22
1      2007-01-01 00:00:00.000 10401    3868.60  22
...
*/

----------------------------------------------------------------------
-- Nested Aggregates
----------------------------------------------------------------------

-- percent of employee total out of grand total
SELECT empid,
  SUM(val) AS emptotal,
  SUM(val) / SUM(SUM(val)) OVER() * 100. AS pct
FROM Sales.OrderValues
GROUP BY empid;

/*
empid  emptotal   pct
------ ---------- -----------
3      202812.88  16.022500
6      73913.15   5.839200
9      77308.08   6.107400
7      124568.24  9.841100
1      192107.65  15.176800
4      232890.87  18.398800
2      166537.76  13.156700
5      68792.30   5.434700
8      126862.29  10.022300
*/

-- step 1: grouped aggregate
SELECT empid,
  SUM(val) AS emptotal
FROM Sales.OrderValues
GROUP BY empid;

/*
empid  emptotal
------ -----------
3      202812.88
6      73913.15
9      77308.08
7      124568.24
1      192107.65
4      232890.87
2      166537.76
5      68792.30
8      126862.29
*/

-- step 2: final query
SELECT empid,
  SUM(val) AS emptotal,
  SUM(val) / SUM(SUM(val)) OVER() * 100. AS pct
FROM Sales.OrderValues
GROUP BY empid;

-- with a CTE
WITH C AS
(
  SELECT empid,
    SUM(val) AS emptotal
  FROM Sales.OrderValues
  GROUP BY empid
)
SELECT empid, emptotal,
  emptotal / SUM(emptotal) OVER() * 100. AS pct
FROM C;

-- following fails
WITH C AS
(
  SELECT empid, orderdate,
    CASE 
      WHEN ROW_NUMBER() OVER(PARTITION BY empid, custid
                             ORDER BY orderdate) = 1
        THEN custid
    END AS distinct_custid
  FROM Sales.Orders
)
SELECT empid, orderdate,
  COUNT(distinct_custid) OVER(PARTITION BY empid
                              ORDER BY orderdate) AS numcusts
FROM C
GROUP BY empid, orderdate;

/*
Msg 8120, Level 16, State 1, Line 12
Column 'C.distinct_custid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
*/

-- following succeeds
WITH C AS
(
  SELECT empid, orderdate,
    CASE 
      WHEN ROW_NUMBER() OVER(PARTITION BY empid, custid
                             ORDER BY orderdate) = 1
        THEN custid
    END AS distinct_custid
  FROM Sales.Orders
)
SELECT empid, orderdate,
  SUM(COUNT(distinct_custid)) OVER(PARTITION BY empid
                                   ORDER BY orderdate) AS numcusts
FROM C
GROUP BY empid, orderdate;

/*
empid       orderdate               numcusts
----------- ----------------------- -----------
1           2006-07-17 00:00:00.000 1
1           2006-08-01 00:00:00.000 2
1           2006-08-07 00:00:00.000 3
1           2006-08-20 00:00:00.000 4
1           2006-08-28 00:00:00.000 5
1           2006-08-29 00:00:00.000 6
1           2006-09-12 00:00:00.000 6
1           2006-09-16 00:00:00.000 7
1           2006-09-20 00:00:00.000 8
1           2006-09-25 00:00:00.000 9
1           2006-09-27 00:00:00.000 9
1           2006-10-09 00:00:00.000 10
1           2006-10-29 00:00:00.000 11
1           2006-11-11 00:00:00.000 11
1           2006-11-19 00:00:00.000 12
1           2006-11-22 00:00:00.000 12
1           2006-11-26 00:00:00.000 13
1           2006-12-03 00:00:00.000 14
1           2006-12-05 00:00:00.000 15
1           2006-12-09 00:00:00.000 17
1           2006-12-17 00:00:00.000 18
1           2006-12-18 00:00:00.000 19
1           2006-12-25 00:00:00.000 21
1           2006-12-27 00:00:00.000 22
1           2007-01-01 00:00:00.000 22
...
*/

----------------------------------------------------------------------
-- Ranking Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Row Number and Ntile Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- ROW_NUMBER
----------------------------------------------------------------------

-- Listing 2-2: Query with ROW_NUMBER Function
SELECT orderid, val,
  ROW_NUMBER() OVER(ORDER BY orderid) AS rownum
FROM Sales.OrderValues;

/*
orderid  val      rownum
-------- -------- -------
10248    440.00   1
10249    1863.40  2
10250    1552.60  3
10251    654.06   4
10252    3597.90  5
10253    1444.80  6
10254    556.62   7
10255    2490.50  8
10256    517.80   9
10257    1119.90  10
...
*/

-- guarantee presentation ordering
SELECT orderid, val,
  ROW_NUMBER() OVER(ORDER BY orderid) AS rownum
FROM Sales.OrderValues
ORDER BY rownum;

-- different presentation ordering and window ordering
SELECT orderid, val,
  ROW_NUMBER() OVER(ORDER BY orderid) AS rownum
FROM Sales.OrderValues
ORDER BY val DESC;

/*
orderid  val       rownum
-------- --------- -------
10865    16387.50  618
10981    15810.00  734
11030    12615.05  783
10889    11380.00  642
10417    11188.40  170
10817    10952.85  570
10897    10835.24  650
10479    10495.60  232
10540    10191.70  293
10691    10164.80  444
...
*/

-- alternative with COUNT window aggregate
SELECT orderid, val,
  COUNT(*) OVER(ORDER BY orderid
                ROWS UNBOUNDED PRECEDING) AS rownum
FROM Sales.OrderValues;

-- alternative without window functions
SELECT orderid, val,
  (SELECT COUNT(*)
   FROM Sales.OrderValues AS O2
   WHERE O2.orderid <= O1.orderid) AS rownum
FROM Sales.OrderValues AS O1;

----------------------------------------------------------------------
-- Determinism
----------------------------------------------------------------------

-- nondeterministic calculation
SELECT orderid, orderdate, val,
  ROW_NUMBER() OVER(ORDER BY orderdate DESC) AS rownum
FROM Sales.OrderValues;

/*
orderid  orderdate               val      rownum
-------- ----------------------- -------- -------
11074    2008-05-06 00:00:00.000 232.09   1
11075    2008-05-06 00:00:00.000 498.10   2
11076    2008-05-06 00:00:00.000 792.75   3
11077    2008-05-06 00:00:00.000 1255.72  4
11070    2008-05-05 00:00:00.000 1629.98  5
11071    2008-05-05 00:00:00.000 484.50   6
11072    2008-05-05 00:00:00.000 5218.00  7
11073    2008-05-05 00:00:00.000 300.00   8
11067    2008-05-04 00:00:00.000 86.85    9
11068    2008-05-04 00:00:00.000 2027.08  10
...
*/

-- deterministic calculation
SELECT orderid, orderdate, val,
  ROW_NUMBER() OVER(ORDER BY orderdate DESC, orderid DESC) AS rownum
FROM Sales.OrderValues;

/*
orderid  orderdate               val      rownum
-------- ----------------------- -------- -------
11077    2008-05-06 00:00:00.000 1255.72  1
11076    2008-05-06 00:00:00.000 792.75   2
11075    2008-05-06 00:00:00.000 498.10   3
11074    2008-05-06 00:00:00.000 232.09   4
11073    2008-05-05 00:00:00.000 300.00   5
11072    2008-05-05 00:00:00.000 5218.00  6
11071    2008-05-05 00:00:00.000 484.50   7
11070    2008-05-05 00:00:00.000 1629.98  8
11069    2008-05-04 00:00:00.000 360.00   9
11068    2008-05-04 00:00:00.000 2027.08  10
...
*/

-- alternative without window functions
SELECT orderdate, orderid, val,
  (SELECT COUNT(*)
   FROM Sales.OrderValues AS O2
   WHERE O2.orderdate >= O1.orderdate
     AND (O2.orderdate > O1.orderdate
          OR O2.orderid >= O1.orderid)) AS rownum
FROM Sales.OrderValues AS O1;


-- attempt 1 for ROW_NUMBER with no ordering
SELECT orderid, orderdate, val,
  ROW_NUMBER() OVER() AS rownum
FROM Sales.OrderValues;

/*
Msg 4112, Level 15, State 1, Line 2
The function 'ROW_NUMBER' must have an OVER clause with ORDER BY.
*/

-- attempt 2 for ROW_NUMBER with no ordering
SELECT orderid, orderdate, val,
  ROW_NUMBER() OVER(ORDER BY NULL) AS rownum
FROM Sales.OrderValues;

/*
Msg 5309, Level 16, State 1, Line 2
Windowed functions and NEXT VALUE FOR functions do not support constants as ORDER BY clause expressions.
*/

-- attempt 3 for ROW_NUMBER with no ordering
SELECT orderid, orderdate, val,
  ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
FROM Sales.OrderValues;

/*
orderid  orderdate               val      rownum
-------- ----------------------- -------- -------
10248    2006-07-04 00:00:00.000 440.00   1
10249    2006-07-05 00:00:00.000 1863.40  2
10250    2006-07-08 00:00:00.000 1552.60  3
10251    2006-07-08 00:00:00.000 654.06   4
10252    2006-07-09 00:00:00.000 3597.90  5
10253    2006-07-10 00:00:00.000 1444.80  6
10254    2006-07-11 00:00:00.000 556.62   7
10255    2006-07-12 00:00:00.000 2490.50  8
10256    2006-07-15 00:00:00.000 517.80   9
10257    2006-07-16 00:00:00.000 1119.90  10
...
*/

-- Sidebar about sequences

-- create sequence
CREATE SEQUENCE dbo.Seq1 AS INT START WITH 1 INCREMENT BY 1;

-- obtain new value from a sequence
SELECT NEXT VALUE FOR dbo.Seq1;

-- use in a query
SELECT orderid, orderdate, val,
  NEXT VALUE FOR dbo.Seq1 AS seqval
FROM Sales.OrderValues;

-- with an OVER clause
SELECT orderid, orderdate, val,
  NEXT VALUE FOR dbo.Seq1 OVER(ORDER BY orderdate, orderid) AS seqval
FROM Sales.OrderValues;

----------------------------------------------------------------------
-- NTILE
----------------------------------------------------------------------

-- NTILE example
SELECT orderid, val,
  ROW_NUMBER() OVER(ORDER BY val) AS rownum,
  NTILE(10) OVER(ORDER BY val) AS tile
FROM Sales.OrderValues;

/*
orderid  val       rownum  tile
-------- --------- ------- -----
10782    12.50     1       1
10807    18.40     2       1
10586    23.80     3       1
10767    28.00     4       1
10898    30.00     5       1
...
...
10708    180.40    78      1
10476    180.48    79      1
10313    182.40    80      1
10810    187.00    81      1
11065    189.42    82      1
10496    190.00    83      1
10793    191.10    84      2
10428    192.00    85      2
10520    200.00    86      2
11040    200.00    87      2
11043    210.00    88      2
...
...
10417    11188.40  826     10
10889    11380.00  827     10
11030    12615.05  828     10
10981    15810.00  829     10
10865    16387.50  830     10
*/

-- deterministic NTILE
SELECT orderid, val,
  ROW_NUMBER() OVER(ORDER BY val, orderid) AS rownum,
  NTILE(10) OVER(ORDER BY val, orderid) AS tile
FROM Sales.OrderValues;

-- when there's a remainder
SELECT orderid, val,
  ROW_NUMBER() OVER(ORDER BY val, orderid) AS rownum,
  NTILE(100) OVER(ORDER BY val, orderid) AS tile
FROM Sales.OrderValues;

/*
orderid  val       rownum  tile
-------- --------- ------- -----
10782    12.50     1       1
10807    18.40     2       1
10586    23.80     3       1
10767    28.00     4       1
10898    30.00     5       1
10900    33.75     6       1
10883    36.00     7       1
11051    36.00     8       1
10815    40.00     9       1
10674    45.00     10      2
11057    45.00     11      2
10271    48.00     12      2
10602    48.75     13      2
10422    49.80     14      2
10738    52.35     15      2
10754    55.20     16      2
10631    55.80     17      2
10620    57.50     18      2
10963    57.80     19      3
...
10816    8446.45   814     98
10353    8593.28   815     99
10514    8623.45   816     99
11032    8902.50   817     99
10424    9194.56   818     99
10372    9210.90   819     99
10515    9921.30   820     99
10691    10164.80  821     99
10540    10191.70  822     99
10479    10495.60  823     100
10897    10835.24  824     100
10817    10952.85  825     100
10417    11188.40  826     100
10889    11380.00  827     100
11030    12615.05  828     100
10981    15810.00  829     100
10865    16387.50  830     100
*/

-- alternative to NTILE without window functions

-- calculation for given cardinality, number of tiles and row number
DECLARE @cnt AS INT = 830, @numtiles AS INT = 100, @rownum AS INT = 42;

WITH C1 AS
(
  SELECT 
    @cnt / @numtiles     AS basetilesize,
    @cnt / @numtiles + 1 AS extendedtilesize,
    @cnt % @numtiles     AS remainder
),
C2 AS
(
  SELECT *, extendedtilesize * remainder AS cutoffrow
  FROM C1
)
SELECT
  CASE WHEN @rownum <= cutoffrow
    THEN (@rownum - 1) / extendedtilesize + 1
    ELSE remainder + ((@rownum - cutoffrow) - 1) / basetilesize + 1
  END AS tile
FROM C2;

-- calculation for given number of tiles against a table
DECLARE @numtiles AS INT = 100;

WITH C1 AS
(
  SELECT 
    COUNT(*) / @numtiles AS basetilesize,
    COUNT(*) / @numtiles + 1 AS extendedtilesize,
    COUNT(*) % @numtiles AS remainder
  FROM Sales.OrderValues
),
C2 AS
(
  SELECT *, extendedtilesize * remainder AS cutoffrow
  FROM C1
),
C3 AS
(
  SELECT O1.orderid, O1.val,
    (SELECT COUNT(*)
     FROM Sales.OrderValues AS O2
     WHERE O2.val <= O1.val
       AND (O2.val < O1.val
            OR O2.orderid <= O1.orderid)) AS rownum
  FROM Sales.OrderValues AS O1
)
SELECT C3.*,
  CASE WHEN C3.rownum <= C2.cutoffrow
    THEN (C3.rownum - 1) / C2.extendedtilesize + 1
    ELSE C2.remainder + ((C3.rownum - C2.cutoffrow) - 1) / C2.basetilesize + 1
  END AS tile
FROM C3 CROSS JOIN C2;

----------------------------------------------------------------------
-- Rank Functions
----------------------------------------------------------------------

-- ROW_NUMBER, RANK, DENSE_RANK
SELECT orderid, orderdate, val,
  ROW_NUMBER() OVER(ORDER BY orderdate DESC) AS rownum,
  RANK()       OVER(ORDER BY orderdate DESC) AS rnk,
  DENSE_RANK() OVER(ORDER BY orderdate DESC) AS drnk
FROM Sales.OrderValues;

/*
orderid  orderdate               val      rownum  rnk  drnk
-------- ----------------------- -------- ------- ---- ----
11077    2008-05-06 00:00:00.000 232.09   1       1    1
11076    2008-05-06 00:00:00.000 498.10   2       1    1
11075    2008-05-06 00:00:00.000 792.75   3       1    1
11074    2008-05-06 00:00:00.000 1255.72  4       1    1
11073    2008-05-05 00:00:00.000 1629.98  5       5    2
11072    2008-05-05 00:00:00.000 484.50   6       5    2
11071    2008-05-05 00:00:00.000 5218.00  7       5    2
11070    2008-05-05 00:00:00.000 300.00   8       5    2
11069    2008-05-04 00:00:00.000 86.85    9       9    3
11068    2008-05-04 00:00:00.000 2027.08  10      9    3
...
*/

-- alternative to ROW_NUMBER, RANK, DENSE_RANK
SELECT orderid, orderdate, val,
  (SELECT COUNT(*)
   FROM Sales.OrderValues AS O2
   WHERE O2.orderdate > O1.orderdate) + 1 AS rnk,
  (SELECT COUNT(DISTINCT orderdate)
   FROM Sales.OrderValues AS O2
   WHERE O2.orderdate > O1.orderdate) + 1 AS drnk
FROM Sales.OrderValues AS O1;

----------------------------------------------------------------------
-- Distribution Functions
----------------------------------------------------------------------

-- Contents of Scores Table
SELECT * FROM Stats.Scores;

/*
testid     studentid  score
---------- ---------- -----
Test ABC   Student A  95
Test ABC   Student B  80
Test ABC   Student C  55
Test ABC   Student D  55
Test ABC   Student E  50
Test ABC   Student F  80
Test ABC   Student G  95
Test ABC   Student H  65
Test ABC   Student I  75
Test XYZ   Student A  95
Test XYZ   Student B  80
Test XYZ   Student C  55
Test XYZ   Student D  55
Test XYZ   Student E  50
Test XYZ   Student F  80
Test XYZ   Student G  95
Test XYZ   Student H  65
Test XYZ   Student I  75
Test XYZ   Student J  95
*/

----------------------------------------------------------------------
-- Rank Distribution Functions
----------------------------------------------------------------------

-- Listing 2-3: Query Computing PERCENT_RANK and CUME_DIST
SELECT testid, studentid, score,
  PERCENT_RANK() OVER(PARTITION BY testid ORDER BY score) AS percentrank,
  CUME_DIST()    OVER(PARTITION BY testid ORDER BY score) AS cumedist
FROM Stats.Scores;

-- formatted
SELECT testid, studentid, score,
  CAST(PERCENT_RANK() OVER(PARTITION BY testid ORDER BY score) AS NUMERIC(4, 3)) AS percentrank,
  CAST(CUME_DIST()    OVER(PARTITION BY testid ORDER BY score) AS NUMERIC(4, 3)) AS cumedist
FROM Stats.Scores;

/*
testid     studentid  score percentrank  cumedist
---------- ---------- ----- ------------ ---------
Test ABC   Student E  50    0.000        0.111
Test ABC   Student C  55    0.125        0.333
Test ABC   Student D  55    0.125        0.333
Test ABC   Student H  65    0.375        0.444
Test ABC   Student I  75    0.500        0.556
Test ABC   Student F  80    0.625        0.778
Test ABC   Student B  80    0.625        0.778
Test ABC   Student A  95    0.875        1.000
Test ABC   Student G  95    0.875        1.000
Test XYZ   Student E  50    0.000        0.100
Test XYZ   Student C  55    0.111        0.300
Test XYZ   Student D  55    0.111        0.300
Test XYZ   Student H  65    0.333        0.400
Test XYZ   Student I  75    0.444        0.500
Test XYZ   Student B  80    0.556        0.700
Test XYZ   Student F  80    0.556        0.700
Test XYZ   Student G  95    0.778        1.000
Test XYZ   Student J  95    0.778        1.000
Test XYZ   Student A  95    0.778        1.000
*/

-- pre-SQL Server 2012 alternative
WITH C AS
(
  SELECT testid, studentid, score,
    RANK() OVER(PARTITION BY testid ORDER BY score) AS rk,
    COUNT(*) OVER(PARTITION BY testid) AS nr
  FROM Stats.Scores
)
SELECT testid, studentid, score,
  1.0 * (rk - 1) / (nr - 1) AS percentrank,
  1.0 * (SELECT COALESCE(MIN(C2.rk) - 1, C1.nr)
         FROM C AS C2
         WHERE C2.testid = C1.testid
           AND C2.rk > C1.rk) / nr AS cumedist
FROM C AS C1;

-- an example involving aggregates
SELECT empid, COUNT(*) AS numorders,
  PERCENT_RANK() OVER(ORDER BY COUNT(*)) AS percentrank,
  CUME_DIST() OVER(ORDER BY COUNT(*)) AS cumedist
FROM Sales.Orders
GROUP BY empid;

-- formatted
SELECT empid, COUNT(*) AS numorders,
  CAST(PERCENT_RANK() OVER(ORDER BY COUNT(*)) AS NUMERIC(4, 3)) AS percentrank,
  CAST(CUME_DIST() OVER(ORDER BY COUNT(*)) AS NUMERIC(4, 3)) AS cumedist
FROM Sales.Orders
GROUP BY empid;
GO

/*
empid  numorders  percentrank  cumedist
------ ---------- ------------ ---------
5      42         0.000        0.111
9      43         0.125        0.222
6      67         0.250        0.333
7      72         0.375        0.444
2      96         0.500        0.556
8      104        0.625        0.667
1      123        0.750        0.778
3      127        0.875        0.889
4      156        1.000        1.000
*/

----------------------------------------------------------------------
-- Inverse Distribution Functions
----------------------------------------------------------------------

DECLARE @pct AS FLOAT = 0.5;

SELECT testid, score,
  PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentiledisc,
  PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentilecont
FROM Stats.Scores;
GO

/*
testid     score percentiledisc percentilecont
---------- ----- -------------- ----------------------
Test ABC   50    75             75
Test ABC   55    75             75
Test ABC   55    75             75
Test ABC   65    75             75
Test ABC   75    75             75
Test ABC   80    75             75
Test ABC   80    75             75
Test ABC   95    75             75
Test ABC   95    75             75
Test XYZ   50    75             77.5
Test XYZ   55    75             77.5
Test XYZ   55    75             77.5
Test XYZ   65    75             77.5
Test XYZ   75    75             77.5
Test XYZ   80    75             77.5
Test XYZ   80    75             77.5
Test XYZ   95    75             77.5
Test XYZ   95    75             77.5
Test XYZ   95    75             77.5
*/

DECLARE @pct AS FLOAT = 0.1;

SELECT testid, score,
  PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentiledisc,
  PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentilecont
FROM Stats.Scores;
GO

/*
testid     score percentiledisc percentilecont
---------- ----- -------------- ----------------------
Test ABC   50    50             54
Test ABC   55    50             54
Test ABC   55    50             54
Test ABC   65    50             54
Test ABC   75    50             54
Test ABC   80    50             54
Test ABC   80    50             54
Test ABC   95    50             54
Test ABC   95    50             54
Test XYZ   50    50             54.5
Test XYZ   55    50             54.5
Test XYZ   55    50             54.5
Test XYZ   65    50             54.5
Test XYZ   75    50             54.5
Test XYZ   80    50             54.5
Test XYZ   80    50             54.5
Test XYZ   95    50             54.5
Test XYZ   95    50             54.5
Test XYZ   95    50             54.5
*/

----------------------------------------------------------------------
-- Offset Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- LAG and LEAD
----------------------------------------------------------------------

-- LAG and LEAD with defaults
SELECT custid, orderdate, orderid, val,
  LAG(val)  OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS prevval,
  LEAD(val) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues;

/*
custid  orderdate   orderid  val      prevval  nextval
------- ----------- -------- -------- -------- --------
1       2007-08-25  10643    814.50   NULL     878.00
1       2007-10-03  10692    878.00   814.50   330.00
1       2007-10-13  10702    330.00   878.00   845.80
1       2008-01-15  10835    845.80   330.00   471.20
1       2008-03-16  10952    471.20   845.80   933.50
1       2008-04-09  11011    933.50   471.20   NULL
2       2006-09-18  10308    88.80    NULL     479.75
2       2007-08-08  10625    479.75   88.80    320.00
2       2007-11-28  10759    320.00   479.75   514.40
2       2008-03-04  10926    514.40   320.00   NULL
3       2006-11-27  10365    403.20   NULL     749.06
3       2007-04-15  10507    749.06   403.20   1940.85
3       2007-05-13  10535    1940.85  749.06   2082.00
3       2007-06-19  10573    2082.00  1940.85  813.37
3       2007-09-22  10677    813.37   2082.00  375.50
3       2007-09-25  10682    375.50   813.37   660.00
3       2008-01-28  10856    660.00   375.50   NULL
...
*/

-- Nondefault offset
SELECT custid, orderdate, orderid,
  LAG(val, 3) OVER(PARTITION BY custid
                   ORDER BY orderdate, orderid) AS prev3val
FROM Sales.OrderValues;

/*
custid  orderdate   orderid  prev3val
------- ----------- -------- ---------
1       2007-08-25  10643    NULL
1       2007-10-03  10692    NULL
1       2007-10-13  10702    NULL
1       2008-01-15  10835    814.50
1       2008-03-16  10952    878.00
1       2008-04-09  11011    330.00
2       2006-09-18  10308    NULL
2       2007-08-08  10625    NULL
2       2007-11-28  10759    NULL
2       2008-03-04  10926    88.80
3       2006-11-27  10365    NULL
3       2007-04-15  10507    NULL
3       2007-05-13  10535    NULL
3       2007-06-19  10573    403.20
3       2007-09-22  10677    749.06
3       2007-09-25  10682    1940.85
3       2008-01-28  10856    2082.00
...
*/

-- SQL Server 2008 Alternative
WITH OrdersRN AS
(
  SELECT custid, orderdate, orderid, val,
    ROW_NUMBER() OVER(ORDER BY custid, orderdate, orderid) AS rn
  FROM Sales.OrderValues
)
SELECT C.custid, C.orderdate, C.orderid, C.val,
  P.val AS prevval,
  N.val AS nextval
FROM OrdersRN AS C
  LEFT OUTER JOIN OrdersRN AS P
    ON C.custid = P.custid
    AND C.rn = P.rn + 1
  LEFT OUTER JOIN OrdersRN AS N
    ON C.custid = N.custid
    AND C.rn = N.rn - 1;

----------------------------------------------------------------------
-- FIRST_VALUE, LAST_VALUE, NTH_VALUE
----------------------------------------------------------------------

-- FIRST_VALUE, LAST_VALUE
SELECT custid, orderdate, orderid, val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
                        ORDER BY orderdate, orderid) AS val_firstorder,
  LAST_VALUE(val)  OVER(PARTITION BY custid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS val_lastorder
FROM Sales.OrderValues;

/*
custid  orderdate   orderid  val      val_firstorder  val_lastorder
------- ----------- -------- -------- --------------- --------------
1       2007-08-25  10643    814.50   814.50          933.50
1       2007-10-03  10692    878.00   814.50          933.50
1       2007-10-13  10702    330.00   814.50          933.50
1       2008-01-15  10835    845.80   814.50          933.50
1       2008-03-16  10952    471.20   814.50          933.50
1       2008-04-09  11011    933.50   814.50          933.50
2       2006-09-18  10308    88.80    88.80           514.40
2       2007-08-08  10625    479.75   88.80           514.40
2       2007-11-28  10759    320.00   88.80           514.40
2       2008-03-04  10926    514.40   88.80           514.40
3       2006-11-27  10365    403.20   403.20          660.00
3       2007-04-15  10507    749.06   403.20          660.00
3       2007-05-13  10535    1940.85  403.20          660.00
3       2007-06-19  10573    2082.00  403.20          660.00
3       2007-09-22  10677    813.37   403.20          660.00
3       2007-09-25  10682    375.50   403.20          660.00
3       2008-01-28  10856    660.00   403.20          660.00
...
*/

-- Example for use
SELECT custid, orderdate, orderid, val,
  val - FIRST_VALUE(val) OVER(PARTITION BY custid
                              ORDER BY orderdate, orderid) AS difffirst,
  val - LAST_VALUE(val)  OVER(PARTITION BY custid
                              ORDER BY orderdate, orderid
                              ROWS BETWEEN CURRENT ROW
                                       AND UNBOUNDED FOLLOWING) AS difflast
FROM Sales.OrderValues;

/*
custid  orderdate   orderid  val     difffirst  difflast
------- ----------- -------- ------- ---------- ---------
1       2007-08-25  10643    814.50  0.00       -119.00
1       2007-10-03  10692    878.00  63.50      -55.50
1       2007-10-13  10702    330.00  -484.50    -603.50
1       2008-01-15  10835    845.80  31.30      -87.70
1       2008-03-16  10952    471.20  -343.30    -462.30
1       2008-04-09  11011    933.50  119.00     0.00
2       2006-09-18  10308    88.80   0.00       -425.60
2       2007-08-08  10625    479.75  390.95     -34.65
2       2007-11-28  10759    320.00  231.20     -194.40
2       2008-03-04  10926    514.40  425.60     0.00
3       2006-11-27  10365    403.20  0.00       -256.80
3       2007-04-15  10507    749.06  345.86     89.06
3       2007-05-13  10535    1940.8  1537.65    1280.85
3       2007-06-19  10573    2082.0  1678.80    1422.00
3       2007-09-22  10677    813.37  410.17     153.37
3       2007-09-25  10682    375.50  -27.70     -284.50
3       2008-01-28  10856    660.00  256.80     0.00
...
*/

-- Pre SQL Server 2012 Alternative
WITH OrdersRN AS
(
  SELECT custid, val,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate, orderid) AS rna,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rnd
  FROM Sales.OrderValues
),
Agg AS
(
  SELECT custid,
    MAX(CASE WHEN rna = 1 THEN val END) AS firstorderval,
    MAX(CASE WHEN rnd = 1 THEN val END) AS lastorderval,
    MAX(CASE WHEN rna = 3 THEN val END) AS thirdorderval
  FROM OrdersRN
  GROUP BY custid
)
SELECT O.custid, O.orderdate, O.orderid, O.val,
  A.firstorderval, A.lastorderval, A.thirdorderval
FROM Sales.OrderValues AS O
  JOIN Agg AS A
    ON O.custid = A.custid
ORDER BY custid, orderdate, orderid;

/*
custid  orderdate   orderid  val      firstorderval  lastorderval  thirdorderval
------- ----------- -------- -------- -------------- ------------- --------------
1       2007-08-25  10643    814.50   814.50         933.50        330.00
1       2007-10-03  10692    878.00   814.50         933.50        330.00
1       2007-10-13  10702    330.00   814.50         933.50        330.00
1       2008-01-15  10835    845.80   814.50         933.50        330.00
1       2008-03-16  10952    471.20   814.50         933.50        330.00
1       2008-04-09  11011    933.50   814.50         933.50        330.00
2       2006-09-18  10308    88.80    88.80          514.40        320.00
2       2007-08-08  10625    479.75   88.80          514.40        320.00
2       2007-11-28  10759    320.00   88.80          514.40        320.00
2       2008-03-04  10926    514.40   88.80          514.40        320.00
3       2006-11-27  10365    403.20   403.20         660.00        1940.85
3       2007-04-15  10507    749.06   403.20         660.00        1940.85
3       2007-05-13  10535    1940.85  403.20         660.00        1940.85
3       2007-06-19  10573    2082.00  403.20         660.00        1940.85
3       2007-09-22  10677    813.37   403.20         660.00        1940.85
3       2007-09-25  10682    375.50   403.20         660.00        1940.85
3       2008-01-28  10856    660.00   403.20         660.00        1940.85
...
*/