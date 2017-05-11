USE [TSQL2012];
GO

--IF OBJECT_ID('dbo.Orders','u') IS NOT NULL DROP TABLE dbo.Orders;

--CREATE TABLE dbo.Orders
--(
--	orderid		INT			NOT NULL,
--	orderdate	DATE		NOT NULL,
--	empid		INT			NOT NULL,
--	custid		VARCHAR(5)	NOT NULL,
--	qty			INT			NOT NULL,
--	CONSTRAINT PK_ORDERS PRIMARY KEY(orderid)
--)

--INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
--VALUES
--  (30001, '20070802', 3, 'A', 10),
--  (10001, '20071224', 2, 'A', 12),
--  (10005, '20071224', 1, 'B', 20),
--  (40001, '20080109', 2, 'A', 40),
--  (10006, '20080118', 1, 'C', 14),
--  (20001, '20080212', 2, 'B', 12),
--  (40005, '20090212', 3, 'A', 10),
--  (20002, '20090216', 1, 'C', 20),
--  (30003, '20090418', 2, 'B', 15),
--  (30004, '20070418', 3, 'C', 22),
--  (30007, '20090907', 3, 'D', 30);

--SELECT
--O.custid,O.orderid,O.qty, RANK() OVER(PARTITION BY O.custid ORDER BY O.qty) AS rnk, 
--DENSE_RANK() OVER(PARTITION BY O.custid ORDER BY O.qty) AS drnk
--FROM dbo.Orders AS O

--SELECT
--O.custid,O.orderid, O.qty,O.qty - LAG(O.qty) OVER(PARTITION BY O.custid ORDER BY O.orderdate,o.orderid) AS diffprev,
--O.qty - LEAD(O.qty) OVER(PARTITION BY O.custid ORDER BY O.orderdate,o.orderid) AS diffnext
--FROM dbo.Orders AS O

--SELECT
--O.empid,
--SUM(CASE WHEN O.orderdate >= DATEFROMPARTS(2007,01,01) AND O.orderdate < DATEFROMPARTS(2008,01,01) THEN 1 END) AS cnt2007,
--SUM(CASE WHEN O.orderdate >= DATEFROMPARTS(2008,01,01) AND O.orderdate < DATEFROMPARTS(2009,01,01) THEN 1 END) AS cnt2008,
--SUM(CASE WHEN O.orderdate >= DATEFROMPARTS(2009,01,01) AND O.orderdate < DATEFROMPARTS(2010,01,01) THEN 1 END) AS cnt2009
--FROM dbo.Orders AS O
--GROUP BY O.empid

--SELECT
--O.empid,
--COUNT(CASE WHEN O.orderdate >= DATEFROMPARTS(2007,01,01) AND O.orderdate < DATEFROMPARTS(2008,01,01) THEN 1 END) AS cnt2007,
--COUNT(CASE WHEN O.orderdate >= DATEFROMPARTS(2008,01,01) AND O.orderdate < DATEFROMPARTS(2009,01,01) THEN 1 END) AS cnt2008,
--COUNT(CASE WHEN O.orderdate >= DATEFROMPARTS(2009,01,01) AND O.orderdate < DATEFROMPARTS(2010,01,01) THEN 1 END) AS cnt2009
--FROM dbo.Orders AS O
--GROUP BY O.empid

--SELECT
--O.empid,
--COUNT(CASE WHEN O.orderdate >= DATEFROMPARTS(2007,01,01) AND O.orderdate < DATEFROMPARTS(2008,01,01) THEN O.orderdate END) AS cnt2007,
--COUNT(CASE WHEN O.orderdate >= DATEFROMPARTS(2008,01,01) AND O.orderdate < DATEFROMPARTS(2009,01,01) THEN O.orderdate END) AS cnt2008,
--COUNT(CASE WHEN O.orderdate >= DATEFROMPARTS(2009,01,01) AND O.orderdate < DATEFROMPARTS(2010,01,01) THEN O.orderdate END) AS cnt2009
--FROM dbo.Orders AS O
--GROUP BY O.empid

--SELECT 
--empid, [2007] AS cnt2008, [2008] AS cnt2008, [2009] AS cnt2009
--FROM (SELECT O.empid, YEAR(O.orderdate) AS OYEAR  FROM dbo.Orders AS O)AS D
--	PIVOT(COUNT(D.OYEAR) FOR OYEAR IN ([2007],[2008],[2009])) AS P;

--IF OBJECT_ID('dbo.EmpYearOrders','U') IS NOT NULL DROP TABLE dbo.EmpYearOrders;

--CREATE TABLE dbo.EmpYearOrders
--(
--empid INT NOT NULL
--CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
--cnt2007 INT NULL,
--cnt2008 INT NULL,
--cnt2009 INT NULL
--)

--INSERT INTO dbo.EmpYearOrders(empid,cnt2007,cnt2008,cnt2009)
--	SELECT 
--	empid, [2007] AS cnt2008, [2008] AS cnt2008, [2009] AS cnt2009
--	FROM (SELECT O.empid, YEAR(O.orderdate) AS OYEAR  FROM dbo.Orders AS O)AS D
--		PIVOT(COUNT(D.OYEAR) FOR OYEAR IN ([2007],[2008],[2009])) AS P;

SELECT 
*
FROM DBO.EmpYearOrders;

SELECT 
*
FROM (SELECT E.empid, OrderYear, 
			CASE OrderYear 
				WHEN 2007 THEN E.cnt2007
				WHEN 2008 THEN E.cnt2008
				WHEN 2009 THEN E.cnt2009
			END AS NoOfOrders  FROM dbo.EmpYearOrders AS E CROSS JOIN (VALUES(2007),(2008),(2009)) AS Years(OrderYear)) AS D
WHERE NoOfOrders IS NOT NULL;

SELECT 
*
FROM DBO.EmpYearOrders
	UNPIVOT()
	