---------------------------------------------------------------------
-- Microsoft SQL Server 2012 T-SQL Fundamentals
-- Chapter 03 - Joins
-- Solutions
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1 
-- 1-1 
-- Write a query that generates 5 copies out of each employee row
-- Tables involved: TSQL2012 database, Employees and Nums tables

--Desired output
empid       firstname  lastname             n
----------- ---------- -------------------- -----------
1           Sara       Davis                1
2           Don        Funk                 1
3           Judy       Lew                  1
4           Yael       Peled                1
5           Sven       Buck                 1
6           Paul       Suurs                1
7           Russell    King                 1
8           Maria      Cameron              1
9           Zoya       Dolgopyatova         1
1           Sara       Davis                2
2           Don        Funk                 2
3           Judy       Lew                  2
4           Yael       Peled                2
5           Sven       Buck                 2
6           Paul       Suurs                2
7           Russell    King                 2
8           Maria      Cameron              2
9           Zoya       Dolgopyatova         2
1           Sara       Davis                3
2           Don        Funk                 3
3           Judy       Lew                  3
4           Yael       Peled                3
5           Sven       Buck                 3
6           Paul       Suurs                3
7           Russell    King                 3
8           Maria      Cameron              3
9           Zoya       Dolgopyatova         3
1           Sara       Davis                4
2           Don        Funk                 4
3           Judy       Lew                  4
4           Yael       Peled                4
5           Sven       Buck                 4
6           Paul       Suurs                4
7           Russell    King                 4
8           Maria      Cameron              4
9           Zoya       Dolgopyatova         4
1           Sara       Davis                5
2           Don        Funk                 5
3           Judy       Lew                  5
4           Yael       Peled                5
5           Sven       Buck                 5
6           Paul       Suurs                5
7           Russell    King                 5
8           Maria      Cameron              5
9           Zoya       Dolgopyatova         5

(45 row(s) affected)

-- Solution
SELECT E.empid, E.firstname, E.lastname, N.n
FROM HR.Employees AS E
  CROSS JOIN dbo.Nums AS N 
WHERE N.n <= 5
ORDER BY n, empid;

-- 1-2  (Optional, Advanced)
-- Write a query that returns a row for each employee and day 
-- in the range June 12, 2009 – June 16 2009.
-- Tables involved: TSQL2012 database, Employees and Nums tables

--Desired output
empid       dt
----------- -----------------------
1           2009-06-12 00:00:00.000
1           2009-06-13 00:00:00.000
1           2009-06-14 00:00:00.000
1           2009-06-15 00:00:00.000
1           2009-06-16 00:00:00.000
2           2009-06-12 00:00:00.000
2           2009-06-13 00:00:00.000
2           2009-06-14 00:00:00.000
2           2009-06-15 00:00:00.000
2           2009-06-16 00:00:00.000
3           2009-06-12 00:00:00.000
3           2009-06-13 00:00:00.000
3           2009-06-14 00:00:00.000
3           2009-06-15 00:00:00.000
3           2009-06-16 00:00:00.000
4           2009-06-12 00:00:00.000
4           2009-06-13 00:00:00.000
4           2009-06-14 00:00:00.000
4           2009-06-15 00:00:00.000
4           2009-06-16 00:00:00.000
5           2009-06-12 00:00:00.000
5           2009-06-13 00:00:00.000
5           2009-06-14 00:00:00.000
5           2009-06-15 00:00:00.000
5           2009-06-16 00:00:00.000
6           2009-06-12 00:00:00.000
6           2009-06-13 00:00:00.000
6           2009-06-14 00:00:00.000
6           2009-06-15 00:00:00.000
6           2009-06-16 00:00:00.000
7           2009-06-12 00:00:00.000
7           2009-06-13 00:00:00.000
7           2009-06-14 00:00:00.000
7           2009-06-15 00:00:00.000
7           2009-06-16 00:00:00.000
8           2009-06-12 00:00:00.000
8           2009-06-13 00:00:00.000
8           2009-06-14 00:00:00.000
8           2009-06-15 00:00:00.000
8           2009-06-16 00:00:00.000
9           2009-06-12 00:00:00.000
9           2009-06-13 00:00:00.000
9           2009-06-14 00:00:00.000
9           2009-06-15 00:00:00.000
9           2009-06-16 00:00:00.000

(45 row(s) affected)

-- Solution
SELECT E.empid,
  DATEADD(day, D.n - 1, '20090612') AS dt
FROM HR.Employees AS E
  CROSS JOIN Nums AS D
WHERE D.n <= DATEDIFF(day, '20090612', '20090616') + 1
ORDER BY empid, dt;

-- 2
-- Return US customers, and for each customer the total number of orders 
-- and total quantities.
-- Tables involved: TSQL2012 database, Customers, Orders and OrderDetails tables

--Desired output
custid      numorders   totalqty
----------- ----------- -----------
32          11          345
36          5           122
43          2           20
45          4           181
48          8           134
55          10          603
65          18          1383
71          31          4958
75          9           327
77          4           46
78          3           59
82          3           89
89          14          1063

(13 row(s) affected)

-- Solution
SELECT C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
WHERE C.country = N'USA'
GROUP BY C.custid;

-- 3
-- Return customers and their orders including customers who placed no orders
-- Tables involved: TSQL2012 database, Customers and Orders tables

-- Desired output
custid      companyname     orderid     orderdate
----------- --------------- ----------- ------------------------
85          Customer ENQZT  10248       2006-07-04 00:00:00.000
79          Customer FAPSM  10249       2006-07-05 00:00:00.000
34          Customer IBVRG  10250       2006-07-08 00:00:00.000
84          Customer NRCSK  10251       2006-07-08 00:00:00.000
...
73          Customer JMIKW  11074       2008-05-06 00:00:00.000
68          Customer CCKOT  11075       2008-05-06 00:00:00.000
9           Customer RTXGC  11076       2008-05-06 00:00:00.000
65          Customer NYUHS  11077       2008-05-06 00:00:00.000
22          Customer DTDMN  NULL        NULL
57          Customer WVAXS  NULL        NULL

(832 row(s) affected)

-- Solution
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid;

-- 4
-- Return customers who placed no orders
-- Tables involved: TSQL2012 database, Customers and Orders tables

-- Desired output
custid      companyname
----------- ---------------
22          Customer DTDMN
57          Customer WVAXS

(2 row(s) affected)

-- Solution
SELECT C.custid, C.companyname
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderid IS NULL;

-- 5
-- Return customers with orders placed on Feb 12, 2007 along with their orders
-- Tables involved: TSQL2012 database, Customers and Orders tables

-- Desired output
custid      companyname     orderid     orderdate
----------- --------------- ----------- -----------------------
66          Customer LHANT  10443       2007-02-12 00:00:00.000
5           Customer HGVLZ  10444       2007-02-12 00:00:00.000

(2 row(s) affected)

-- Solution
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20070212';

-- 6 (Optional, Advanced)
-- Return customers with orders placed on Feb 12, 2007 along with their orders
-- Also return customers who didn't place orders on Feb 12, 2007 
-- Tables involved: TSQL2012 database, Customers and Orders tables

-- Desired output
custid      companyname     orderid     orderdate
----------- --------------- ----------- -----------------------
72          Customer AHPOP  NULL        NULL
58          Customer AHXHT  NULL        NULL
25          Customer AZJED  NULL        NULL
18          Customer BSVAR  NULL        NULL
91          Customer CCFIZ  NULL        NULL
...
33          Customer FVXPQ  NULL        NULL
53          Customer GCJSG  NULL        NULL
39          Customer GLLAG  NULL        NULL
16          Customer GYBBY  NULL        NULL
4           Customer HFBZG  NULL        NULL
5           Customer HGVLZ  10444       2007-02-12 00:00:00.000
42          Customer IAIJK  NULL        NULL
34          Customer IBVRG  NULL        NULL
63          Customer IRRVL  NULL        NULL
73          Customer JMIKW  NULL        NULL
15          Customer JUWXK  NULL        NULL
...
21          Customer KIDPX  NULL        NULL
30          Customer KSLQF  NULL        NULL
55          Customer KZQZT  NULL        NULL
71          Customer LCOUJ  NULL        NULL
77          Customer LCYBZ  NULL        NULL
66          Customer LHANT  10443       2007-02-12 00:00:00.000
38          Customer LJUCA  NULL        NULL
59          Customer LOLJO  NULL        NULL
36          Customer LVJSO  NULL        NULL
64          Customer LWGMD  NULL        NULL
29          Customer MDLWA  NULL        NULL
...

(91 row(s) affected)

-- Solution
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
    AND O.orderdate = '20070212';

-- 7 (Optional, Advanced)
-- Return all customers, and for each return a Yes/No value
-- depending on whether the customer placed an order on Feb 12, 2007
-- Tables involved: TSQL2012 database, Customers and Orders tables

-- Desired output
custid      companyname     HasOrderOn20070212
----------- --------------- ------------------
1           Customer NRZBB  No
2           Customer MLTDN  No
3           Customer KBUDE  No
4           Customer HFBZG  No
5           Customer HGVLZ  Yes
6           Customer XHXJV  No
7           Customer QXVLA  No
8           Customer QUHWH  No
9           Customer RTXGC  No
10          Customer EEALV  No
...

(91 row(s) affected)

-- Solution
SELECT DISTINCT C.custid, C.companyname, 
  CASE WHEN O.orderid IS NOT NULL THEN 'Yes' ELSE 'No' END AS [HasOrderOn20070212]
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
    AND O.orderdate = '20070212';
