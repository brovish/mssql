USE "TSQL2012";

--SELECT 
--SO.orderid, SO.orderdate, SO.custid, SO.empid
--FROM Sales.Orders AS SO
--WHERE SO.orderdate >= '20070601' AND SO.orderdate < '20070701'

--SELECT 
--SO.orderid, SO.orderdate, SO.custid, SO.empid
--FROM Sales.Orders AS SO
--WHERE SO.orderdate = EOMONTH(SO.orderdate)

--SELECT 
--HRE.empid, HRE.firstname, HRE.lastname
--FROM HR.Employees AS HRE
--WHERE HRE.lastname LIKE '%[a]%[a]%'

--SELECT 
--HRE.empid, HRE.firstname, HRE.lastname
--FROM HR.Employees AS HRE
--WHERE HRE.lastname LIKE '%[a]%[a]%'

----THIS IS BETTER AS IT CAN BE PARAMETERIZED
--SELECT 
--HRE.empid, HRE.firstname, HRE.lastname
--FROM HR.Employees AS HRE
--WHERE LEN(HRE.lastname) - LEN(REPLACE(HRE.lastname,'a','')) >= 2 

--SELECT 
--SOD.orderid, SUM(SOD.qty * SOD.unitprice) AS totalvalue
--FROM Sales.OrderDetails AS SOD
--GROUP BY SOD.orderid
--HAVING SUM(SOD.qty * SOD.unitprice)>10000
--ORDER BY totalvalue DESC

--SELECT 
--SORD.shipcountry, AVG(SORD.freight) AS avgfreight
--FROM Sales.Orders AS SORD
--WHERE SORD.orderdate >= '20070101' AND SORD.orderdate< '20080101'
--GROUP BY SORD.shipcountry
--ORDER BY avgfreight DESC
--OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

--SELECT 
--SORD.custid, SORD.orderdate,SORD.orderid,ROW_NUMBER() OVER(PARTITION BY SORD.custid ORDER BY SORD.orderdate, SORD.orderid)
--FROM Sales.Orders AS SORD
--ORDER BY SORD.custid

--SELECT
--E.empid,E.firstname,E.lastname,E.titleofcourtesy, 
--CASE  E.titleofcourtesy
--	WHEN 'Ms.' THEN 'Female'
--	WHEN 'MRs.' THEN 'Female'
--	WHEN 'Mr.' THEN 'Male'
--	ELSE 'Unknown'
--END
--FROM HR.Employees AS E

SELECT
C.custid, C.region
FROM SALES.Customers AS C
ORDER BY C.region


