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

SELECT
O.custid,O.orderid, O.qty, () AS diffprev, () AS diffnext
FROM dbo.Orders AS O

