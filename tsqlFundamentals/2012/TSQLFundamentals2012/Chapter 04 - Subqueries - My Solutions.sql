USE TSQL2012;

--IF OBJECT_ID('DBO.ORDERS','U') IS NOT NULL DROP TABLE DBO.ORDERS
--CREATE TABLE DBO.ORDERS
--(
--orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY
--);

--INSERT INTO dbo.ORDERS(orderid)
--	SELECT O.orderid
--	FROM Sales.Orders AS O
--	WHERE O.orderid % 2 = 0;

--SELECT 
--N.n
--FROM dbo.Nums AS N LEFT OUTER JOIN DBO.ORDERS AS O
--	ON N.n = O.orderid
--WHERE N.n BETWEEN (SELECT MIN(OI.orderid) FROM dbo.ORDERS AS OI) AND (SELECT MAX(OI.orderid) FROM dbo.ORDERS AS OI)
--	AND O.orderid IS NULL;

--DROP TABLE dbo.ORDERS;

--SELECT 
--* 
--FROM Sales.Orders AS O1
--WHERE orderid = (SELECT MAX(O2.orderid) FROM Sales.Orders AS O2 WHERE O2.custid = O1.custid)

--SELECT 
--*
--FROM Sales.Orders AS O1
--WHERE O1.orderdate = (SELECT MAX(O2.orderdate) FROM Sales.Orders AS O2)


--SELECT 
--O.custid, O.orderid,O.orderdate,O.empid 
--FROM Sales.Orders AS O
--WHERE O.custid IN (SELECT TOP(1) WITH TIES O2.custid 
--					FROM Sales.Orders AS O2
--					GROUP BY O2.custid
--					ORDER BY COUNT(*) DESC)

--SELECT
-- H.empid, H.firstname,H.lastname--, O.orderdate
--FROM HR.Employees AS H
--WHERE H.empid NOT IN(SELECT O.empid FROM Sales.Orders AS O WHERE O.orderdate >= '20080501')

--SELECT 
--DISTINCT C.country
--FROM Sales.Customers AS C
--WHERE C.country NOT IN (SELECT E.country FROM HR.Employees AS E )


--SELECT
--O1.custid, O1.orderid,O1.orderdate,O1.empid
--FROM Sales.Orders AS O1
--WHERE O1.orderdate  = (SELECT 
--						MAX(O2.orderdate)
--						FROM Sales.Orders AS O2 
--						WHERE O2.custid = O1.custid						
--						)
--ORDER BY O1.custid


--SELECT 
--*
--FROM Sales.Customers AS C
--WHERE C.custid IN (SELECT O.custid FROM Sales.Orders AS O WHERE O.custid = C.custid AND O.orderdate >= '20070101' AND O.orderdate < '20080101')
--AND C.custid NOT IN (SELECT O.custid FROM Sales.Orders AS O WHERE O.custid = C.custid AND O.orderdate >= '20080101' AND O.orderdate < '20090101' )

--SELECT 
--DISTINCT C.custid,C.companyname
--FROM Sales.Customers AS C INNER JOIN Sales.Orders AS O
--ON C.custid = O.custid INNER JOIN Sales.OrderDetails AS OD
--ON OD.orderid = O.orderid AND OD.productid=12

SELECT
CO.custid, CO.ordermonth,qty,(SELECT SUM(CO1.qty) 
								FROM Sales.CustOrders AS CO1 
								WHERE CO1.ordermonth <= CO.ordermonth AND CO1.custid = CO.custid ) AS runqty 
FROM Sales.CustOrders AS CO
ORDER BY CO.custid, CO.ordermonth

