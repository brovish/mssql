--select top 10 *, ROW_NUMBER() over (order by (select null))
--from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t1(n)
--cross join (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t2(n)
--cross join (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t3(n)
--cross join (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t4(n)
--cross join (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t5(n)
--cross join (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t6(n)
--cross join (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as t7(n)

--;with cte(n) as
--(
--select 1
--union all
--select n+1
--from cte
--where n< 2
--)
--select *
--from cte



--select *, case when n=1 then 'aaho' else 'jaande' end as nn
--from (values(1),(2)) as a(n)

--select *
--from (values(1),(2)) as a(n)
--cross apply (values(case when a.n=1 then 'aaho' else 'jaande' end )) as b(nn)

--select *
--from (values(1),(2)) as a(n)
--cross apply (select case when a.n=1 then 'aaho' else 'jaande' end as nn) as b(nn)


--select *
--from (values(1,'19890101'), (2,'19890102'), (3,'19890103')) as v(id,orderdate)
--outer apply (values(1),(2),(3)) as num(n)
--outer apply(select DATEADD(day,1,orderdate) as verifieddata where n=2 or n=3) as a1(verifieddata)
--use tempdb;
--create table t
--( col1 int identity(1,1));
--go

--insert into t default values;
--go 10

--select * from t;
--select STRING_AGG(col1,',') from t;

--;with cte as
--(
--select *, ROW_NUMBER() over(order by col1) as rn
--from t
--)
--,
--recurCTE as
--(
--select cast(col1 as varchar(max)) as list, rn
--from cte where rn =1
--union all
--select CONCAT(r.list, c.col1) as list, c.rn
--from recurCTE as r
--inner join CTE as c on c.rn = r.rn + 1
--)
--,
--recurinvCTE as
--(
--select cast(col1 as varchar(max)) as list, rn
--from cte where rn =10
--union all
--select CONCAT(r.list, c.col1) as list, c.rn
--from recurinvCTE as r
--inner join CTE as c on c.rn = r.rn - 1
--)
--select * from recurinvCTE
--union all
--select * from recurCTE

----CONCATENATE COLUMN VALUES TO A LIST USING XML PATH
----Note: SPECIAL XML CHARACTERS LIKE ‘<’ WILL BE ENCODED. Workaround given in T-SQL querying.
--;WITH CTE AS
--(
--SELECT * 
--FROM (VALUES('LAPTOP', 'DELL<'), ('LAPTOP', 'HP'), ('LAPTOP', 'COMPAQ'), ('MAC', 'APPLE')) AS P(PR, SUPP)
--)
--SELECT A.PR, STUFF((SELECT ',' + B.SUPP FROM CTE AS B WHERE B.PR = A.PR ORDER BY SUPP FOR XML PATH ('')), 1, 1, '')
--FROM CTE AS A
--GROUP BY PR;



----REQUIRES SQL SERVER 2017. Handles special XML characters
--;WITH CTE AS
--(
--SELECT * 
--FROM (VALUES('LAPTOP', 'DELL<'), ('LAPTOP', 'HP'), ('LAPTOP', 'COMPAQ'), ('MAC', 'APPLE')) AS P(PR, SUPP)
--)
--SELECT A.PR, STRING_AGG(SUPP, ',') WITHIN GROUP (ORDER BY SUPP ASC) AS List
--FROM CTE AS A
--GROUP BY PR;


--;with base as
--(
--select * from (values(23),(24),(25),(26),(27),(28)) as b(val)
--)
--SELECT STRING_AGG(val, ',') WITHIN GROUP (ORDER BY val desc) AS List
--FROM base as a

;with cte as
(
select 'ab,bc,cd,d' as list
)
select * from cte cross apply string_split(list,',') 

--substring(list, n, charindex(',', arr, n))
;with cte as
(
select 'ab,bc,cd,d' as list
)
select list, n, substring(list, n, charindex(',', list+',', n)-n) as ch
from cte cross apply dbo.GetNums(1,LEN(list)) 
--from cte cross apply (select n from dbo.GetNums(1,LEN(list)) where n = CHARINDEX(',',',' + list,n)) as b(n)
cross apply (select case when )

;with cte(id,arr) as
(
select * from (values('a','6,55,2'), ('b','5,44,6'), ('c','21')) as base(id,arr)
)
select id, arr, n as indexpos, SUBSTRING(arr, n, CHARINDEX(',', arr + ',', n) - n) as element
from cte as base
cross apply (select n from GetNums(1,len(base.arr)) as num where num.n = CHARINDEX(',', ',' + base.arr, num.n)  ) as a

------------------------------------------------------------------------------------------------------------------
use MyDB;
--O: Gaps and islands
create table tbl(col1 int not null primary key)
go

insert into tbl values(1),(2),(3),(5),(6),(8),(9),(11),(13);

--gaps
with cte as
(select col1 as curr, LEAD(col1) over(order by col1) as nxt
from tbl
)
select curr + 1 as gapStartsFrom, nxt - 1 as gapEndsAt
from cte
where nxt - curr >1

--islands
with cte as
(
select col1 as curr, col1 - DENSE_RANK() over(order by col1) as grp, DENSE_RANK() over(order by col1) as dn
from tbl
)
select MIN(curr) as islandStart, max(curr) as islandEnd
from cte
group by grp






