----------------------------------------------------------------------
-- High-Performance T-SQL: Set-based Solutions using Microsoft SQL Server 2012 Window Functions
-- Chapter 03 - Ordered Set Functions
-- © Itzik Ben-Gan
----------------------------------------------------------------------

SET NOCOUNT ON;
USE TSQL2012;

----------------------------------------------------------------------
-- Hypothetical Set Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- RANK
----------------------------------------------------------------------

-- as a window function
USE TSQL2012;

SELECT custid, val,
  RANK() OVER(PARTITION BY custid ORDER BY val) AS rnk
FROM Sales.OrderValues;

/*
custid  val      rnk
------- -------- ----
1       330.00   1
1       471.20   2
1       814.50   3
1       845.80   4
1       878.00   5
1       933.50   6
2       88.80    1
2       320.00   2
2       479.75   3
2       514.40   4
3       375.50   1
3       403.20   2
3       660.00   3
3       749.06   4
3       813.37   5
3       1940.85  6
3       2082.00  7
4       191.10   1
4       228.00   2
4       282.00   3
4       319.20   4
4       390.00   5
4       407.70   6
4       480.00   7
4       491.50   8
4       899.00   9
4       1477.00  10
4       1641.00  11
4       2142.90  12
4       4441.25  13
...
*/
GO

-- as an ordered set function
/*
DECLARE @val AS NUMERIC(12, 2) = 1000.00;

SELECT custid,
  RANK(@val) WITHIN GROUP(ORDER BY val) AS rnk
FROM Sales.OrderValues
GROUP BY custid;
*/

/*
custid      rnk
----------- -----------
1           7
2           5
3           6
4           10
5           7
6           8
7           6
8           3
9           9
10          7
...
*/
GO

-- SQL Server Alternative
DECLARE @val AS NUMERIC(12, 2) = 1000.00;

SELECT custid,
  COUNT(CASE WHEN val < @val THEN 1 END) + 1 AS rnk
FROM Sales.OrderValues
GROUP BY custid;
GO

----------------------------------------------------------------------
-- DENSE_RANK
----------------------------------------------------------------------

/*
DECLARE @val AS NUMERIC(12, 2) = 1000.00;

SELECT custid,
  DENSE_RANK(@val) WITHIN GROUP(ORDER BY val) AS densernk
FROM Sales.OrderValues
GROUP BY custid;
*/

/*
custid      densernk
----------- --------------
1           7
2           5
3           6
4           10
5           7
6           8
7           6
8           3
9           8
10          7
...
*/
GO

-- SQL Server Alternative
DECLARE @val AS NUMERIC(12, 2) = 1000.00;

SELECT custid,
  COUNT(DISTINCT CASE WHEN val < @val THEN val END) + 1 AS densernk
FROM Sales.OrderValues
GROUP BY custid;
GO

----------------------------------------------------------------------
-- PERCENT_RANK
----------------------------------------------------------------------
/*
DECLARE @score AS TINYINT = 80;

SELECT testid,
  PERCENT_RANK(@score) WITHIN GROUP(ORDER BY score) AS pctrank
FROM Stats.Scores
GROUP BY testid;
*/

/*
testid     pctrank
---------- ---------------
Test ABC   0.556       
Test XYZ   0.500       
*/
GO

-- SQL Server Alternative
DECLARE @score AS TINYINT = 80;

WITH C AS
(
  SELECT testid,
    COUNT(CASE WHEN score < @score THEN 1 END) + 1 AS rk,
    COUNT(*) + 1 AS nr
  FROM Stats.Scores
  GROUP BY testid
)
SELECT testid, 1.0 * (rk - 1) / (nr - 1) AS pctrank
FROM C;
GO

----------------------------------------------------------------------
-- CUME_DIST
----------------------------------------------------------------------
/*
DECLARE @score AS TINYINT = 80;

SELECT testid,
  CUME_DIST(@score) WITHIN GROUP(ORDER BY score) AS cumedist
FROM Stats.Scores
GROUP BY testid;
*/

/*
testid     cumedist
---------- ------------
Test ABC   0.800
Test XYZ   0.727
*/
GO

-- SQL Server Alternative
DECLARE @score AS TINYINT = 80;

WITH C AS
(
  SELECT testid,
    COUNT(CASE WHEN score <= @score THEN 1 END) + 1 AS np,
    COUNT(*) + 1 AS nr
  FROM Stats.Scores
  GROUP BY testid
)
SELECT testid, 1.0 * np / nr AS cumedist
FROM C;
GO

----------------------------------------------------------------------
-- General Solution
----------------------------------------------------------------------

/*
SELECT <partition_col>, wf AS osf
FROM <partitions_table> AS P
  CROSS APPLY (SELECT <window_function>() OVER(ORDER BY <ord_col>) AS wf, return_flag
               FROM (SELECT <ord_col>, 0 AS return_flag
                     FROM <details_table> AS D
                     WHERE D.<partition_col> = P.<partition_col>
               
                     UNION ALL
               
                     SELECT @input_val, 1) AS U) AS A
WHERE return_flag = 1;
GO
*/

-- example for implementing general solution to calculate RANK and DENSE_RANK
DECLARE @val AS NUMERIC(12, 2) = 1000.00;

SELECT custid, rnk, densernk
FROM Sales.Customers AS P
  CROSS APPLY (SELECT 
                 RANK() OVER(ORDER BY val) AS rnk,
                 DENSE_RANK() OVER(ORDER BY val) AS densernk,
                 return_flag
               FROM (SELECT val, 0 AS return_flag
                     FROM Sales.OrderValues AS D
                     WHERE D.custid = P.custid
               
                     UNION ALL
               
                     SELECT @val, 1) AS U) AS A
WHERE return_flag = 1;

/*
custid      rnk                  densernk
----------- -------------------- --------------------
1           7                    7
2           5                    5
3           6                    6
4           10                   10
5           7                    7
6           8                    8
7           6                    6
8           3                    3
9           9                    8
11          9                    9
...
*/
GO

-- example for implementing general solution to calculate PERCENT_RANK and CUME_DIST
DECLARE @score AS TINYINT = 80;

SELECT testid, pctrank, cumedist
FROM Stats.Tests AS P
  CROSS APPLY (SELECT 
                 PERCENT_RANK() OVER(ORDER BY score) AS pctrank,
                 CUME_DIST() OVER(ORDER BY score) AS cumedist,
                 return_flag
               FROM (SELECT score, 0 AS return_flag
                     FROM Stats.Scores AS D
                     WHERE D.testid = P.testid
               
                     UNION ALL
               
                     SELECT @score, 1) AS U) AS A
WHERE return_flag = 1;

/*
testid     pctrank                cumedist
---------- ---------------------- ----------------------
Test ABC   0.555555555555556      0.8
Test XYZ   0.5                    0.727272727272727
*/
GO

-- exclude empty partitions
DECLARE @val AS NUMERIC(12, 2) = 1000.00;

SELECT custid, rnk, densernk
FROM Sales.Customers AS P
  CROSS APPLY (SELECT 
                 RANK() OVER(ORDER BY val) AS rnk,
                 DENSE_RANK() OVER(ORDER BY val) AS densernk,
                 return_flag
               FROM (SELECT val, 0 AS return_flag
                     FROM Sales.OrderValues AS D
                     WHERE D.custid = P.custid
               
                     UNION ALL
               
                     SELECT @val, 1) AS D) AS A
WHERE return_flag = 1
  AND EXISTS
    (SELECT * FROM Sales.OrderValues AS D
     WHERE D.custid = P.custid);
GO

----------------------------------------------------------------------
-- Inverse Distribution Functions
----------------------------------------------------------------------

-- as window functions
DECLARE @pct AS FLOAT = 0.5;

SELECT testid, score,
  PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentiledisc,
  PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentilecont
FROM Stats.Scores;

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
GO

-- getting only one row per group

/*
--standard (unsupported in SQL Server 2012)
DECLARE @pct AS FLOAT = 0.5;

SELECT testid, 
  PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score) AS percentiledisc,
  PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score) AS percentilecont
FROM Stats.Scores
GROUP BY testid;
GO
*/

-- option 1
DECLARE @pct AS FLOAT = 0.5;

SELECT DISTINCT testid,
  PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score)
    OVER(PARTITION BY testid) AS percentiledisc,
  PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score)
    OVER(PARTITION BY testid) AS percentilecont
FROM Stats.Scores;

/*
testid     percentiledisc percentilecont
---------- -------------- ----------------------
Test ABC   75             75
Test XYZ   75             77.5
*/
GO

-- option 2
DECLARE @pct AS FLOAT = 0.5;

WITH C AS
(
  SELECT testid,
    PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentiledisc,
    PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentilecont,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY (SELECT NULL)) AS rownum
  FROM Stats.Scores
)
SELECT testid, percentiledisc, percentilecont
FROM C
WHERE rownum = 1;

/*
testid     percentiledisc percentilecont
---------- -------------- ----------------------
Test ABC   75             75
Test XYZ   75             77.5
*/
GO

-- option 3
DECLARE @pct AS FLOAT = 0.5;

SELECT TOP (1) WITH TIES testid,
  PERCENTILE_DISC(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentiledisc,
  PERCENTILE_CONT(@pct) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentilecont
FROM Stats.Scores
ORDER BY ROW_NUMBER() OVER(PARTITION BY testid ORDER BY (SELECT NULL));
GO

-- pre-SQL Server 2012 alternative to PERCENTILE_DISC
DECLARE @pct AS FLOAT = 0.5;

WITH C AS
(
  SELECT testid, score,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score) AS np,
    COUNT(*) OVER(PARTITION BY testid) AS nr
  FROM Stats.Scores
)
SELECT testid, MIN(score) AS percentiledisc
FROM C
WHERE	1.0 * np / nr >= @pct
GROUP BY testid;

/*
testid     percentiledisc
---------- --------------
Test ABC   75
Test XYZ   75
*/
GO

-- pre-SQL Server 2012 alternative to PERCENTILE_CONT
DECLARE @pct AS FLOAT = 0.5;

WITH C1 AS
(
  SELECT testid, score,
    ROW_NUMBER() OVER(PARTITION BY testid ORDER BY score) - 1 AS rownum,
    @pct * (COUNT(*) OVER(PARTITION BY testid) - 1) AS a
  FROM Stats.Scores
),
C2 AS
(
  SELECT testid, score, a-FLOOR(a) AS factor
  FROM C1
  WHERE rownum IN (FLOOR(a), CEILING(a))
)
SELECT testid, MIN(score) + factor * (MAX(score) - MIN(score)) AS percentilecont
FROM C2
GROUP BY testid, factor;

/*
testid     percentilecont
---------- ----------------------
Test ABC   75
Test XYZ   77.5
*/
GO

----------------------------------------------------------------------
-- FIRST_VALUE, LAST_VALUE, NTH_VALUE
----------------------------------------------------------------------

-- FIRST_VALUE, LAST_VALUE as window functions
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

-- returning one row per customer
WITH C AS
(
  SELECT custid, 
    FIRST_VALUE(val) OVER(PARTITION BY custid
                          ORDER BY orderdate, orderid) AS val_firstorder,
    LAST_VALUE(val)  OVER(PARTITION BY custid
                          ORDER BY orderdate, orderid
                          ROWS BETWEEN CURRENT ROW
                                   AND UNBOUNDED FOLLOWING) AS val_lastorder,
    ROW_NUMBER() OVER(PARTITION BY custid ORDER BY (SELECT NULL)) AS rownum
  FROM Sales.OrderValues
)
SELECT custid, val_firstorder, val_lastorder
FROM C
WHERE rownum = 1;

/*
custid  val_firstorder  val_lastorder
------- --------------- --------------
1       814.50          933.50
2       88.80           514.40
3       403.20          660.00
4       480.00          491.50
5       1488.80         1835.70
6       149.00          858.00
7       1176.00         730.00
8       982.00          224.00
9       88.50           792.75
10      1832.80         525.00
...
*/

-- pre SQL Server 2012 solutions

-- Using row numbers
WITH OrdersRN AS
(
  SELECT custid, val,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate, orderid) AS rna,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rnd
  FROM Sales.OrderValues
)
SELECT custid,
  MAX(CASE WHEN rna = 1 THEN val END) AS firstorderval,
  MAX(CASE WHEN rnd = 1 THEN val END) AS lastorderval,
  MAX(CASE WHEN rna = 3 THEN val END) AS thirdorderval
FROM OrdersRN
GROUP BY custid;

/*
custid  firstorderval  lastorderval  thirdorderval
------- -------------- ------------- --------------
1       814.50         933.50        330.00
2       88.80          514.40        320.00
3       403.20         660.00        1940.85
4       480.00         491.50        407.70
5       1488.80        1835.70       2222.40
6       149.00         858.00        330.00
7       1176.00        730.00        7390.20
8       982.00         224.00        224.00
9       88.50          792.75        1549.60
10      1832.80        525.00        966.80
...
*/

-- using carry-along-sort technique

-- step 1: create concatenated strings
SELECT custid,
  CONVERT(CHAR(8), orderdate, 112)
    + STR(orderid, 10)
    + STR(val, 14, 2)
    COLLATE Latin1_General_BIN2 AS s
FROM Sales.OrderValues;

/*
custid      s
----------- --------------------------------
85          20060704     10248        440.00
79          20060705     10249       1863.40
34          20060708     10250       1552.60
84          20060708     10251        654.06
76          20060709     10252       3597.90
34          20060710     10253       1444.80
14          20060711     10254        556.62
68          20060712     10255       2490.50
88          20060715     10256        517.80
35          20060716     10257       1119.90
...
*/

-- step 2: group, aggregate and extract
WITH C AS
(
  SELECT custid,
    CONVERT(CHAR(8), orderdate, 112)
      + STR(orderid, 10)
      + STR(val, 14, 2)
      COLLATE Latin1_General_BIN2 AS s
  FROM Sales.OrderValues
)
SELECT custid,
  CAST(SUBSTRING(MIN(s), 19, 14) AS NUMERIC(12, 2)) AS firstorderval,
  CAST(SUBSTRING(MAX(s), 19, 14) AS NUMERIC(12, 2)) AS lastorderval
FROM C
GROUP BY custid;

/*
custid  firstorderval  lastorderval
------- -------------- -------------
1       814.50         933.50
2       88.80          514.40
3       403.20         660.00
4       480.00         491.50
5       1488.80        1835.70
6       149.00         858.00
7       1176.00        730.00
8       982.00         224.00
9       88.50          792.75
10      1832.80        525.00
...
*/

-- in case ordering element supports negative values, e.g., orderid
WITH C AS
(
  SELECT custid,
    CONVERT(CHAR(8), orderdate, 112)
      + CASE SIGN(orderid) WHEN -1 THEN '0' ELSE '1' END -- negative sorts before nonnegative
      + STR(CASE SIGN(orderid) 
              WHEN -1 THEN 2147483648 -- if negative add abs(minnegative)
              ELSE 0 
            END + orderid, 10)
      + STR(val, 14, 2)
      COLLATE Latin1_General_BIN2 AS s
  FROM Sales.OrderValues
)
SELECT custid,
  CAST(SUBSTRING(MIN(s), 20, 14) AS NUMERIC(12, 2)) AS firstorderval,
  CAST(SUBSTRING(MAX(s), 20, 14) AS NUMERIC(12, 2)) AS lastorderval
FROM C
GROUP BY custid;

----------------------------------------------------------------------
-- String Concatenation
----------------------------------------------------------------------

-- Supported by Oracle
/*
SELECT custid,
  LISTAGG(orderid, ',') WITHIN GROUP(ORDER BY orderid) AS custorders
FROM Sales.Orders
GROUP BY custid;
*/

/*
custid  custorders
------- ------------------------------------------------------------------------------------------------------------
1       10643,10692,10702,10835,10952,11011
2       10308,10625,10759,10926
3       10365,10507,10535,10573,10677,10682,10856
4       10355,10383,10453,10558,10707,10741,10743,10768,10793,10864,10920,10953,11016
5       10278,10280,10384,10444,10445,10524,10572,10626,10654,10672,10689,10733,10778,10837,10857,10866,10875,10924
6       10501,10509,10582,10614,10853,10956,11058
7       10265,10297,10360,10436,10449,10559,10566,10584,10628,10679,10826
8       10326,10801,10970
9       10331,10340,10362,10470,10511,10525,10663,10715,10730,10732,10755,10827,10871,10876,10932,10940,11076
11      10289,10471,10484,10538,10539,10578,10599,10943,10947,11023
...
*/

-- SQL Server Alternative
SELECT custid,
  COALESCE(
    STUFF(
      (SELECT ',' + CAST(orderid AS VARCHAR(10)) AS [text()]
       FROM Sales.Orders AS O
       WHERE O.custid = C.custid
       ORDER BY orderid
       FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'),
      1, 1, ''),
    '') AS custorders
FROM Sales.Customers AS C;
