USE tempdb;

SET NOCOUNT ON;
SET STATISTICS IO ON;
--IF OBJECT_ID(N'DBO.ORDERS', N'U') IS NOT NULL DROP TABLE dbo.ORDERS
--IF OBJECT_ID(N'dbo.CUSTOMERS', N'U') IS NOT NULL DROP TABLE dbo.CUSTOMERS

--CREATE TABLE dbo.CUSTOMERS
--(
--	CUSTID CHAR(5) NOT NULL,
--	CITY VARCHAR(10) NOT NULL,
--	CONSTRAINT PK_CUSTOMERS PRIMARY KEY(CUSTID)
--);


--CREATE TABLE dbo.ORDERS
--(
--	ORDERID INT NOT NULL,
--	CUSTID CHAR(5) NULL,
--	CONSTRAINT PK_ORDERS PRIMARY KEY(ORDERID),
--	CONSTRAINT FK_ORDERS_CUSTOMERS FOREIGN KEY(CUSTID)
--		REFERENCES DBO.CUSTOMERS(CUSTID)
--);


--INSERT INTO dbo.CUSTOMERS(CUSTID,CITY)
--VALUES
--  ('FISSA', 'Madrid'),
--  ('FRNDO', 'Madrid'),
--  ('KRLOS', 'Madrid'),
--  ('MRPHS', 'Zion'  );

--  INSERT INTO dbo.Orders(orderid, custid) VALUES
--  (1, 'FRNDO'),
--  (2, 'FRNDO'),
--  (3, 'KRLOS'),
--  (4, 'KRLOS'),
--  (5, 'KRLOS'),
--  (6, 'MRPHS'),
--  (7, NULL   );

--SELECT 
--C.CUSTID, COUNT(O.ORDERID)
--FROM dbo.CUSTOMERS AS C
--LEFT OUTER JOIN dbo.ORDERS AS O
--	ON C.CUSTID = O.CUSTID
--WHERE C.CITY = N'MADRID'
--GROUP BY C.CUSTID
--HAVING COUNT(*) < 3

----JUST MUCKING AROUND...NOT THE SOLUTION!
--SELECT 
--*
--FROM dbo.CUSTOMERS AS C
--WHERE C.CITY = N'MADRID' AND (SELECT COUNT(*) FROM dbo.ORDERS AS O WHERE O.CUSTID = C.CUSTID ) < 3

--SELECT DISTINCT
--*, rank() OVER(order by CUSTID)
--FROM dbo.Orders AS O
--WHERE CUSTID IS NOT NULL;


--WITH MY_CTE AS
--(
--SELECT DISTINCT
--CUSTID
--FROM dbo.Orders AS O
--WHERE CUSTID IS NOT NULL
--order by CUSTID 
--)
--SELECT MY_CTE.CUSTID, rank() OVER(order by CUSTID)
--FROM MY_CTE;

--select 
--*
--from dbo.CUSTOMERS cross join dbo.ORDERS

--except

--select
--*
--from dbo.CUSTOMERS cross apply (select null as ass from ORDERS where 1=0 )as a;
use TSQLV3;
--select
--empid,YEAR(orderdate), SUM(val)
--from TSQLV3.Sales.OrderValues
--group by empid, year(orderdate)

--SELECT orderid, custid,
--  COUNT(*) OVER(PARTITION BY custid) AS numordersforcust
--FROM Sales.Orders
--WHERE shipcountry = N'Spain'
--ORDER BY numordersforcust DESC;

(select * from (values(1),(1)) as tbl(a)
)--union 
except
(select * from (values(2),(3)) as tbl2(a)
)
order by 1




