use SQLCookbook;
go

--this takes a long time. took more than 10 minutes 30 secs to return 100000000 rows with parallelism
DBCC FREEPROCCACHE() ;
DBCC DROPCLEANBUFFERS ;
GO
SET STATISTICS TIME ON ;
GO
SET STATISTICS IO ON ;
GO
--this took 150 ms with parallelism and without ordering
;with cte as
(
select num
from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as b(num)
),
cte2 as 
(
select concat(c1.num, c2.num) as num
from cte as c1 cross apply cte as c2 
),
cte3 as 
(
select concat(c1.num, c2.num) as num
from cte2 as c1 cross apply cte2 as c2 
),
cte4 as 
(
select concat(c1.num, c2.num) as num
from cte3 as c1 cross apply cte3 as c2 
)
select /*top(100)*/ *
from cte4
--order by num
--OPTION	(MAXDOP 1)

--this takes a long time. took more than 10 minutes 30 secs to return 100000000 rows with parallelism
DBCC FREEPROCCACHE() ;
DBCC DROPCLEANBUFFERS ;
GO
SET STATISTICS TIME ON ;
GO
SET STATISTICS IO ON ;
GO
--this took 150 ms with parallelism and without ordering
;with cte as
(
select num
from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as b(num)
),
cte2 as 
(
select concat(c1.num, c2.num) as num
from cte as c1 cross apply cte as c2 
),
cte3 as 
(
select concat(c1.num, c2.num) as num
from cte2 as c1 cross apply cte2 as c2 
),
cte4 as 
(
select concat(c1.num, c2.num) as num
from cte3 as c1 cross apply cte3 as c2 
)
select /*top(100)*/ *
from cte4
--order by num
OPTION	(MAXDOP 1)


DBCC FREEPROCCACHE() ;
DBCC DROPCLEANBUFFERS ;
GO
SET STATISTICS TIME ON ;
GO
SET STATISTICS IO ON ;
GO
--this took 150 ms with parallelism and without ordering
;with cte as
(
select num
from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as b(num)
),
cte2 as 
(
select concat(c1.num, c2.num) as num
from cte as c1 cross apply cte as c2 
),
cte3 as 
(
select concat(c1.num, c2.num) as num
from cte2 as c1 cross apply cte2 as c2 
),
cte4 as 
(
select concat(c1.num, c2.num) as num
from cte3 as c1 cross apply cte3 as c2 
)
select top(100) *
from cte4
--order by num
--OPTION	(MAXDOP 1)


DBCC FREEPROCCACHE() ;
DBCC DROPCLEANBUFFERS ;
GO
SET STATISTICS TIME ON ;
GO
SET STATISTICS IO ON ;
GO
--this took 14 secs with parallelism and with ordering
;with cte as
(
select num
from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as b(num)
),
cte2 as 
(
select concat(c1.num, c2.num) as num
from cte as c1 cross apply cte as c2 
),
cte3 as 
(
select concat(c1.num, c2.num) as num
from cte2 as c1 cross apply cte2 as c2 
),
cte4 as 
(
select concat(c1.num, c2.num) as num
from cte3 as c1 cross apply cte3 as c2 
)
select top(100) *
from cte4
order by num
--OPTION	(MAXDOP 1)

DBCC FREEPROCCACHE() ;
DBCC DROPCLEANBUFFERS ;
GO
SET STATISTICS TIME ON ;
GO
SET STATISTICS IO ON ;
GO
--this took 1 minute 8 secs with no parallelism
;with cte as
(
select num
from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as b(num)
),
cte2 as 
(
select concat(c1.num, c2.num) as num
from cte as c1 cross apply cte as c2 
),
cte3 as 
(
select concat(c1.num, c2.num) as num
from cte2 as c1 cross apply cte2 as c2 
),
cte4 as 
(
select concat(c1.num, c2.num) as num
from cte3 as c1 cross apply cte3 as c2 
)
select top(100) *
from cte4
order by num
OPTION	(MAXDOP 1)




--1 from
--2 where
--3 group by
--4 having
--5 select 
--	expressions
--	distinct
--6 order by
--7 top/offset-fetch
