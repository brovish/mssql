USE TSQL2012

--IF OBJECT_ID('dbo.DIGITS','U') IS NOT NULL DROP TABLE dbo.DIGITS
--CREATE TABLE dbo.DIGITS
--(
--digit INT NOT NULL PRIMARY KEY
--)

--INSERT INTO dbo.DIGITS(digit)
--VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)

--SELECT 
--*, (D1.digit*100 + D2.digit*10 + D3.digit) + 1 AS Num
--FROM dbo.DIGITS AS D1 CROSS JOIN dbo.DIGITS AS D2 CROSS JOIN dbo.DIGITS AS D3
--ORDER BY Num


--SELECT 
--E.empid, E.firstname,E.lastname, N.n
--FROM HR.Employees AS E CROSS JOIN dbo.Nums AS N 
--WHERE N.n<6
--ORDER BY N.n, E.empid

--SELECT 
--E.empid, N.n, DATEADD(DAY,N.n,'20090611')
--FROM HR.Employees AS E CROSS JOIN dbo.Nums AS N 
--WHERE N.n<6
--ORDER BY E.empid 

----I WOULD HAVE TAKEN THIS QUERY AS THE CORRECT ONE AS THE PROBLEM STATEMENT ASKS FOR RETURNING USA CUSTOMERS
----AND I TAKE THAT STATEMENT TO MEAN 'ALL USA CUSTOMERS'..SO USING A LEFT OUTER JOIN MAKES SENSE HERE.
--SELECT
--C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
--FROM Sales.Customers AS C
--	LEFT OUTER JOIN (
--	 Sales.Orders AS O INNER JOIN Sales.OrderDetails AS OD
--	 ON O.orderid = OD.orderid
--	 ) 
--ON C.custid = O.custid
--WHERE C.country = 'USA'
--GROUP BY C.custid

--SELECT
--C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
--FROM Sales.Customers AS C
--	INNER JOIN Sales.Orders AS O
--		ON C.custid = O.custid
--	INNER JOIN Sales.OrderDetails AS OD
--		ON O.orderid = OD.orderid  
--WHERE C.country = 'USA'
--GROUP BY C.custid


SELECT
C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
FROM Sales.Customers AS C
	INNER JOIN Sales.Orders AS O
		ON C.custid = O.custid
	INNER JOIN Sales.OrderDetails AS OD
		ON O.orderid = OD.orderid  
WHERE C.country = 'USA'
GROUP BY C.custid

