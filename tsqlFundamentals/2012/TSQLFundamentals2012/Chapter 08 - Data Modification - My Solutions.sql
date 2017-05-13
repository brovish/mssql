USE [TSQL2012];
GO

--IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;

--CREATE TABLE dbo.Customers
--(
--  custid      INT          NOT NULL PRIMARY KEY,
--  companyname NVARCHAR(40) NOT NULL,
--  country     NVARCHAR(15) NOT NULL,
--  region      NVARCHAR(15) NULL,
--  city        NVARCHAR(15) NOT NULL  
--);

--INSERT INTO dbo.Customers(custid,companyname,country,region,city)
--VALUES
--	(100,N'Coho Winery', N'USA', N'WA', N'Redmond');

--INSERT INTO dbo.Customers(custid,companyname,country,region,city)
--	SELECT 
--	C.custid,C.companyname,C.country,C.region,C.city
--	FROM Sales.Customers AS C INNER JOIN Sales.Orders AS O
--		ON C.custid = O.custid
--	GROUP BY C.custid,C.companyname,C.country,C.region,C.city;
	
----THIS IS THE STANDARD WAY TO DO IT(BU USING 'USING' CLAUSE)
--INSERT INTO dbo.Customers(custid,companyname,country,region,city)
--	SELECT 
--	C.custid,C.companyname,C.country,C.region,C.city
--	FROM Sales.Customers AS C
--	WHERE EXISTS( SELECT * FROM Sales.Orders AS O
--		WHERE C.custid = O.custid);

--IF OBJECT_ID('dbo.Orders','U') IS NOT NULL
--	DROP TABLE dbo.Orders;

--SELECT * 
--INTO dbo.Orders
--	FROM Sales.Orders AS O
--	WHERE O.orderdate >= '2006-01-01' AND O.orderdate < '2009-01-01';

--DELETE FROM dbo.Orders 
--	OUTPUT deleted.orderid, deleted.orderdate
--	WHERE dbo.Orders.orderdate < '2006-08-01'

--DELETE FROM dbo.Orders 
--	WHERE dbo.Orders.custid IN (SELECT C.custid FROM Sales.Customers AS C WHERE C.country = 'Brazil')

--ANOTHER WAY OF DOING SAME...
--DELETE FROM dbo.Orders 
--	WHERE EXISTS (SELECT * FROM Sales.Customers AS C WHERE C.custid = Orders.custid AND C.country = 'Brazil')

--SELECT 
--*
--FROM dbo.Customers

--UPDATE dbo.Customers
--	SET region = '<None>'
--	OUTPUT  inserted.custid, deleted.region AS oldregion, inserted.region AS newregion
--	WHERE region IS NULL;

