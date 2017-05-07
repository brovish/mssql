USE [TSQL2012];
GO
--SELECT 
--O.empid, MAX(O.orderdate) AS maxorderdate
--FROM Sales.Orders AS O
--GROUP BY O.empid;

--SELECT 
--MO.empid, MO.maxorderdate, SO.orderid, SO.custid
--FROM (
--		SELECT 
--		O.empid, MAX(O.orderdate) AS maxorderdate
--		FROM Sales.Orders AS O
--		GROUP BY O.empid
--	 ) AS MO INNER JOIN Sales.Orders AS SO
--				ON SO.empid = MO.empid
--				AND SO.orderdate = MO.maxorderdate;

--SELECT 
--O.orderid, O.orderdate, O.custid, O.empid, ROW_NUMBER() OVER(ORDER BY O.orderdate,O.orderid) AS rownum
--FROM Sales.Orders AS O

--WITH MyCTE AS
--(
--	SELECT 
--	O.orderid, O.orderdate, O.custid, O.empid, ROW_NUMBER() OVER(ORDER BY O.orderdate,O.orderid) AS rownum
--	FROM Sales.Orders AS O
--)
--SELECT MyCTE.orderid, MyCTE.orderdate, MyCTE.custid, MyCTE.empid, MyCTE.rownum
--FROM MyCTE
--ORDER BY MyCTE.orderdate, MyCTE.orderid--SEE THE ORDER BY HERE IS IMPORTANT AS THE ORDER BY IN CTE IS ONLY USED FOR CTE, NOT THE OUTSIDE QUERY.
--OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

--WITH MYRECURISVECTE AS 
--(
--	SELECT 
--	E.empid, E.mgrid, E.firstname, E.lastname
--	FROM HR.Employees AS E
--	WHERE E.empid = 9

--	UNION ALL

--	SELECT 
--	E.empid, E.mgrid, E.firstname, E.lastname
--	FROM MYRECURISVECTE AS ME INNER JOIN HR.Employees AS E
--	ON E.empid = ME.mgrid

--)
--SELECT 
--*
--FROM MYRECURISVECTE;

--CREATE VIEW Sales.VEmpOrders 
--AS
--	SELECT 
--	O.empid, YEAR(O.orderdate) AS orderyear, SUM(OD.qty) AS qty
--	FROM Sales.Orders AS O INNER JOIN Sales.OrderDetails AS OD
--		ON O.orderid = OD.orderid
--		GROUP BY O.empid, YEAR(O.orderdate)
--		--ORDER BY O.empid, YEAR(O.orderdate);
--GO

--SELECT 
--*
--FROM Sales.VEmpOrders
--ORDER BY empid, orderyear;


