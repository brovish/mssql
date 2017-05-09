USE "TSQL2012";
GO

--SELECT 1 AS n
--UNION ALL
--SELECT 2 
--UNION ALL
--SELECT 3 
--UNION ALL
--SELECT 4 
--UNION ALL
--SELECT 5 
--UNION ALL
--SELECT 6 
--UNION ALL
--SELECT 7 
--UNION ALL
--SELECT 8 
--UNION ALL
--SELECT 9 
--UNION ALL
--SELECT 10

--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2008,01,01) AND O.orderdate< DATEFROMPARTS(2008,02,01)
--EXCEPT
--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2008,02,01) AND O.orderdate< DATEFROMPARTS(2008,03,01)

--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2008,01,01) AND O.orderdate< DATEFROMPARTS(2008,02,01)
--INTERSECT 
--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2008,02,01) AND O.orderdate< DATEFROMPARTS(2008,03,01)

--(
--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2008,01,01) AND O.orderdate< DATEFROMPARTS(2008,02,01)

--INTERSECT 
--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2008,02,01) AND O.orderdate< DATEFROMPARTS(2008,03,01)
--)
--EXCEPT

--SELECT 
--O.custid,O.empid
--FROM Sales.Orders AS O
--WHERE O.orderdate>= DATEFROMPARTS(2007,01,01) AND O.orderdate< DATEFROMPARTS(2008,01,01)

SELECT country,region,city
FROM
	(
		SELECT 
		1 AS sortCOL,country,region,city
		FROM HR.Employees

		UNION ALL

		SELECT 
		2 AS sortCOL,country,region,city
		FROM Production.Suppliers
	) AS TE
ORDER BY TE.sortCOL,TE.country,TE.region,TE.city;

