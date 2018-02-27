USE SQLCookbook;

--12.16

--12.13
select DEPTNO, JOB, sum(SAL), GROUPING_ID(DEPTNO, JOB), GROUPING(DEPTNO), GROUPING(JOB)
, case 
	   when GROUPING_ID(DEPTNO, JOB) = 0 then 'Total by dept + job' 
	   when GROUPING_ID(DEPTNO, JOB) = 1 then 'Total by dept' 
	   when GROUPING_ID(DEPTNO, JOB) = 2 then 'Total by job' 	   
	   when GROUPING_ID(DEPTNO, JOB) = 3 then 'grand Total' 
   end
from EMP as e
group by cube(DEPTNO, JOB)
order by GROUPING_ID(DEPTNO), GROUPING_ID(JOB) --DEPTNO, JOB

select DEPTNO, JOB, sum(SAL), GROUPING_ID(DEPTNO, JOB)
, case 
	   when GROUPING_ID(DEPTNO, JOB) = 0 then 'Total by dept + job' 
	   when GROUPING_ID(DEPTNO, JOB) = 1 then 'Total by dept' 
	   when GROUPING_ID(DEPTNO, JOB) = 2 then 'Total by job' 	   
	   when GROUPING_ID(DEPTNO, JOB) = 3 then 'grand Total' 
   end
from EMP as e
group by rollup(DEPTNO, JOB)
order by DEPTNO, JOB

--12.12
select case when job is null then 'total' else job end, sum(sal), GROUPING(job)
from EMP as e
group by
GROUPING sets((job), ());

select case when job is null then 'total' else job end, sum(sal), GROUPING(job)
from EMP as e
group by
rollup(job);


--12.11
;with cte as
(select DEPTNO, ENAME,  job, max(sal) as sal
from emp as e
group by DEPTNO, e.ENAME, e.EMPNO, JOB
)
select *
from cte as c
outer apply (select max(sal), min(sal) from emp where DEPTNO = c.DEPTNO) as a1(maxd,mind)
outer apply (select max(sal), min(sal) from emp where JOB = c.JOB) as a2(maxj,minj)
outer apply (values(case when c.sal = maxd then 'top sal in dept' when c.sal = mind then 'low sal in dept' end)) as a3(dept_status)
outer apply (values(case when c.sal = maxj then 'top sal in job' when c.sal = minj then 'low sal in job' end)) as a4(job_status)
order by DEPTNO, sal


--12.10
--vertical historgrams
select case when [10] is not null then '*' end, case when [20] is not null then '*' end, case when [30] is not null then '*' end
from
(select DEPTNO, ENAME, ROW_NUMBER() over(partition by DEPTNO order by(select null)) as rn
from EMP
)as base
pivot(max(ENAME) for deptno in ([10],[20],[30])) as pvt
order by 1 ,2,3

--12.9
--horizontal historgrams
;with cte as
(
select DEPTNO, COUNT(empno) as cnt
from EMP
group by DEPTNO
)
select * 
from cte as c
cross apply (select REPLICATE('*', cnt)) as a1(hist)

--12.8
--create 5 buckets with n rows 
select *, ntile(5) over(order by empno)
from emp as e

--create 5 buckets with n rows but the division of rows into the buckets is different and imo, wrong.
--find a better solution
select *, (ROW_NUMBER() over(order by empno)% 5) + 1 AS NTILE
from emp as e
ORDER BY empno

--12.7
--creates buckets with 5 rows each...the number of buckets could be 
select *,  CEILING(ROW_NUMBER() over (order by empno)/ 5.0)
from EMP as e

--12.6
select *, [20] - [10] 
from
(
select DEPTNO, sum(sal) as sal--, ROW_NUMBER() over(order by (select null)) as rn
from emp as e
group by DEPTNO ) base
pivot(max(sal) for deptno in([10],[20],[30])) as pvt;

--12.5
;with cte as
(
select *, row_number() over(partition by deptno order by ename) as rn
from EMP
)
select case when rn=1 then cte.DEPTNO  end, cte.ENAME
from cte
group by  cte.DEPTNO, cte.ENAME, rn	

--12.4
select a1.*
from emp as e
cross apply (values(e.ENAME),(JOB),(cast(EMPNO as varchar(max))),(' ')) as a1(emps)
where DEPTNO = 10

--12.3

select a1.*
from (values(10, 20, 30)) as v(cnt3, cnt5, cnt6)
cross apply (values(3,v.cnt3), (5,v.cnt5), (6,v.cnt6)) as a1(deptno, empCnt)


--12.2
--you have 2 columns and have more than one data value for a category column(either unique or non-unique values)
--then you have to add differentiating 'for' column. Add row_number 
select *
into #base
from (values('clerk','david'), ('clerk', 'david'), ('manager', 'david'), ('manager', 'bai'), ('manager', 'tom')) as v(job,ename)

--won't work
select [clerk], [manager] 
from #base
pivot(max(ename) for job in ([clerk], [manager])) as pvt

select *, ROW_NUMBER() over (partition by job order by (select null)) as rn
into #base1
from (values('clerk','david'), ('clerk', 'david'), ('manager', 'david'), ('manager', 'bai'), ('manager', 'tom')) as v(job,ename)

select [clerk], [manager] 
from #base1
pivot(max(ename) for job in ([clerk], [manager])) as pvt

select max(case when job='clerk' then ename end) as [clerk], max(case when job='manager' then ename end) as [manager]
from #base1
group by rn

--12.1
--we only need the categorical column and the values to spread column. So only 2 columns are needed for pivoting
--drop table #base
select *
into #base
from (values(10,3), (20,5), (30,6)) as v(value,cnt)

select [3] as [cnt3], [5] as [cnt5], [6] as [cnt6]
from #base
pivot(max(value) for cnt in ([3], [5], [6])) as pvt

select max(case when cnt=3 then value end) as cnt3, max(case when cnt=5 then value end) as cnt5, max(case when cnt=6 then value end) as cnt6
from #base

--11.12
select v.*, n, [verifiedDate], [shipped], nn
from (values(1,'19890101','19890103'), (2,'19890102','19890104'), (3,'19890103','19890105')) as v(id,ordDate,prcDate)
cross apply GetNums(1,3) as gn
outer apply (select dateadd(day,1,prcDate) as [verifiedDate] where n=2 or n=3) as a1([verifiedDate])
outer apply (select dateadd(day,1,[verifiedDate]) as [shipped] where n=3) as a2([shipped])
outer apply (values(case when n=2  then 22 end)) as a3(nn)
order by v.id, n

--11.11
select e.DEPTNO, e.ENAME, e.SAL, e.HIREDATE, first_VALUE(SAL) over(partition by deptno order by hiredate desc ) as latVal
	, last_VALUE(SAL) over(partition by deptno order by hiredate  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) as latVal1
from emp as e
order by DEPTNO

--11.10
select distinct e.JOB
from EMP as e

select e.JOB
from EMP as e
group by e.JOB

--11.8
;with cte as
(
select *, LEAD(sal) over(order by sal) as nxtSal,  lag(sal) over(order by sal) as prvSal
from EMP
)
select c.ENAME, c.SAL
		, case when nxtSal is null then min(sal) over() else nxtSal end as forward
		, case when prvSal is null then MAX(sal) over() else prvsal end as rewind
from cte as c

--11.7
with cte as
(select *, LEAD(sal) over(order by hiredate) as nxtSal
from emp
)
select * 
from cte 
where sal<nxtSal

;with cte as 
(select *, (select min(sal) from emp as e2 where e2.HIREDATE  = (select MIN(e1.HIREDATE) from EMP as e1 where e1.HIREDATE> e.HIREDATE)) as nxtSal
from emp as e
)
select * 
from cte 
where sal<nxtSal

--11.6
select *
from emp as e
where e.SAL in (select MIN(sal) from emp union select MAX(sal) from emp)

--11.4
;with v as 
(select * 
from (values(10,20), (20,10), (30,40), (80,130), (130,80), (5,5), (5,5)) as b(a,b)
)
select distinct v1.* 
from v as v1
inner join v as v2 on (v1.a=v2.b and v2.a=v1.b ) and v1.a <= v1.b

--11.3
;with b1
as
(select d.DNAME, d.LOC, d.DEPTNO from DEPT as d where d.DEPTNO in (30,40)
),
b2 as
(select e.ENAME, e.DEPTNO, d1.DNAME, d1.LOC
	from EMP as e
	inner join dept as d1 on d1.DEPTNO = e.DEPTNO
	where e.DEPTNO in (10,20)) 
select b2.ENAME, isnull(b2.DEPTNO,b1.DEPTNO), isnull(b1.DNAME, b2.DNAME), isnull(b1.LOC, b2.LOC)
from b1 full outer join  b2 on 1=0

--11.2
select *, (select COUNT(*) from emp as e1 where e1.JOB<=e.JOB) as rn
from emp as e
order by rn

--11.1
;with cte as
(select *, ROW_NUMBER() over (order by (select null)) as rn
from EMP
)
select * from cte
where cte.rn % 2 = 0

;with cte as
(select *, ROW_NUMBER() over (order by (select null)) as rn
from EMP
)
select * from cte
where cte.rn % 2 = 0

--10.5
;with cte as
(select *, ROW_NUMBER() over(order by sal) as rn
from emp
)
select *
from cte
order by rn
offset 0 rows fetch next 5 rows only;

;with cte as
(select *, ROW_NUMBER() over(order by sal) as rn
from emp
)
select top(5) *
from cte
order by rn

;with cte as
(select *, ROW_NUMBER() over(order by sal) as rn
from emp
)
select *
from cte
where rn between 1 and 5

--10.4
select gn.n as year, a1.cnt
from GetNums(1980,1989) as gn
outer apply (select count(EMPNO), year(HIREDATE) 
				from EMP where year(HIREDATE) = gn.n group by year(HIREDATE)) as  a1(cnt,year)

select gn.n as year, a1.cnt
from GetNums(1980,1989) as gn
outer apply (select count(EMPNO), year(HIREDATE) 
				from EMP where year(HIREDATE) = gn.n group by year(HIREDATE)) as  a1(cnt,year)

--10.3
--drop table t1; --delete from t1
--CREATE TABLE dbo.T1(projID int,startDate date, endDate date);
--INSERT INTO dbo.T1(projID, startDate, endDate)
--			  VALUES(1,'20070101','20070103')
--				   ,(2,'20070103','20070104')
--				   ,(3,'20070106','20070107')
--				   ,(4,'20070109','20070109')
--				   ,(5,'20070109','20070110');

--islands but now you want to have stand alone rows as well as infact that is also an island
;with base as
(
select *, row_number() over(order by endDate) as sortColumn
from T1
),
cte as
(
SELECT t1.projID, t1.startDate, t1.endDate, t1.sortColumn
	,case when lag(T1.endDate) over (order by T1.sortColumn) = T1.startDate then 0 else 1 end as flag
FROM base as T1
),
cte2 as
(
select c.projID, c.startDate, c.endDate, sum(c.flag) over(order by sortColumn) as grp
from cte as c
)
select MIN(startDate) as rangeFrom, max(endDate) as rangeTo
from cte2
group by grp


--islands but now you want to have stand alone rows as well as infact that is also an island
;with base as
(
select *, row_number() over(order by endDate) as sortColumn
from T1
),
cte as
(
SELECT t1.projID, t1.startDate, t1.endDate, t1.sortColumn, case when T2.projID is null then 1 else 0 end as flag
FROM base as T1--left outer join could also be moved to scalar subquery or cross apply
LEFT OUTER JOIN base AS T2 ON  (T1.startDate = T2.endDate) AND T1.startDate<T1.endDate
),
cte2 as
(
select c.projID, c.startDate, c.endDate, (select sum(b.flag) from cte as b where b.sortColumn <= c.sortColumn) as grp
--select shipDate as curr, dateadd(day, -1 * dense_rank() over(order by shipDate) , shipDate )as grp
from cte as c
)
select MIN(startDate) as rangeFrom, max(endDate) as rangeTo
from cte2
group by grp


--10.2
select DEPTNO, ENAME, SAL, HIREDATE, case when lead(sal) over(partition by deptno order by hiredate) is null then 'N/A' 
										else cast(sal - lead(sal) over(partition by deptno order by hiredate) as varchar(20))
									 end
from EMP

select DEPTNO, ENAME, SAL, HIREDATE, sal - (select min(e2.SAL) from emp as e2 where e2.DEPTNO = e.DEPTNO and  e2.HIREDATE = (select min(e1.HIREDATE) from emp as e1 where e.deptno = e1.DEPTNO and e1.HIREDATE > e.HIREDATE))
from EMP as e
order by DEPTNO

--10.1
--drop table t1
--CREATE TABLE dbo.T1(startDate date, endDate date);
--GO
--INSERT INTO dbo.T1(startDate, endDate) VALUES('20070101','20070103'),('20070103','20070104'),('20070106','20070107'),('20070109','20070109');
--drop table t1; delete from t1
--CREATE TABLE dbo.T1(projID int,startDate date, endDate date);
--INSERT INTO dbo.T1(projID, startDate, endDate)
			  --VALUES(1,'20070101','20070103')
				 --  ,(2,'20070103','20070104')
				 --  ,(3,'20070106','20070107')
				 --  ,(4,'20070109','20070109')
				 --  ,(5,'20070109','20070110');

				 --select cast('20070109'  as int)

--gaps..date ranges between consecutive projects

;with cte as
(SELECT t1.* 
FROM T1
inner JOIN T1 AS T2 ON T1.projID != T2.projID and (T1.endDate = T2.startDate or T1.startDate = T2.endDate) 
)
select *, lead(startDate) over(order by endDate)
from cte
order by endDate

--these are the projects which are not part of any 'consecutive project dates' islands
SELECT t1.*
FROM T1
where not exists (select * from T1 AS T2 where T1.projID != T2.projID and (T1.endDate = T2.startDate or T1.startDate = T2.endDate)) 

--islands...range of consecutive projects
SELECT t1.*
FROM T1
inner JOIN T1 AS T2 ON T1.projID != T2.projID and (T1.endDate = T2.startDate or T1.startDate = T2.endDate) 



--drop table t1
--CREATE TABLE dbo.T1(shipdate date);
--GO
--INSERT INTO dbo.T1(shipDate) VALUES('20070101'),('20070102'),('20070102'),('20070103'),('20070106'),('20070107'),('20070109'),('20070109');

--gaps
;with cte as
(
select shipDate as curr, lead(shipDate) over(order by shipDate) as nxt
from t1
)
select dateadd(day,1,curr) as rangeFrom, dateadd(day, -1, nxt) as rangeTo
from cte
where datediff(day, curr, nxt) > 1

--islands..note did not use row_number/rank as col1 might not be unique
;with cte as
(
select shipDate as curr, dateadd(day, -1 * dense_rank() over(order by shipDate) , shipDate )as grp
from t1
)
select MIN(curr) as rangeFrom, max(curr) as rangeTo
from cte
group by grp


--SET NOCOUNT ON;
--USE tempdb;
--drop table t1
--IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

--CREATE TABLE dbo.T1(col1 INT NOT NULL CONSTRAINT PK_T1 PRIMARY KEY);
--GO
--INSERT INTO dbo.T1(col1) VALUES(1),(2),(3),(7),(8),(9),(11),(15),(16),(17),(28);


--gaps
;with cte as
(
select col1 as curr, lead(col1) over(order by col1) as nxt
from t1
)
select curr +1 as rangeFrom, nxt -1 as rangeTo
from cte
where nxt - curr > 1

--islands..note did not use row_number/rank as col1 might not be unique
;with cte as
(
select col1 as curr, col1 - dense_rank() over(order by col1) as grp
from t1
)
select MIN(curr) as rangeFrom, max(curr) as rangeTo
from cte
group by grp




--9.12
;with CTE as
(select *
from emp as e
cross apply (values(MONTH(e.HIREDATE))) as a1(m)
cross apply (values(datename(DW,e.HIREDATE))) as a2(d)
)
select c1.ENAME, c2.ENAME
from CTE as c1
inner join  CTE as c2 on c2.EMPNO> c1.EMPNO and c2.d = c1.d and c2.m = c1.m

--where cnt>1

--9.10
select currentMonth, count(a2.EMPNO)
from (values(DATEFROMPARTS(1980,1,1))) as val1(startDate)
cross apply (values(DATEFROMPARTS(1983,02,1))) as val2(endDate)
cross apply GetNums(0,datediff(MONTH,startDate,endDate)) as gn
cross apply (values(DATEADD(MONTH,n,startDate))) as a1(currentMonth)
outer apply (select * from EMP as e where e.HIREDATE >= currentMonth and e.HIREDATE<DATEADD(MONTH,1,currentMonth)) as a2
group by currentMonth

--9.9
select m, qtr, qtrStart, qtrEnd
from (values(sysdatetime())) as val1(dt)
cross apply (values(year(dt))) as a0(y)
cross apply (values(month(dt))) as a1(m)
cross apply (values(m/3 + 1 )) as a2(qtr)
cross apply (values(DATEFROMPARTS(y,qtr,1))) as a3(qtrStart)
cross apply (values(dateadd(DAY,-1,dateadd(month,3,qtrStart)))) as a4(qtrEnd)

--9.8
select startValForEveryQtr, startQtr, endQtr--qrtStart, qrtEnd
from (values(sysdatetime())) as val1(dt)
cross apply (values(year(dt))) as val2(y)
cross apply (values(DATEFROMPARTS(y,1,1))) as a0(startVal)
cross apply GetNums(1,4) as gn
cross apply (values(dateadd(month,n*3,startVal))) as a1(startValForEveryQtr)
cross apply (values(dateadd(month,-3,startValForEveryQtr))) as a2(startQtr)
cross apply (values(dateadd(DAY,-1,startValForEveryQtr))) as a3(endQtr)


select qrtStart, qrtEnd
from (values(sysdatetime())) as val1(dt)
cross apply (values(year(dt))) as val2(y)
cross apply (values(DATEFROMPARTS(y,1,1))) as a0(temp)
cross apply GetNums(1,4) as gn
cross apply (values(dateadd(month,n*4,temp))) as a1(temp1)
cross apply (values(dateadd(month,-4,temp1))) as a2(qrtStart)
cross apply (values(DATEADD(day,-1,temp1))) as a3(qrtEnd)

--9.7
--use pivot to display calendar
select week, [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday]
from 
(select week, currentDate, weekdayName
	from (values(SYSDATETIME())) as v(today)
	cross apply (values(DATEFROMPARTS(YEAR(today),month(today),1))) as a1(startOfMonth)
	cross apply (values(DATEADD(month,1,startOfMonth))) as a2(startOfNextMonth)
	cross apply (select * from GetNums(0,DATEDIFF(day,startOfMonth,startOfNextMonth))) as gn(n)
	cross apply (values(DATEADD(day,gn.n,startOfMonth))) as a3(currentDate)
	cross apply (values(DATENAME(dw,currentDate))) as a4(weekdayName)
	cross apply (values(DATENAME(ISO_WEEK,currentDate))) as a5(week)
) as base
pivot(max(currentDate) for weekdayName in ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])) as pvt

--use CASE with GROUP BY to display calendar
select a5.week,
		max(case when weekdayName='Monday' then currentDate end) as 'Monday',
		max(case when weekdayName='Tuesday' then currentDate end) as 'Tuesday',
		max(case when weekdayName='Wednesday' then currentDate end) as 'Wednesday',
		max(case when weekdayName='Thursday' then currentDate end) as 'Thursday',
		max(case when weekdayName='Friday' then currentDate end) as 'Friday',
		max(case when weekdayName='Saturday' then currentDate end) as 'Saturday',
		max(case when weekdayName='Sunday' then currentDate end) as 'Sunday'
from (values(SYSDATETIME())) as v(today)
cross apply (values(DATEFROMPARTS(YEAR(today),month(today),1))) as a1(startOfMonth)
cross apply (values(DATEADD(month,1,startOfMonth))) as a2(startOfNextMonth)
cross apply (select * from GetNums(0,DATEDIFF(day,startOfMonth,startOfNextMonth))) as gn(n)
cross apply (values(DATEADD(day,gn.n,startOfMonth))) as a3(currentDate)
cross apply (values(DATENAME(dw,currentDate))) as a4(weekdayName)
cross apply (values(DATENAME(ISO_WEEK,currentDate))) as a5(week)
group by a5.week
--cross apply (values(case when weekdayName='Monday' then currentDate end)) as a5(Monday)


--9.5
--first and last friday in every month of a eyar
select y, nameOfMonth, nameOfDay,  min(currentDt) as firstFriday, max(currentDt) as lastFriday
from (values(2007)) as v(y)
cross apply (values('Friday')) as a1(dName)
cross apply (values(DATEFROMPARTS(y,1,1))) as a2(yearStart)
cross apply (values(DATEADD(year,1,yearStart))) as a3(nextYear)
cross apply (values(datediff(day,yearStart, nextYear))) as a4(noOfDays)
cross apply (select * from GetNums(1,noOfDays) as gn) as a5(n)
cross apply (values(dateadd(day,a5.n,yearStart))) as a6(currentDt)
cross apply (values(DATENAME(DW,currentDt))) as a7(nameOfDay)
cross apply (values(DATENAME(month,currentDt))) as a8(nameOfMonth)
where a7.nameOfDay = 'Friday'
group by y, nameOfMonth, nameOfDay

--9.4
select y, dateadd(day,a5.n,yearStart), datename(dw,dateadd(day,a5.n,yearStart)) 
from (values(2007)) as v(y)
cross apply (values('Friday')) as a1(dName)
cross apply (values(DATEFROMPARTS(y,1,1))) as a2(yearStart)
cross apply (values(DATEADD(year,1,yearStart))) as a3(nextYear)
cross apply (values(datediff(day,yearStart, nextYear))) as a4(noOfDays)
cross apply (select * from GetNums(1,noOfDays) as gn where datename(dw,dateadd(day,gn.n,yearStart)) = 'Friday') as a5(n)

--9.3
select dt, m, y, startMon, nextMOn, lastDayOfPrevMonth, startDay, endDay
from (values(SYSDATETIME())) as v(dt)
cross apply (values(month(dt))) as a1(m)
cross apply (values(year(dt))) as a2(y)
cross apply (values(DATEFROMPARTS(y,m,1))) as a3(startMon)
cross apply (values(DATEADD(month,1,startMon))) as a4(nextMOn)
cross apply (values(DATEADD(DAY,-1,nextMOn))) as a5(lastDayOfPrevMonth)
cross apply (values(datename(DW,startMon))) as a6(startDay)
cross apply (values(datename(DW,lastDayOfPrevMonth))) as a7(endDay)

--9.2
--using built in functions
select dt, isod, y, m, d, h, mint, sec
from (values(SYSDATETIME())) as v(dt)
cross apply (values(CONVERT(datetime2,dt,112))) as a1(isod)
cross apply (values(year(isod))) as a2(y)
cross apply (values(month(isod))) as a3(m)
cross apply (values(day(isod))) as a4(d)
cross apply (values(datepart(hour,isod))) as a5(h)
cross apply (values(datepart(minute,isod))) as a6(mint)
cross apply (values(datepart(SECOND,isod))) as a7(sec)

select dt, isod, SUBSTRING(isodChar,1,4) as y, SUBSTRING(isodChar,6,2) as m, SUBSTRING(isodChar,9,2) as d --and so on
from (values(SYSDATETIME())) as v(dt)
cross apply (values(CONVERT(datetime2,dt,126))) as a1(isod)
cross apply (values(cast(isod as varchar))) as a2(isodChar)

--9.1
select d, a1.yearStart, a2.nextYear, a3.numOfDays, case when numOfDays=366 then 'leap' else 'nonleap' end as 'isLeapOrNot'
from (values(SYSDATETIME())) as v(d)
cross apply (values(datefromparts(YEAR(d),1,1))) as a1(yearStart) 
cross apply (values(dateadd(year, 1, yearStart))) as a2(nextYear) 
cross apply (values(datediff(Day, a1.yearStart, a2.nextYear ))) as a3(numOfDays)

select *, ROW_NUMBER() over(order by (select null)) as rn
from EMP

--assume a unique column is present. What if not unique column is present to give number of rows before a particular row
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

--if no unique column is present, then add a new unique column that can support ordering which in turn
--would help decide the rows before or after a particular row
;with cte as
(select *
from EMP as e
cross apply (select newid()) as a(id)
)
select *, (select count(*)+1 from cte as c1 where c.id > c1.id) as rn
from cte as c
order by rn

;with cte as
(
select *
from EMP as e
cross apply (select count(*)from emp) as a(cnt)
cross apply (select * from GetNums(1,cnt)) as a1(n1)
cross apply (select * from GetNums(1,cnt)) as a2(n2)
)
select * --, (select count(case when n1>n2 then 1 else 0 end)) as a3(rwcnt)
from cte as c
cross apply (select * from cte as c1 where c.)


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
