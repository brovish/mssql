----------------------------------------------------------------------
-- High-Performance T-SQL: Set-based Solutions using Microsoft SQL Server 2012 Window Functions
-- Chapter 04 - Optimization of Window Functions
-- © Itzik Ben-Gan
----------------------------------------------------------------------

-- DDL for Accounts and Transactions table
SET NOCOUNT ON;
USE TSQL2012;

IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;
IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL DROP TABLE dbo.Accounts;

CREATE TABLE dbo.Accounts
(
  actid   INT         NOT NULL,
  actname VARCHAR(50) NOT NULL,
  CONSTRAINT PK_Accounts PRIMARY KEY(actid)
);

CREATE TABLE dbo.Transactions
(
  actid  INT   NOT NULL,
  tranid INT   NOT NULL,
  val    MONEY NOT NULL,
  CONSTRAINT PK_Transactions PRIMARY KEY(actid, tranid),
  CONSTRAINT FK_Transactions_Accounts
    FOREIGN KEY(actid)
    REFERENCES dbo.Accounts(actid)
);
GO

-- small set of sample data
INSERT INTO dbo.Accounts(actid, actname) VALUES
  (1,  'account 1'),
  (2,  'account 2'),
  (3,  'account 3');

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

-- definition of GetNums helper function
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

-- large set of sample data (change inputs as needed)
DECLARE
  @num_partitions     AS INT = 100,
  @rows_per_partition AS INT = 20000;

TRUNCATE TABLE dbo.Transactions;
DELETE FROM dbo.Accounts;

INSERT INTO dbo.Accounts WITH (TABLOCK) (actid, actname)
  SELECT n AS actid, 'account ' + CAST(n AS VARCHAR(10)) AS actname
  FROM dbo.GetNums(1, @num_partitions) AS P;

INSERT INTO dbo.Transactions WITH (TABLOCK) (actid, tranid, val)
  SELECT NP.n, RPP.n,
    (ABS(CHECKSUM(NEWID())%2)*2-1) * (1 + ABS(CHECKSUM(NEWID())%5))
  FROM dbo.GetNums(1, @num_partitions) AS NP
    CROSS JOIN dbo.GetNums(1, @rows_per_partition) AS RPP;
GO

----------------------------------------------------------------------
-- Indexing Guidelines
----------------------------------------------------------------------

-- make sure index does not exist
DROP INDEX idx_actid_val_i_tranid ON dbo.Transactions;

-- without POC index plan requires a Sort iterator
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

-- create POC index
CREATE INDEX idx_actid_val_i_tranid
  ON dbo.Transactions(actid, val)
  INCLUDE(tranid);

-- with POC index plan doesn't require Sort iterator
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

-- no window partition clause

-- forward scan of index can benefit from parallelism
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(ORDER BY actid, val) AS rownum
FROM dbo.Transactions
WHERE tranid < 1000;

-- bacward scan of index can be used, bat cannot benefit from parallelism
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(ORDER BY actid DESC, val DESC) AS rownum
FROM dbo.Transactions
WHERE tranid < 1000;

-- with partitioning, ascending order, ordered forward scan of index
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

-- with partitioning, descending order, sort takes place
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val DESC) AS rownum
FROM dbo.Transactions;

-- adding presentation ORDER BY removes the sort
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val DESC) AS rownum
FROM dbo.Transactions
ORDER BY actid DESC;

----------------------------------------------------------------------
-- Ranking Functions
----------------------------------------------------------------------

-- ROW_NUMBER
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

-- arbitrary ordering
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
FROM dbo.Transactions;

-- NTILE
SELECT actid, tranid, val,
  NTILE(100) OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

-- RANK
SELECT actid, tranid, val,
  RANK() OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

-- DENSE_RANK
SELECT actid, tranid, val,
  DENSE_RANK() OVER(PARTITION BY actid ORDER BY val) AS rownum
FROM dbo.Transactions;

----------------------------------------------------------------------
-- Improved Parallelism with APPLY
----------------------------------------------------------------------

-- without APPLY: 7 seconds
SELECT actid, tranid, val,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val) AS rownumasc,
  ROW_NUMBER() OVER(PARTITION BY actid ORDER BY val DESC) AS rownumdesc
FROM dbo.Transactions;

-- Listing 1: Parallel APPLY Technique
-- with APPLY (need at least 8 CPUs), 3 seconds: 
SELECT C.actid, A.*
FROM dbo.Accounts AS C
  CROSS APPLY (SELECT tranid, val,
                 ROW_NUMBER() OVER(ORDER BY val) AS rownumasc,
                 ROW_NUMBER() OVER(ORDER BY val DESC) AS rownumdesc
               FROM dbo.Transactions AS T
               WHERE T.actid = C.actid) AS A;

----------------------------------------------------------------------
-- Aggregate and Offset Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Without Ordering and Framing
----------------------------------------------------------------------

-- window aggregate with just partitioning, 10 seconds
SELECT actid, tranid, val,
   MAX(val) OVER(PARTITION BY actid) AS mx
FROM dbo.Transactions;

-- window aggregate with partitioning, plus filter, 12 seconds
WITH C AS
(
  SELECT actid, tranid, val,
     MAX(val) OVER(PARTITION BY actid) AS mx
  FROM dbo.Transactions
)
SELECT actid, tranid, val
FROM C
WHERE val = mx;

-- alternative with grouped aggregate, 2 seconds
WITH Aggs AS
(
  SELECT actid, MAX(val) AS mx
  FROM dbo.Transactions
  GROUP BY actid
)
SELECT T.actid, T.tranid, T.val, A.mx
FROM dbo.Transactions AS T
  JOIN Aggs AS A
    ON T.actid = A.actid;

-- alternative with grouped aggregate, plus filter, < 1 second
WITH Aggs AS
(
  SELECT actid, MAX(val) AS mx
  FROM dbo.Transactions
  GROUP BY actid
)
SELECT T.actid, T.tranid, T.val
FROM dbo.Transactions AS T
  JOIN Aggs AS A
    ON T.actid = A.actid
   AND T.val = A.mx;

----------------------------------------------------------------------
-- With Ordering and Framing
----------------------------------------------------------------------

----------------------------------------------------------------------
-- UNBOUNDED PRECEDING AND CURRENT ROW
----------------------------------------------------------------------

-- ROWS, 9 seconds, 6,208 reads
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS balance
FROM dbo.Transactions;

-- RANGE, 60 seconds, 18,063,511 reads, 5,800 writes
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid
                ORDER BY tranid
                RANGE BETWEEN UNBOUNDED PRECEDING
                          AND CURRENT ROW) AS balance
FROM dbo.Transactions;

-- RANGE, 60 seconds, 18,063,511 reads, 5,800 writes
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid
                ORDER BY tranid) AS balance
FROM dbo.Transactions;

-- with APPLY, 21 seconds: 
SELECT C.actid, A.*
FROM dbo.Accounts AS C
  CROSS APPLY (SELECT tranid, val,
                 SUM(val) OVER(ORDER BY tranid
                               RANGE BETWEEN UNBOUNDED PRECEDING
                                         AND CURRENT ROW) AS balance
               FROM dbo.Transactions AS T
               WHERE T.actid = C.actid) AS A;

----------------------------------------------------------------------
-- Expanding All Frame Rows
----------------------------------------------------------------------

-- subtractable aggregates, up to 4 rows in frame, 14 seconds
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN 5 PRECEDING
                         AND 2 PRECEDING) AS sumval
FROM dbo.Transactions;

-- nonsubtractable aggregates, always, 75 seconds
SELECT actid, tranid, val,
  MAX(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN 100 PRECEDING
                          AND  2 PRECEDING) AS maxval
FROM dbo.Transactions;

-- with APPLY, 31 seconds
SELECT C.actid, A.*
FROM dbo.Accounts AS C
  CROSS APPLY (SELECT tranid, val,
                 MAX(val) OVER(ORDER BY tranid
                               ROWS BETWEEN 100 PRECEDING
                                        AND  2 PRECEDING) AS maxval
               FROM dbo.Transactions AS T
               WHERE T.actid = C.actid) AS A;

-- test for in-memory vs. on-disk worktable
SET STATISTICS IO ON;

SELECT actid, tranid, val,
  MAX(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN 9999 PRECEDING
                         AND 9999 PRECEDING) AS maxval
FROM dbo.Transactions;

SELECT actid, tranid, val,
  MAX(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN 10000 PRECEDING
                         AND 10000 PRECEDING) AS maxval
FROM dbo.Transactions;

-- 9999 PRECEDING AND 9999 PRECEDING, 6 seconds
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Transactions'. Scan count 1, logical reads 6208, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- 10000 PRECEDING AND 10000 PRECEDING, 33 seconds
Table 'Worktable'. Scan count 2000100, logical reads 12086700, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Transactions'. Scan count 1, logical reads 6208, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

SET STATISTICS IO OFF;

-- xevent
CREATE EVENT SESSION xe_window_spool ON SERVER
ADD EVENT sqlserver.window_spool_ondisk_warning
  ( ACTION (sqlserver.plan_handle, sqlserver.sql_text) )
ADD TARGET package0.asynchronous_file_target
  ( SET FILENAME  = N'c:\temp\xe_xe_window_spool.xel', 
    metadatafile  = N'c:\temp\xe_xe_window_spool.xem' );

ALTER EVENT SESSION xe_window_spool ON SERVER STATE = START;

-- cleanup
DROP EVENT SESSION xe_window_spool ON SERVER;

----------------------------------------------------------------------
-- Computing Two Cumulative Values
----------------------------------------------------------------------

-- subtractable aggregates, more than 4 rows in frame, 14 seconds
SELECT actid, tranid, val,
  SUM(val) OVER(PARTITION BY actid
                ORDER BY tranid
                ROWS BETWEEN 100 PRECEDING
                          AND  2 PRECEDING) AS sumval
FROM dbo.Transactions;

-- with APPLY, 8 seconds
SELECT C.actid, A.*
FROM dbo.Accounts AS C
  CROSS APPLY (SELECT tranid, val,
                 SUM(val) OVER(ORDER BY tranid
                               ROWS BETWEEN 100 PRECEDING
                                         AND  2 PRECEDING) AS sumval
               FROM dbo.Transactions AS T
               WHERE T.actid = C.actid) AS A;

----------------------------------------------------------------------
-- Distribution Functions
----------------------------------------------------------------------

----------------------------------------------------------------------
-- PERCENT_RANK, CUME_DIST
----------------------------------------------------------------------

-- PERCENT_RANK and CUME_DIST
SELECT testid, studentid, score,
  PERCENT_RANK() OVER(PARTITION BY testid ORDER BY score) AS percentrank
FROM Stats.Scores;

SELECT testid, studentid, score,
  CUME_DIST()    OVER(PARTITION BY testid ORDER BY score) AS cumedist
FROM Stats.Scores;

----------------------------------------------------------------------
-- PERCENTILE_CONT, PERCENTILE_DISC
----------------------------------------------------------------------

SELECT testid, score,
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentiledisc
FROM Stats.Scores;

SELECT testid, score,
  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY score) OVER(PARTITION BY testid) AS percentilecont
FROM Stats.Scores;
