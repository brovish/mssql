USE PerformanceV3;
SET NOCOUNT ON;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Sample query
SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 10000;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
-- Clear cache for cold cache test
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
