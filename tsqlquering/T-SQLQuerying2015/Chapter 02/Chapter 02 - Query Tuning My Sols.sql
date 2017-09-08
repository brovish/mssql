-- Underestimation
DECLARE @i AS INT = 500000;

SELECT empid, COUNT(*) AS numorders
FROM dbo.Orders
WHERE orderid > @i
GROUP BY empid
OPTION(OPTIMIZE FOR (@i = 999900));

--SELECT orderid, custid, empid, shipperid, orderdate, filler
--FROM dbo.Orders
--WHERE custid = 'C0000000001';


---- Try above query after changing number of CPUs to 16
--DBCC OPTIMIZER_WHATIF(CPUs, 0);

---- Tipping point
---- Following query gets a parallel scan
--SELECT orderid, custid, empid, shipperid, orderdate, filler
--FROM dbo.Orders
--WHERE orderid <= 300000; 

---- Connect to the database PerformanceV3
--SET NOCOUNT ON;
--USE PerformanceV3;

---- Sample query
--SELECT orderid, custid, empid, shipperid, orderdate, filler
--FROM dbo.Orders
--WHERE orderid <= 10000;

---- Clear cache for cold cache test
--CHECKPOINT;
--DBCC DROPCLEANBUFFERS;

---- Statistics IO and time information
--SET STATISTICS IO, TIME ON;

---- Extended Events session with sql_statement_completed event
----CREATE EVENT SESSION query_performance ON SERVER 
----ADD EVENT sqlserver.sql_statement_completed(
----    WHERE (sqlserver.session_id=(59))); -- replace with your session ID;

----ALTER EVENT SESSION query_performance ON SERVER STATE = START;

-- Sample query
--SELECT orderid, custid, empid, shipperid, orderdate, filler
--FROM dbo.Orders
--WHERE orderid <= 10000;

--IF OBJECT_ID(N'DBO.ORDERS2',N'U') IS NOT NULL DROP TABLE DBO.ORDERS2;

--SELECT * INTO DBO.ORDERS2 FROM dbo.Orders;
--ALTER TABLE DBO.ORDERS2 
--ADD CONSTRAINT PK_ORDERS2 PRIMARY KEY NONCLUSTERED(ORDERID)

---- Heap scan
--SELECT orderid, custid, empid, shipperid, orderdate, filler
--FROM DBO.ORDERS2;

---- B-tree scan
--SELECT orderid, custid, empid, shipperid, orderdate, filler
--FROM dbo.Orders;


-----------------------------------------------------------------------
---- Unordered Covering Nonclustered Index Scan
-----------------------------------------------------------------------

--SELECT orderid
--FROM dbo.Orders;

---- Add orderdate to query; PK_Orders index still covering
--SELECT orderid, orderdate
--FROM dbo.Orders;


--SET NOCOUNT ON;
--USE tempdb;
--GO

---- Create table T1
--IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;

--CREATE TABLE dbo.T1
--(
--  clcol UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
--  filler CHAR(2000) NOT NULL DEFAULT('a')
--);
--GO
--CREATE UNIQUE CLUSTERED INDEX idx_clcol ON dbo.T1(clcol);
--GO

---- Insert rows (run for a few seconds then stop)
--SET NOCOUNT ON;
--USE tempdb;

--TRUNCATE TABLE dbo.T1;

--WHILE 1 = 1
--  INSERT INTO dbo.T1 DEFAULT VALUES;
--GO

---- Observe level of fragmentation
--SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
--( 
--  DB_ID(N'tempdb'),
--  OBJECT_ID(N'dbo.T1'),
--  1,
--  NULL,
--  NULL
--);


---- Get index linked list info
--DBCC IND(N'tempdb', N'dbo.T1', 0);
--GO

--CREATE TABLE #DBCCIND
--(
--  PageFID INT,
--  PagePID INT,
--  IAMFID INT,
--  IAMPID INT,
--  ObjectID INT,
--  IndexID INT,
--  PartitionNumber INT,
--  PartitionID BIGINT,
--  iam_chain_type VARCHAR(100),
--  PageType INT,
--  IndexLevel INT,
--  NextPageFID INT,
--  NextPagePID INT,
--  PrevPageFID INT,
--  PrevPagePID INT
--);

--INSERT INTO #DBCCIND
--  EXEC (N'DBCC IND(N''tempdb'', N''dbo.T1'', 0)');

--CREATE CLUSTERED INDEX idx_cl_prevpage ON #DBCCIND(PrevPageFID, PrevPagePID);

--WITH LinkedList
--AS
--(
--  SELECT 1 AS RowNum, PageFID, PagePID
--  FROM #DBCCIND
--  WHERE IndexID = 1
--    AND IndexLevel = 0
--    AND PrevPageFID = 0
--    AND PrevPagePID = 0

--  UNION ALL

--  SELECT PrevLevel.RowNum + 1,
--    CurLevel.PageFID, CurLevel.PagePID
--  FROM LinkedList AS PrevLevel
--    JOIN #DBCCIND AS CurLevel
--      ON CurLevel.PrevPageFID = PrevLevel.PageFID
--      AND CurLevel.PrevPagePID = PrevLevel.PagePID
--)
--SELECT
--  CAST(PageFID AS VARCHAR(MAX)) + ':'
--  + CAST(PagePID AS VARCHAR(MAX)) + ' ' AS [text()]
--FROM LinkedList
--ORDER BY RowNum
----FOR XML PATH('')
--OPTION (MAXRECURSION 0);
