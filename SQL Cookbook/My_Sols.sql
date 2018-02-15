USE SQLCookbook;

select *, ROW_NUMBER() over(order by (select null)) as rn
from EMP

--assume a unique column is present. What if not unique column is present to give row number without unique ordering
--(like we specify SELECT NULL in ORDER by for ROW_NUmber).
select *, (select count(*)+1 from emp as e1 where e.EMPNO > e1.EMPNO)
from EMP as e

--assumes unique column present to provide ordering.
select e.*, COUNT(e1.EMPNO) + 1
from EMP as e
left outer join emp as e1 on e.EMPNO>e1.EMPNO
group by e.EMPNO, e.ENAME, e.JOB, e.MGR, e.HIREDATE, e.SAL, e.COMM, e.DEPTNO

--if no unique column is present. then does not work as shown below
select *, (select count(*)+1 from emp as e1 where e.DEPTNO > e1.DEPTNO)
from EMP as e


--newid() does not seem to work with row_number to give a random ordering for each execution
select *, ROW_NUMBER() over(order by (select null)) as rn
from EMP

select *, ROW_NUMBER() over(order by (select 1)) as rn
from EMP

select *, ROW_NUMBER() over(order by (select sysdatetime())) as rn
from EMP

select *, ROW_NUMBER() over(order by (select newid())) as rn
from EMP

select TOP(3) *
from EMP
order by (select null)

select TOP(3) *
from EMP
order by (select 1)

select TOP(3) *
from EMP
order by (select sysdatetime())

select TOP(3) *
from EMP
order by (select newid())

--new column

--8.7
select e.HIREDATE as currEmpHireDate, Prev.hiredate
from EMP as e
outer apply (select max(e1.HIREDATE) as prevEmpHireDate from emp as e1 where e.HIREDATE> e1.HIREDATE) as Prev(hiredate)

select e.HIREDATE as currEmpHireDate, Max(e1.HIREDATE)
from EMP as e
left outer join EMP as e1 on e.HIREDATE > e1.HIREDATE
group by e.EMPNO, e.HIREDATE

--8.3
declare @date1 as datetime = '19900101'
declare @date2 as datetime = '19900120'

--currentDate is a date value between start and finish
select  sum(case when DATENAME(DW,currentDate) not in ('Saturday', 'Sunday') then 1 else 0 end) as noOfWorkDays
from dbo.GetNums(0,DATEDIFF(day,@date1, @date2)-1) as Num
cross apply (select DATEADD(day,n,@date1)) as Dates(currentDate)

--create index idx_median on dbo.Transactions(actid,val);

SELECT  distinct actid, 
		PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY val) OVER (PARTITION BY actid) AS MEDIAN
FROM dbo.Transactions as t
order by actid

;with c as
(
SELECT actid, COUNT(VAL) AS cnt, (COUNT(*)-1)/2 AS ov, 2-count(*)%2 as fv
FROM Transactions AS T
GROUP BY actid
)
select c.actid, avg(1. * a.val) as median
from c
cross apply(select * from dbo.Transactions as t 
			where t.actid = c.actid
			order by val
			offset c.ov rows fetch next c.fv rows only) as a
group by c.actid
order by actid

--running total with window function
select empid, ordermonth, qty, SUM(qty) over(partition by empid order by ordermonth rows between unbounded preceding and current row) as runqty
from dbo.EmpOrders

--running total with scalar sub query
select empid, ordermonth, qty, (select sum(qty) from dbo.EmpOrders as e1 where e1.empid=e.empid and e1.ordermonth <= e.ordermonth) as runqty
from dbo.EmpOrders as e

--running total with scalar inner join
select e.empid, e.ordermonth, e.qty, sum(e1.qty) as runqty
from dbo.EmpOrders as e
inner join dbo.EmpOrders as e1 on e1.empid=e.empid and e1.ordermonth <= e.ordermonth
group by e.empid, e.ordermonth, e.qty
order by e.empid, e.ordermonth


--running total with window function
select actid, tranid, val, SUM(val) over(partition by actid order by tranid rows between unbounded preceding and current row) as balance
from dbo.Transactions

--running total with scalar sub query
select actid, tranid, val, (select SUM(val) from dbo.Transactions as t1 where t1.actid =t.actid and t1.tranid<=t.tranid) as balance
from dbo.Transactions as t

--running total with scalar inner join
select t.actid, t.tranid, t.val, sum(t1.val) as balance
from dbo.Transactions as t
inner join dbo.Transactions as t1 on t1.actid =t.actid and t1.tranid<=t.tranid
group by t.actid, t.tranid, t.val
--order by e.empid, e.ordermonth


--7.6
--running total with window function
select 
e.ENAME, sum(SAL) over(order by  empno) as runningtotal
from emp as e

--running total with scalar sub query
select 
e.ENAME, (select SUM(sal) from emp as e1 where e1.EMPNO <= e.EMPNO) as runningtotal
from emp as e

--running total with scalar inner join
select 
e.ENAME, sum(e1.SAL) as runningtotal
from emp as e
inner join emp as e1 on e1.EMPNO<=e.EMPNO
group by e.EMPNO, e.ENAME
order by e.EMPNO


--7.1
select AVG(sal), ROW_NUMBER() over(partition by deptno order by sum(sal)) as rn
		--,ROW_NUMBER() over(partition by deptno order by sal) as rn1 --can't do 
		--, lag(sal) over(partition by deptno order by sum(sal)) as previousRow --can't do this
from emp
group by DEPTNO, JOB


--6.15
--parse IP addresses 100
;with base as
(
select * 
from (values('10.12.32.2'), ('33.41.432.1')) as b(s)
),
splits as
(
select *, SUBSTRING(base.s, n , CHARINDEX('.', base.s + '.', n+1) -n) as element, ROW_NUMBER() over (partition by base.s order by n) as rn
from base
cross apply (select * from GetNums(1, len(base.s)) as gn 
				where gn.n = CHARINDEX('.', '.' + base.s , n)) as num(n)
)
select [1] as a, [2] as b, [3] as c, [4] as d
from (select s,element,rn from splits) as base
pivot(min(element) for rn in([1],[2],[3],[4])) as pvt

--6.14

--get the third delimited string
;with base as
(
select * 
from (values('rost,post'), ('gajer,hornak,were')) as b(s)
),
splits as
(
select *, SUBSTRING(base.s, n , CHARINDEX(',', base.s + ',', n+1) -n) as element, ROW_NUMBER() over (partition by base.s order by n) as rn
from base
cross apply (select * from GetNums(1, len(base.s)) as gn 
				where gn.n = CHARINDEX(',', ',' + base.s , n)) as num(n)
)
select * 
from splits
where rn = 3

--6.13

--xml trick to concatenate
;with base as
(
select * 
from (values('adams10'), ('1010'), ('asan')) as b(s)
)
,splits as
(
select *, SUBSTRING(base.s, n, 1) as element
from base
cross apply GetNums(1, len(base.s)) as gn
)
--concatenate the split back, this time filtering only numerics
SELECT (SELECT '' + B.element FROM splits AS B WHERE B.s = A.s and b.element like '[0-9]' FOR XML PATH ('')) as concatstr
FROM splits AS A
GROUP BY a.s
having (SELECT '' + B.element FROM splits AS B WHERE B.s = A.s and b.element like '[0-9]' FOR XML PATH ('')) is not null

--string_agg(sqlserver 2017) to concatenate
;with base as
(
select * 
from (values('adams10'), ('1010'), ('asan')) as b(s)
)
,splits as
(
select *, SUBSTRING(base.s, n, 1) as element
from base
cross apply GetNums(1, len(base.s)) as gn
)
--concatenate ;the split back, this time filtering only numerics
SELECT STRING_AGG(element,'') within group (order by getdate()) as concatstr
FROM splits AS A
where a.element like '[0-9]'
GROUP BY a.s

--6.12 
;with base as
(
select * 
from (values('adams'), ('allen')) as b(s)
),
splits as
(select *, SUBSTRING(base.s, n, 1) as element
from base
cross apply GetNums(1,len(base.s)) as gn
)--now concat the sorted strings
SELECT  (SELECT '' + B.element FROM splits AS B WHERE B.s = A.s ORDER BY b.element FOR XML PATH ('')) as concatstr
FROM splits AS A
GROUP BY a.s


;with base as
(
select * 
from (values('adams'), ('allen')) as b(s)
),
splits as
(select *, SUBSTRING(base.s, n, 1) as element
from base
cross apply GetNums(1,len(base.s)) as gn
)--concat sorted string with inbuilt func
select STRING_AGG(element,'') within group (order by element asc)
from splits
group by s

--6.11 string split to individual entries 

--using cross apply (atleast sql server 2005)
select id, arr, n as indexpos, SUBSTRING(arr, n, CHARINDEX(',', arr + ',', n) - n) as element
from (values('a','6,55,2'), ('b','5,44,6'), ('c','21')) as base(id,arr)
cross apply (select n from GetNums(1,len(base.arr)) as num where num.n = CHARINDEX(',', ',' + base.arr, num.n)  ) as a

--generic string split function using cross apply(to be used before sql2016)
go
drop function if exists my_string_split
go
create function my_string_split(@str as varchar(max), @sep as char(1)) 
returns table
as
return
	select SUBSTRING(@str, n, CHARINDEX(@sep, @str + @sep, n) - n) as element
	from (select n from GetNums(1,len(@str)) as num where num.n = CHARINDEX(@sep, @sep + @str, num.n)  ) as a
go

select id, arr, sp.element
from (values('a','6,55,2'), ('b','5,44,6'), ('c','21')) as base(id,arr)
cross apply my_string_split(base.arr, ',') as sp
	
--string_split in sql2016
select *
from (values(1), (3), (4)) as b(n)
where b.n in (select * from string_split('1,2,3', ','))

--GET A COMMA SEPARATED LIST OF VALUES IN A COLUMN. CANT USE PIVOT. POSSIBLE SOLUTIONS INCLUDE USE OF CURSOR, 'FOR XML PATH('')', RECURSIVE CTE(WOULD GET VERY SLOW AS DEPTH INCREASES), (CAN YOU DO THIS USING CROSS APPLY?) 
--AND IN SQL SERVER 2017 USE STRING_AGG

--REQUIRES SQL SERVER 2017
--;WITH CTE AS
--(
--SELECT * 
--FROM (VALUES('LAPTOP', 'DELL<'), ('LAPTOP', 'HP'), ('LAPTOP', 'COMPAQ'), ('MAC', 'APPLE')) AS P(PR, SUPP)
--)
--SELECT A.PR, STRING_AGG(SUPP, ',') WITHIN GROUP (ORDER BY Name ASC) AS Departments
--FROM CTE AS A
--GROUP BY PR; 


;WITH CTE AS
(
SELECT * 
FROM (VALUES('LAPTOP', 'DELL<'), ('LAPTOP', 'HP'), ('LAPTOP', 'COMPAQ'), ('MAC', 'APPLE')) AS P(PR, SUPP)
)
SELECT A.PR, STUFF((SELECT ',' + B.SUPP FROM CTE AS B WHERE B.PR = A.PR ORDER BY SUPP FOR XML PATH ('')), 1, 1, '')Columns
FROM CTE AS A
GROUP BY PR; 

--USING RECURSIVE CTE
;WITH CTE AS
(
SELECT * 
FROM (VALUES('LAPTOP', 'DELL<'), ('LAPTOP', 'HP'), ('LAPTOP', 'COMPAQ'), ('MAC', 'APPLE')) AS P(PR, SUPP)
)
,CTE1 AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY PR ORDER BY SUPP) AS RN
FROM CTE
),
RECURSIVECTE AS
(
SELECT PR, CAST(CONCAT(SUPP, '') AS VARCHAR) AS LIST, RN
FROM CTE1
WHERE RN = 1
UNION ALL
SELECT R.PR, CAST(CONCAT(R.LIST, ',' + C.SUPP) AS VARCHAR) AS LIST , C.RN
FROM RECURSIVECTE AS R
INNER JOIN CTE1 AS C ON C.RN = R.RN + 1 AND R.PR = C.PR
)
, REVERSEORDER AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY PR ORDER BY RN DESC) AS REVERSEORDERING
FROM RECURSIVECTE
)
SELECT *
FROM REVERSEORDER 
WHERE REVERSEORDERING = 1



--6.8
SELECT S
FROM (VALUES('ABCD'), ('CDAB'), ('CDAA'), ('CDZZ')) AS V(S)
ORDER BY SUBSTRING(S,LEN(S)-1 , 2)

--6.3
DECLARE @STR AS VARCHAR(10) = '10,CLARK,MANAGER';

--COUNT OCCURENCES OF A CHARACTER IN A STRING USING CROSS APPLY MIMICKING A LOOP
SELECT SUM(CASE WHEN SUBSTRING(@STR, S.N, 1) = ',' THEN 1 ELSE 0 END) AS TOTALOCCURENCES
FROM (VALUES(1)) AS DUMMY(D)
CROSS APPLY (SELECT * FROM GetNums(1, LEN(@STR))) AS S(N)


--COUNT OCCURENCES OF A CHARACTER IN A STRING USING USING RECURSIVE CTE MIMICKING A LOOP
DECLARE @STARTPOS AS INT = 1;

;WITH CTER
AS(
SELECT CASE WHEN SUBSTRING(@STR, @STARTPOS, 1) = ',' THEN 1 ELSE 0 END AS S, @STARTPOS AS L
UNION ALL
SELECT CASE WHEN SUBSTRING(@STR, L + 1 , 1) = ',' THEN 1 ELSE 0 END AS S, L + 1 
FROM CTER AS R
WHERE SUBSTRING(@STR, L + 1 , 1) <> ''
)
SELECT SUM(S) AS TOTALOCCURENCES
FROM CTER

GO
--6.1

--USING CROSS APPLY WITH GETNUMS
DECLARE @STR AS VARCHAR(10) = 'KINGS';

SELECT SUBSTRING(@STR, S.N, 1) AS S
FROM (VALUES(1)) AS DUMMY(D)
CROSS APPLY (SELECT * FROM GetNums(1, LEN(@STR))) AS S(N)

SELECT SUBSTRING(@STR, S.N, LEN(@STR)) AS S, SUBSTRING(@STR, LEN(@STR) - S.N  + 1, S.N) AS P 
FROM (VALUES(1)) AS DUMMY(D)
CROSS APPLY (SELECT * FROM GetNums(1, LEN(@STR))) AS S(N)

GO

--USING RECURSIVE CTE
DECLARE @STR AS VARCHAR(10) = 'KINGS';
DECLARE @STARTPOS AS INT = 1;

;WITH CTER
AS(
SELECT SUBSTRING(@STR, @STARTPOS, 1) AS S, @STARTPOS AS L
UNION ALL
SELECT SUBSTRING(@STR, L + 1 , 1) AS S, L + 1 
FROM CTER AS R
WHERE SUBSTRING(@STR, L + 1 , 1) <> ''
)
SELECT *
FROM CTER


SELECT SUBSTRING('', 1, 1)

--4.16
--;WITH CTE1 AS 
--(SELECT *
--	FROM (VALUES(1,'A',100), (2,'A',200), (3,'B',300)) AS MyEmp(EmpID,DeptName,Salary)
--)
--DELETE FROM CTE1
--WHERE EmpID = 1

--3.10
SELECT *
FROM EMP AS E
WHERE E.COMM < (SELECT COMM FROM EMP AS E1 WHERE E1.ENAME='WARD') OR E.COMM IS NULL

--3.9--emp_bonus table was not in DDL scripts
;WITH CTE1 AS 
(SELECT *
	FROM (VALUES(1,'A',100), (2,'A',200), (3,'B',300)) AS MyEmp(EmpID,DeptName,Salary)
),
CTE2 AS 
(
SELECT *
	FROM (VALUES(1,10), (1,20), (2, 30)) AS MyBonus(EmpID, BonusAmount)
)
--,CTE3 AS 
--(
--SELECT EmpID, DeptName, SUM(Salary) OVER(PARTITION BY DeptName) AS SALARYSUM
--FROM CTE1 
--)
,CTE4 AS 
(
SELECT EmpID, SUM(BonusAmount) AS SUMBONUS
FROM CTE2
GROUP BY EmpID
)
SELECT *
FROM CTE1
LEFT OUTER JOIN CTE4 ON CTE1.EmpID = CTE4.EmpID



SELECT *, CAST(CONCAT(A.A,B.B) AS INT) + 1 AS NUM FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS A(A)  
CROSS JOIN (SELECT * FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS CP(A)) AS B(B)


--3.8
SELECT E.ENAME, D.LOC
FROM EMP AS E
INNER JOIN DEPT AS D ON D.DEPTNO = E.DEPTNO
WHERE E.DEPTNO=10

--3.7
SELECT * FROM (VALUES(1),(1),(2)) AS TBL(A) EXCEPT SELECT * FROM (VALUES(1),(2)) AS TBL2(A) 
SELECT * FROM (VALUES(1),(2)) AS TBL2(A) EXCEPT SELECT * FROM (VALUES(1),(1),(2)) AS TBL(A) 


SELECT BB0.CARDINALITY, BB.DATA
FROM
(	SELECT CASE WHEN COUNT(NUM) >1 THEN 'DIFFERENT CARDINALITY' ELSE 'SAME CARDINALITY' END AS CARDINALITY
	FROM (
	SELECT COUNT(*)
	FROM EMP AS E
	UNION
	SELECT COUNT(*)
	FROM DEPT AS D
	) AS B(NUM)
) AS BB0(CARDINALITY)
CROSS APPLY (
SELECT CASE WHEN COUNT(NUM) >1 THEN 'DIFFERENT DEPTNOs' ELSE 'SAME DEPTNOs' END AS [DATA]
FROM (
SELECT DEPTNO
FROM EMP AS E
INTERSECT
SELECT DEPTNO
FROM DEPT AS D
) AS B(NUM)
) AS BB([DATA])

--3.6
--IN-EFFICIENT AS TABLE DEPT WILL BE SCANNED AS MANY AS THE NUMBER OF ROWS IN EMP TABLE
SELECT E.EMPNO, (SELECT DEPT.DNAME FROM DEPT WHERE DEPT.DEPTNO = E.DEPTNO) AS [DEPTNO]
FROM EMP AS E

SELECT E.EMPNO, d.DNAME
FROM EMP AS E
INNER JOIN DEPT AS D ON D.DEPTNO = E.DEPTNO

--3.5
SELECT DEPT.*
FROM DEPT
LEFT OUTER JOIN EMP ON EMP.DEPTNO = DEPT.DEPTNO
WHERE EMP.EMPNO IS NULL

--3.4
SELECT *
FROM DEPT
WHERE DEPTNO NOT IN (SELECT DEPTNO FROM EMP);

SELECT V FROM (VALUES(1)) AS B(V)
WHERE V NOT IN (SELECT V FROM (VALUES(3),(4),(NULL)) AS D(V));
--1 NOT IN(3,4,NULL)
--NOT (1==3 OR 1==4 OR 1==NULL)
--NOT (FALSE AND FALSE AND UNKNOWN)
--TRUE AND TRUE AND UNKNOWN
--NOT TRUE

SELECT V FROM (VALUES(1)) AS B(V)
WHERE V IN (SELECT V FROM (VALUES(1),(NULL)) AS D(V));
--1 IN(1,NULL)
--(1==1 OR 1==NULL)
--TRUE OR UNKNOWN
--TRUE

SELECT V FROM (VALUES(1)) AS B(V)
WHERE NOT EXISTS (SELECT * FROM (VALUES(3),(4),(NULL)) AS D(V) WHERE D.V=B.V);

--2.7
SELECT ENAME, DEPTNO
FROM EMP
WHERE EMP.DEPTNO = 10
UNION ALL
SELECT '------', NULL
UNION ALL
SELECT DNAME, DEPTNO
FROM DEPT

select * from (values(1),(1),(2)) as tbl(a) union all select * from (values(2),(3)) as tbl2(a) 

--2.6
SELECT *
FROM EMP
ORDER BY CASE WHEN JOB = 'SALESMAN' THEN COMM ELSE SAL END, COMM;

--2.5
SELECT *
FROM EMP
ORDER BY CASE WHEN COMM IS NOT NULL THEN 0 ELSE 1 END, COMM;

SELECT *
FROM EMP
ORDER BY CASE WHEN COMM IS NOT NULL THEN 0 ELSE 1 END, COMM DESC;

SELECT *
FROM EMP
ORDER BY CASE WHEN COMM IS NOT NULL THEN 1 ELSE 0 END, COMM ;

SELECT *
FROM EMP
ORDER BY CASE WHEN COMM IS NOT NULL THEN 1 ELSE 0 END, COMM DESC;

--2.4
;WITH CTE AS
(SELECT CONCAT(E.ENAME, ' ', E.DEPTNO) AS D
FROM EMP AS E
)
,CTE2 AS (
SELECT *
FROM CTE AS C 
CROSS APPLY string_split(C.D, ' ') AS SP
)
,CTE3 AS
(
SELECT D, [0] AS DEPTNO, [1] AS [NAME]
FROM (SELECT CTE2.D, CTE2.value, CASE WHEN ISNUMERIC(CTE2.value) = 0 THEN 1 ELSE 0 END AS IsNumber FROM CTE2) AS BASE
PIVOT(MAX(BASE.VALUE) FOR IsNumber IN ([1],[0])) AS PVT
)
SELECT *
FROM CTE3
ORDER BY DEPTNO



SELECT JOB
FROM EMP AS E
group by JOB
ORDER BY max(sal)

SELECT E.ENAME
FROM EMP AS E
--ORDER BY 1-- THIS IS REFERRING THE COLUMN 1 IN THE SELECT LIST(E.ENAME), NOT THE COLUMN 1 FROM THE UNDERLYING TABLE AS THE OUTPUT OF SELECT IS INPUT OF ORDER BY
--ORDER BY E.JOB-- EVEN IF THE COLUMN IS NOT SELECT LIST WE CAN STILL REFER TO COLUMNS INT ROWSET THAT FORMS THE INPUT TO ORDER BY UNLESS DISTINCT IS USED IN SELECT
--ORDER BY (SELECT NULL)
--ORDER BY (SELECT 234 AS T)--can use any value here to get random records...
--ORDER BY (SELECT NEWID())--have a to use a value that changes each time it is called to get random values for each run AND THERE IS NO ORDER TO VALUES GENERATED
--ORDER BY (SELECT SYSDATETIME())--THERE IS AN IMPLICIT ORDER IN USING DATATIME VALUES. THE ORDER WILL REMAIN SAME FOR EACH RUN. SO THE ROWS FETCHED CANNOT BE GUURANTEED TO BE NOT THE SAME
ORDER BY NEWID()--THERE IS AN IMPLICIT ORDER IN USING DATATIME VALUES. THE ORDER WILL REMAIN SAME FOR EACH RUN. SO THE ROWS FETCHED CANNOT BE GUURANTEED TO BE NOT THE SAME
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

SELECT TOP(5) *
FROM EMP;

SELECT *
FROM EMP AS E
--ORDER BY (SELECT NULL)
ORDER BY (SELECT 234 AS T)--can use any value here to get random records...
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--SELECT 'TT' + NULL
SELECT CONCAT('TT', NULL)




--CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
--AS
--RETURN
--  WITH
--    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
--    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
--    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
--    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
--    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
--    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
--    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
--            FROM L5)
--  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
--  FROM Nums
--  ORDER BY rownum;
--GO
