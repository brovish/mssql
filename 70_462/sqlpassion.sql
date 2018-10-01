--questions: 
--1) in case of a non-unique nci, the CI key is also stored in the index pages/nonleaf pages(it would be stored in leaf page 
--anyways). What happens if the non-unique nci is on a heap. Is the RID stored in the non-leaf pages? What happens in case of non-unique CI?
--2) i thought the CI defined order of rows was reflected by slot array not by the actual physical order of rows on the page. 
--so the data should not have been physically ordered on individual pages but should have let the slot indexes define the order. But my testing show the rows are
--actually being stored physically ordered on the page.
--3)forwarding records/pointer. Issue with heap tables(why not an issue with B-Tree tables?). why are forwarding records not used in CIs?
--What happens in the case of CI tables? I think in case of CIs, we get page splits
--4) external fragmentation. Are we just referring to extents being physically out of order or only the pages. because if a page split happens, 
--in a, say a filled extent, then that page is never going to be in physical order no matter the extent allocated to hold it is phyically contigous
--or not. Even if a unfilled extent(some free pages) exists and is contigous, linked list of pages will physically be out of order(logical order would 
--be maintained because, well, it is a linked list). If it is the extent ordering that is being considered, then in that case even when entering 
--new data(no page splits), the extents being allocated for holding new pages might not be contigous. So does that also count as external 
--fragmentation
--5) why does SERIALIZABLE isolation level requires NCI to use KEY RANGE LOCKING. Why cant it use a CI. When no NCI is present S lock are used on individual rows and when more than 5000 S locks are taken on rows, an S
--table lock is taken(individual shared locks won't prevent the phantom rows anyway).
--6) does a temp table creation in a sp invalidates all the sps in plan cache as the db schema is changed?
--7)when a on disk work table is used, say for when hastable is spilled onto tempdb, why does it is show up as logical reads against the 'worktable' instead of 
--physical reads?
--8) Aren't columnstore indexes similar to NCI on that column(albeit NCI also stores RID or CI key)?
--9)--If using FULL recovery model, take regular tran log backups as otherwise the tran log will keep on growing? Why does not the tran log keeps
--on growing when using SIMPLE recovery? Take into account the data and log files while talking about recovery models.

--todo: 1. I need a good story explaining right from how sql server finds which pages or extents are free, their allocation to an table(heap or otherwise). how sql server decides 
--which pages have some free space and thus can be used and if not how are new pages/extents allocated.
--2. good story about query compilation. parse->expression tree->compilation to execution plan using COM objects(operators). You can refer to an
--invalid table in a proc and it will throw an error during runtime but not the case with query. It seems query fails at the parsing step. why?
--wasn't parsing supposed to check only syntax as it happens in case of a PROC?
--3. good story about bookmark lookup(RID lookup for heap and CI key for b-tree) and tying in with stats(bookmark lookup always uses NESTED LOOP JOIN). Also a good story for physical JOIN operators 
-- with stats influence. Also, differentiate between index benefits(seeks into the b-tree) vs stats(cardinality estimation). index also creates stats but stats can also be created(either automatically or 
--manually) independently of indexes. columns used in predicate are good candidates for stats. You can also create multi col stats either through a multi col index or auto/manual created stats but 
--the histogram will only be created for leading col while the density vector would have info for leading col as well as col combination. Stats loose their accuracy(even when kept updated) as the table
--data grows as the histogram can only have 200 steps
--4. Good story around data and log files while talking about recovery models

--tatt: 1. pagesplit cause both internal(always) and external fragmentation(not always but often as the new page might not be physically adjacent). 
--internal fragmentation is when we have free space in a page and it cause either by deletions or by page splits or by setting a fill factor.external 
--fragmentation is a bigger problem in heaps if we have ncis on the heap as we have to update RowIDs. In case of CI, there is no change to index 
--key and hence no change to nci. Also, defragmenting heaps is a problem if we have ncis on it due to the same reason as nci has to be rebuild as well.
--external fragmentation is bad because you have to do random io instead of sequential io and more head movements are involved. Internal fragmentation
--is bad because pages are not filled competely and thus you do more io to read the same amount of data.
--2. row size is limited to 8000 kb if using fixed length type(int, char). you can exceed the 8000 byte limit during table creation using var length data types
--but then if the 2 things could happen. page splits or the creation of 'ROW_OVERFLOW_DATA' allocation unit.  if the row size remains less than 8000
--, then if a page is full and you are trying to add more data to a var col, a page split will occur. But if the row size tself becomes greater than 8000
--by addition of var col, then 'ROW_OVERFLOW_DATA' allocation unit would be used.
--3. Locks provide transactional consitency and synchronize access to data at the relational level(row or table) while latches synchronize access to data structures(pages) between threads
--4. The difference of the recovery model (full/Simple) is how SQL Server deals with the clearing of the transaction log.

create database testdb
go

use testdb
go
create table tbl
(
	firstname char(50),
	lastname char(50),
	address char(100)
)
go

insert into tbl values
('ramneek','singh','sdfdsghgfh 32 esdfsdf,ewr')
go 2


dbcc traceon(3604)--need for dbcc page command
--find which data pages belong to our tbl. columns PageFID and PagePID.
--this will return 2 pages: IAM page with pagetype 10 and data page
dbcc ind(testdb,tbl,-1)

--remember page header size is 96 bytes, then we have payload and then the rowoffset array(aslot array).
--row offset array need 2 bytes to store location for each record
--dump the first data page using FID(FileID) and PID(PageID) of the page. First record in data pages are at offset 96
dbcc page(testdb,1,312,3)
dbcc page(testdb,1,312,1)
dbcc page(testdb,1,312,2)

--u can also use the dmf dm_db_index_physical_stats to get similar info
SELECT
    [index_depth],
    [index_level],
    [page_count],
    [record_count],
	*
FROM sys.dm_db_index_physical_stats (DB_ID (N'testdb'), OBJECT_ID (N'tbl'), -1, 0, 'DETAILED');
GO

use master
go
drop database testdb
go

dbcc traceon(3604)
go

/* both GAM and SGAM use bit 1 for denoting free but how can we tell if a uniform extent has free page?:
current use of extent| GAM bit setting| SGAM bit setting
---------------------  ---------------  ----------------
free, not in use		1				0

uniform extent			0				0
or full mixed extent

mixed extent with		0				1
free pages

*/
--1rst interval. GAM page records which extents have been allocated for any type of use. 1 for extent that is free and 0 for in use.
--excluding the page header and other overhead, it has about 8000 bytes or 64000 bits for use or. that means it can store usage for 64000 extents 
--or for 512000 pages or about 4 gb of memory. So 1 GAM page bitmaps' extents totalling about 4 GB of memory. So when our database file is larger than
--4 GB, SQL server needs multiple GAM pages. First GAM page is always the 3rd page and the next is after 511230 pages(about 4 GB)
--gam(1:2)
--dumping out GAM page which is always the 3 page from start(page id is 0 based, so we pass 2) and the display mode is 3 for database tpc_e
dbcc page(tpc_e,1,2,3)

--A SGAM page again looks after 4 GB of memory. It records which extents are used as mixed extents and have atleast 1 unused page(how do we track 
--which uniform extents have free pages?). If bit is 1, that extent is a mixed extent and has free a page. If 0, the extent either is not a mixed 
--extent or is a mixed extent with no free pages. First SGAM page is always the 4rd page and the next is after 511230 pages(about 4 GB)
--sgam(1:3)
--dumping out SGAM page which is always the 4 page from start(page id is 0 based, so we pass 3) and the display mode is 3 for database tpc_e
dbcc page(tpc_e,1,3,3)

--2nd interval. the second GAM and SGAM page occurs after 511230 pages from the first one.
dbcc page(tpc_e,1,511232,3)

dbcc page(tpc_e,1,511233,3)


create database allocationuntis
go

use allocationuntis
go

create table t
(
firstname char(50),
lastname char(50),
address char(100),
dob date
)
go

select *
from sys.tables

select *
from sys.all_columns as i
where i.object_id = object_id('t')

--metadata about a heap as well is stored in a table called index. But its type would be marked as heap
select *
from sys.indexes as i
where i.object_id = object_id('t')

--sql server always creates  1 partition for your table. note that we did not specify a partition to be created
select *
from sys.partitions as p
where p.object_id = object_id('t')

--only contains 'in_row_data'
select a.*
from sys.allocation_units as a
inner join sys.partitions as p on a.container_id = p.partition_id
where p.object_id = object_id('t')

--add a varchar col which tips the total column size over the payload limit of page. that will cause 'ROW_OVERFLOW_DATA' allocation unit to be added 
--to the table. adding a varchar of, say, size 100 would not tip the scale and thus not cause addtition of 'ROW_OVERFLOW_DATA' allocation unit.
alter table t
	add id4 varchar(7900);--7900 is tipping the total size of the data cols(7900+200) to be greater than payload size of page
go 
--contains 'in_row_data' and 'ROW_OVERFLOW_DATA' allocation unit
select a.*
from sys.allocation_units as a
inner join sys.partitions as p on a.container_id = p.partition_id
where p.object_id = object_id('t')

--add a varbinary col which tips the total column size over the payload limit of page. that will cause 'LOB_DATA' allocation unit to be added 
--to the table. but the thing it is adding both 'LOB_DATA' and 'ROW_OVERFLOW_DATA' allocation unit(to verify create the table t but do not add 
--id4 column that should have created a 'ROW_OVERFLOW_DATA' alloc unit)!!
alter table t
	add id5 varbinary(max);

--contains 'in_row_data', 'ROW_OVERFLOW_DATA' and 'LOB_DATA' allocation unit
--note that till now we do not have any pages associated with table as we have not inserted any data
select a.*
from sys.allocation_units as a
inner join sys.partitions as p on a.container_id = p.partition_id
where p.object_id = object_id('t')
go

--insert some data that fits in payload of a page.
insert into t values
(
'ramneek',
'singh',
'asdasdfd sdfds we3423, dsf, 3223',
'2013/01/01',
'asdadasdaaa sdfsdfs w wewerewr wqweqweqweqwe',
cast('simple things...' as varbinary(max))
)

--as we were able to fit the data on the page, we only used 'IN_ROW_DATA' allocation unit and only used 1 data page. the other used page is the
--IAM(index allocation map page). Why is the total_pages 9. it seems to suggest that a uniform extent was used but why? New versions allocate 
--uniform extent straight away. Verified it on SQL server 2012 where total_pages was 2 as it for the data page it used a mixed extent.
select a.*
from sys.allocation_units as a
inner join sys.partitions as p on a.container_id = p.partition_id
where p.object_id = object_id('t')
go

--now insert data to overflow in id 4 column. we could have updated the previously added row as well to 'overflow'
insert into t values
(
'ramneek',
'singh',
'asdasdfd sdfds we3423, dsf, 3223',
'2013/01/01',
REPLICATE('a',7900),
cast('simple things...' as varbinary(max))
)
go

-- used_pages is 2(1 page for IAM and 1 page for overlfow column data).  But the data_pages is 0(shouldn't the overlfow column data page be counted
--as a data page?). total_pages is 9(uniform extent was used + IAM page)
select a.*
from sys.allocation_units as a
inner join sys.partitions as p on a.container_id = p.partition_id
where p.object_id = object_id('t')
go

--now insert data to overflow in id 4 column. we could have updated the previously added row as well to 'overflow'
insert into t values
(
'ramneek',
'singh',
'asdasdfd sdfds we3423, dsf, 3223',
'2013/01/01',
'asd dsdsfs sdds',
cast(REPLICATE('a',70000) as varbinary(max))
)
go

-- used_pages is 2(1 page for IAM and 1 page for LOB_DATA column data).  But the data_pages is 0(shouldn't the overlfow column data page be counted
--as a data page?). total_pages is 9(uniform extent was used + IAM page)
--LOB_DATA column data page does not seem like a normal data page as we inserted 70kb of data and still we had 1 used_page. whereas considering the 
--size of data page payload, we should have used around 9 data_pages
select a.*
from sys.allocation_units as a
inner join sys.partitions as p on a.container_id = p.partition_id
where p.object_id = object_id('t')
go

use master
go
drop database allocationuntis

--now for each allocation unit, an IAM page is created. IAM page tells which pages(in case of mixed extents) and which extents belong to the table 
--and which not. like GAM and SGAM pages, it too maps 4 GB of database file(it is also a bitmap). All IAM pages have 8 page pointer slots and then a set of bits that map 
--a range of extents onto a file. The 8 page pointer slots are filled only for the 1rst IAM page for an object. if the mapping bit for a particular 
--extent is set, then that belongs to the table associated with the IAM and if 0 then not.
create database iampages;
go

use iampages
go

create table t
(
col1 char(2000),
col2 char(2000),
col3 char(2000),
col4 char(2000)
)
go

insert into t values
(
	'c1','c2','c3','c4'
)
go

dbcc traceon(3604)
go

--this will return 2 pages: IAM page with pagetype 10 and data page with pagetype 1. get the first data page for the table
dbcc ind(iampages, t, -1)
go

--get the iam page for table t
--on prior versions(2012 and 2014?), 1 page in a mixed extent would be used. On newer versions, 1 page in uniform extent would be used.
--the allocated page ids returned by the IAM page would be the same as retruned by dbcc ind
dbcc page(iampages,1,320,3)
go

insert into t values
(
	'c1','c2','c3','c4'
)
go 8

--this will return 2 pages: IAM page with pagetype 10 and data page with pagetype 1. get the first data page for the table
dbcc ind(iampages, t, -1)
go

--get the iam page for table t
--on prior versions(2012 and 2014?), 1 page in a mixed extent would be used. On newer versions, 1 page in uniform extent would be used.
--the allocated page ids returned by the IAM page would be the same as retruned by dbcc ind
dbcc page(iampages,1,320,3)
go

use master
go
drop database iampages

--bookmark lookup deadlock occurs when out of 2 concurrent sessions one is reading data from a NCI and has to perform lookups into
--CI and other one is updating the CI(the key CI key) and thus has to update the NCI bookmark as well.
--when NCI is waiting to accquire a shared lock on CI to read data while CI has X(exclusive) lock and it is waiting to get a 
--exclusive(X) lock on NCI. So both are blocking each other and we have a deadlock

create database bookmarklkupdl;
go

use bookmarklkupdl;
go

create table deadlock
(
col1 int not null primary key,
col2 int not null ,
col3 int not null 
)
go

create nonclustered index idx_col3 on deadlock(col3);
go

insert into deadlock values(1,1,1);

select * from deadlock;

--bookmark lookup deadlock is more easily reproduced using repeatable read.
--repeatable read would hold the shared lock until the end of the transaction. Default isolation level of read committed would
--also reproduce the deadlock but would need a higher workload. How does read_committed_snapshot changes the scenario?
set transaction isolation level repeatable read
--set transaction isolation level  read committed
go

----execute in session 1
--while(1=1)
--begin
--	update deadlock
--	set col1 = col1 + 1
--	where col3 =1;
--end


----execute in session 2
--set transaction isolation level repeatable read
----set transaction isolation level  read committed
--go

--while(1=1)
--begin
--	select * from deadlock with (index(idx_col3))
--	where col3 =1
--end


use master
go
drop database bookmarklkupdl


--thread pool starvation. By default x64 bit SQL Server instance will have 512 threads if core count is <=4 and 576 if core count is <8 
--and so on. All the databases on the SQL server instance will share the same thread pool. You can modify the default thread pool size.
--When a thread running a query is in signal wait state or resource wait state, that thread is not available to do other tasks. Imagine 
--a scenario when a transaction updates a row in a table taking a exclusive(X) table lock on it. We do not commit the transaction. Now 
--we run, say 600, SELECT queries against that table. The queries would want a shared(S) lock but that is not compatible with X lock.
--So the threads would move to the resource wait queue with 512 threads showing wait_type of 'LCK_M_IS' and the rest showing a wait_type 
--of 'threadpool'.
create database threadpoolwaits
go

use threadpoolwaits;
go

create table t
(
col1 int not null identity(1,1) primary key,
col2 int
)
go

insert into t values(1);
go

create procedure readworkload
as
begin 
select * from t;
end

--config value and run value is 0. means the default setting is being used
sp_configure 'max worker threads'

--number of worker threads avaiable. My system having <=4 cores, i get 512 max thread count.
select max_workers_count from sys.dm_os_sys_info

--start a transaction but do not commit it
begin tran
update t with (tablockx)
set col2=24
--commit tran

--run the proc from a different session..it would be blocked and be moved to resourse wait queue with a wait_type of 'LCK_M_IS' signifying
--that intends to get a shared lock(IS).
exec readworkload
select * from sys.dm_os_waiting_tasks where session_id=54--session 54 is the one running proc(different from current session)


-- stress test using ostress.exe part of RM utils from Microsoft. running it would ultimately cause SQL server to become unresponsive as
--it does have worked threads to process new requests. A special thread is reserved for DAC and DAC can be used either using sqlcmd
--or in ssms. For ssms, provide the server name as: admin:XPSDEGRAAFF\SQLSERVER2017
--C:\Program Files\Microsoft Corporation\RMLUtils>ostress.exe -SXPSDEGRAAFF\SQLSERVER2017 -Q"EXEC threadpoolwaits.dbo.readworkload" -n600
select * from sys.dm_os_waiting_tasks where wait_type ='LCK_M_IS'
select * from sys.dm_os_waiting_tasks where wait_type ='threadpool'

--C:\Users\ramneekm>sqlcmd.exe -S XPSDEGRAAFF\SQLSERVER2017  -d threadpoolwaits -A
--analyze all requests waiting for a free worker thread. they won't have any session_id
--1> select * from sys.dm_os_waiting_tasks where wait_type ='threadpool'
--1> go
--analyze all current executing requests waiting for shared lock.
--1> select * from sys.dm_os_waiting_tasks where wait_type ='LCK_M_IS'
--1> go
--analyze all current executing requests in sql server
--1> select r.command, r.plan_handle, r.wait_type, r.wait_resource, r.wait_time, r.session_id, r.blocking_session_id from sys.dm_exec_requests as r inner join sys.dm_exec_sessions as s on r.session_id = s.session_id where s.is_user_process = 1
--1> go
--analyze head blocker session
--1> select login_time, host_name, program_name, login_name from sys.dm_exec_sessions where session_id = 55
--1> go
--analyze head blocker connection
--1> select connect_time, client_tcp_port, most_recent_sql_handle from sys.dm_exec_connections where session_id = 55
--1> go
--retrieve the sql statement that is the culprit
--1> select [text] from sys.dm_exec_sql_text(0x0200000077E29C32B500E1EF1EB44CD0BEA802CA2E8A52000000000000000000000000000000000000000000)
--1> go
-- now u can kill the session(with the open tran)
--1> kill 55
--1> go
--1> exit

--always close the DAC connection, either in ssms or sqlcmd!!

use master
go
drop database threadpoolwaits

create database latchcontentiondemo
go

use latchcontentiondemo
go

--clear wait stats
dbcc sqlperf('sys.dm_os_wait_stats', 'clear');
go

create procedure populatetemptable
as
begin

create table #tempt
(
col1 int identity(1,1),
col2 char(4000),
col3 char(4000)
);

create unique clustered index id_c1 on #tempt(col1);

--insert 10 records
declare @i as int = 1;
while(@i<10)
	begin
		insert into #tempt values('ramneek', 'singh')
		set @i = @i +1
	end

end
go


--the following sample will demonstrate allocation bitmap contention(GAM, SGAM and PFS pages. in every data file file header is page 0, PFS page 1, GAM page 2 and SGAM is
--page 3) in tempdb under high concurrent workload. There is a PFS page after every 8000 pages after first and GAM and SGAM each after 64000 extents(4GB).
-- two workarounds exist to reduce Tempdb contention: add more tempdb files and disable mixed extents(this is already the default in new versions). 
--latches as intersnal sql server 'locks' used when to handle concurrent access scenarios. although this example is showing latch contention for non-data
--pages, the concept remains same for data pages as well. Take for example when we concurrently trying to update 2 separate records in a table. both updates will
--get a row-level lock(hopefully) and if they are on spearate pages, both the updates can proceed concurrently with both page being 'latched' with PAGELATCH_EX. But if they 
--are on the same page, then only one thread can get the PAGELATCH_EX latch and the other thread will have to wait even when the locks involved are row-level for 
--different rows. So it effectively serializes the request for updates to 2 different records. Page latches are used to ensure integrity of pages. imagine scenarios
--if it were not serialzied: page split occurs due to one update and the 'other' row moves to a different page!
--so if you are doing a lot of, say, inserts which are ordere on index key and show proximity(like transactions entries, invoice entries,or bulk loading records), you 
--would be effectively running serially.
--proc executes the 'populatetemptable' 
create proc looppopulatetemptable
as
begin
declare @i as int = 0;
while(@i<100)
	begin
		exec populatetemptable;
		set @i += 1;
	end
end
go

exec looppopulatetemptable;
go

--stress test with ostress.exe 
--C:\Program Files\Microsoft Corporation\RMLUtils>ostress.exe -SXPSDEGRAAFF\SQLSERVER2017 -Q"EXEC latchcontentiondemo.dbo.looppopulatetemptable" -n100

--now u can see there are currently a lot of threads waiting because of pagelatch_up wait_type. Notice that sessions_id is not null, so these 
--are executing requests who have been allocated a thread(unlike for wait_type='threadpool')
select * from sys.dm_os_waiting_tasks 
where wait_type='PAGELATCH_EX'
--wait_type='PAGELATCH_UP' or resource_description = '2.1.1'
--or resource_description = '2.1.2'
--or resource_description = '2.1.3'

--the wait_type='PAGELATCH_EX' is up near the top
select * from sys.dm_os_wait_stats 
where wait_type like '%PAGELATCH%' 
order by wait_time_ms desc

--ostress took 00:01:08 for completion
--total tasks waiting is 636,862
--total time waiting is 6,549,256

--clear wait stats
dbcc sqlperf('sys.dm_os_wait_stats', 'clear');

--increase the size of the tempdb file and add a datafile to tempdb with the same size so that 
--we have 2 tempdb data files.
alter database tempdb
modify file 
(
	name='tempdev',
	size=512mb
)
go

alter database tempdb
add file 
(
	name='tempdev2',
	size=512mb,
	filename='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLSERVER2017\MSSQL\DATA\tempdev2.ndf'
)
go

--the wait_type='PAGELATCH_EX' is up near the top
select * from sys.dm_os_wait_stats 
where wait_type like '%PAGELATCH%' 
order by wait_time_ms desc

--adding a new tempdb file should have taken the contion down. Although the total tasks waiting is down
--but the ostress time as well as total time spent waiting has gone up :(
--ostress took 00:01:23 for completion
--total tasks waiting is 136,047
--total time waiting is 7,519,606

use master
go
drop database latchcontentiondemo

create database hashcollisions
go
use hashcollisions
go
alter database hashcollisions
	add filegroup hekatonFG contains memory_optimized_data
go

alter database hashcollisions
add file 
(
	name='hekatonContainer',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLSERVER2017\MSSQL\DATA\hekatonContainer.ndf'
)
to filegroup [hekatonFG]
go

create table testtable
(
col1 int not null primary key nonclustered 
	hash with (bucket_count=1024),
col2 int not null,
col3 int not null 
)
with
(
memory_optimized = on,
durability = schema_only
)
go

use master
go
drop database hashcollisions

create database UniqueCIStructure;
go

use UniqueCIStructure;
go

--create a table with length 400 bytes(393 + 7bytes overhead). Therefore u can fit 20 records on 1 page(8192 - 96 bytes overhead= 8060 bytes. 8060/400=20.15)
create table cust
(
customerid int not null primary key identity(1,1),
custname char(100) not null,
custaddr char(100) not null,
comments char(189)
)
go

--insert 80,000 records..20 rows fit in one page. So 80,000 would fit in 80000/20 = 4,000 pages as we will see below.
declare @i int = 1;
while(@i<=80000)
begin
	insert into cust values
	(
	'customername' + cast(@i as char),
	'customeraddr' + cast(@i as char),
	'comments' + cast(@i as char)
	)
	set @i += 1;
end
go 

select * from cust 

--use the dmf dm_db_index_physical_stats 
SELECT * FROM sys.dm_db_index_physical_stats (DB_ID (N'UniqueCIStructure'), OBJECT_ID (N'cust'), -1, 0, 'DETAILED');
GO

--u can also view the distribution of the data by checking the stats for the index. run sp_help on the table
--to find out the name for the index. then run dbcc show_statistics(or instead of doing prev 2 steps, just query sys.stats). 
--But SQL server might not have created stats for the index as yet(remember SQL Server creates stats automatically for columns 
--in a index but also  not columns not in an index but used in a predicate). so first force an update to stats and query them
--if we do not use FullScan, then a sample will be used to create the distribution which would not accurately reflect the data
select * from sys.stats where object_id =  OBJECT_ID('cust');--stats created by an index will have the same name as index and 
--those created non-indexed predicate columns will have system generated name
select * from sys.stats_columns where object_id =  OBJECT_ID('cust');--which columns are covered by stats..

--stats are used to create a efficient execution plan and index are used faster retreival of data. example below in db onlystatsNoIndexCol.
--if you have in-efficient execution plan, then it is not necessary that the stats need to be updated as the problem could also be parameter 
--sniffing. remember the excellent talk by kimberley tripp on sp caching. a column with high selectivity(uniqueness) will have low density 
--and a col with low selectivity will have high density. Density = 1/(no. of distinct values in a col). The lower the col density, the more 
--suitable it is for nci use.

update statistics dbo.cust
dbcc show_statistics('cust', 'PK__cust__B61ED7F5E167DD0F')
--true distribution stats
update statistics dbo.cust with fullscan
dbcc show_statistics('cust', 'PK__cust__B61ED7F583E1873B')

--create helper table to sore output of dbcc ind 
CREATE TABLE sp_table_pages 
(
PageFID tinyint,   
PagePID int,   
IAMFID   tinyint,   
IAMPID  int,   
ObjectID  int,   
IndexID  tinyint,   
PartitionNumber tinyint,   
PartitionID bigint,   
iam_chain_type varchar(30),   
PageType  tinyint,   
IndexLevel  tinyint,   
NextPageFID  tinyint,   
NextPagePID  int,   
PrevPageFID  tinyint,   
PrevPagePID int,   
Primary Key (PageFID, PagePID));
go

insert into sp_table_pages
exec('dbcc ind(UniqueCIStructure, cust, 1)')

--retreive all index pages/non-leaf level (pagetype = 2)
select *
from sp_table_pages
where PageType = 2
order by IndexLevel desc
go

--retreive all data pages/leaf level (pagetype = 1). 4,000 pages
select *
from sp_table_pages
where PageType = 1
order by IndexLevel desc
go

--retreive root index page
select *
from sp_table_pages
where IndexLevel = 2
order by IndexLevel desc
go

--now imagine we have to find record with customerid 33333. enable trace flag 3604 for using dbcc page command
dbcc traceon(3604)
go

--dump the root index page (found using dbcc ind or by filtering the table containing the dumped output of dbcc ind). returns 269 records as it points to 14 pages in next level
--the column customerid in the output tells us the smallest id value stored on a particular page in the next level
dbcc page(UniqueCIStructure, 1, 959, 3)

--dump the intermediate index page. returns 269 records as it points to 269 pages in next level 
dbcc page(UniqueCIStructure, 1, 2310, 3)

--dump the leaf/data page. the row offset array in the end shows the page storing 20 records. we go through all the 20 rows on the page using row offset array 
--to find the row we are looking for(the page has laready been read into memory). Compare that with a NCI RID lookup(bookmark lookup for a heap) which takes 
--directly to the row as it stores the SlotID as well. in this case slot 12 has our row.
--one question i have is that i thought the CI defined order of rows was reflected by slot array not by the actual order of rows on the page. 
--so the data should not have been physically ordered on individual pages but should have let the slot indexes define the order. But my testing show the rows are
--actually being stored physically ordered on the page.
dbcc page(UniqueCIStructure, 1, 2008, 1)

use master
go
drop database UniqueCIStructure;

--forwarding records/pointer. Issue with heap tables(why not an issue with B-Tree tables?). When a record moves to a different physical location in a heap, 
--a fwd'ing record--/pointer is placed in it's original place. happens when a var length col is updated and the row can't fit on the page.
--in this SQL Server avoids having to update all non-clustered indexes on the heap table. What happens in the case of CI tables?
--why are forwarding records not used in CIs?
create database forwardingrecords;
go

use forwardingrecords;
go

set statistics io on
go

create table heaptbl
(
c1 int identity(1,1),
c2 char(2000),
c3 varchar(1000)
)
go


insert into heaptbl values
(replicate('1',2000), ''),--there was not need to use replicate for c2. it would have reserved 2000 bytes even if we had entered empty string.
(replicate('2',2000), ''),
(replicate('3',2000), ''),
(replicate('4',2000), '')
go

--should perfrom 1 logical read
select * from heaptbl;

update heaptbl
set c3 = REPLICATE('t',300)
where c1 = 4

--should perform 2 logical reads. Although it showed 3 logical reads but using the DMF and dbcc below, we confirm 2 data pages
select * from heaptbl;

dbcc traceon(3604)--need for dbcc page command
--find which data pages belong to our tbl. columns PageFID and PagePID.
--this will return 3 pages: IAM page with pagetype 10 and 2 data pages
dbcc ind(forwardingrecords,heaptbl,-1)

--remember page header size is 96 bytes, then we have payload and then the rowoffset array(aslot array).
--row offset array need 2 bytes to store location for each record
--dump the 2 data pages using FID and PID of the page. First record in data pages are at offset 96. note the 'FORWARDING_STUB'
dbcc page(forwardingrecords,1,328,3)
dbcc page(forwardingrecords,1,328,1)
dbcc page(forwardingrecords,1,328,2)

dbcc page(forwardingrecords,1,329,3)
dbcc page(forwardingrecords,1,329,1)
dbcc page(forwardingrecords,1,329,2)

--u can also use the dmf dm_db_index_physical_stats to get similar info. note the field forwarded_record_count
SELECT
	[forwarded_record_count],
    [index_depth],
    [index_level],
    [page_count],
    [record_count],
	*
FROM sys.dm_db_index_physical_stats (DB_ID (N'forwardingrecords'), OBJECT_ID (N'heaptbl'), -1, 0, 'DETAILED');
GO


--rebuilding a heap table gets rid of forwarding records.
alter table heaptbl rebuild

--now check again using DMF. Note forwarded_record_count is not 0. It would have updated the NCIs on the heap as well.
SELECT
	[forwarded_record_count],
    [index_depth],
    [index_level],
    [page_count],
    [record_count],
	*
FROM sys.dm_db_index_physical_stats (DB_ID (N'forwardingrecords'), OBJECT_ID (N'heaptbl'), -1, 0, 'DETAILED');
GO

use master
go
drop database forwardingrecords;
go

create database nci
go
use nci
go

--row length 393 + 7 bytes overhead = 400 bytes. 8,060/400 = 20.15. So 20 rows stored on each page.
create table cust
(
customerid int not null,
customername char(100) not null,
customeraddr char(100) not null,
comments char(189) not null
)
go

create unique clustered index idx_custid on cust(customerid)
go

--insert 80,000 records..20 rows fit in one page. So 80,000 would fit in 80000/20 = 4,000 pages as we will see below.
declare @i int = 1;
while(@i<=80000)
begin
	insert into cust values
	(
	 @i,
	'customername' + cast(@i as char),
	'customeraddr' + cast(@i as char),
	'comments' + cast(@i as char)
	)
	set @i += 1;
end
go 

select * from cust

--non-unique non clustered index on CI
create nonclustered index idx_nonuniquenci_custname on cust(customername)

--index_id 1 is for CI and index_id 2 is for nci
SELECT	* FROM sys.dm_db_index_physical_stats (DB_ID (N'nci'), OBJECT_ID (N'cust'), -1, 0, 'DETAILED');
GO

--create helper table to sore output of dbcc ind 
CREATE TABLE sp_table_pages 
(
PageFID tinyint,   
PagePID int,   
IAMFID   tinyint,   
IAMPID  int,   
ObjectID  int,   
IndexID  tinyint,   
PartitionNumber tinyint,   
PartitionID bigint,   
iam_chain_type varchar(30),   
PageType  tinyint,   
IndexLevel  tinyint,   
NextPageFID  tinyint,   
NextPagePID  int,   
PrevPageFID  tinyint,   
PrevPagePID int,   
Primary Key (PageFID, PagePID));
go

--passing 2 for nci type
insert into sp_table_pages
exec('dbcc ind(nci, cust, 2)')

--get the root page of nci.. the index has 3 levels
select * from sp_table_pages where IndexLevel=2

--now dump the root page of non-unique nci using dbcc page
dbcc traceon(3604)
go

--16 rows are stored in the root page. because we created a non-unique nci, the CI key(in this case the customerid) is also 
--stored in the index pages/nonleaf pages(it would be stored in leaf page anyways). What happens if the non-unique nci is on a
--heap. Is the RID stored in the non-leaf pages?
--Question:what happens in case of non-unique CI. 
dbcc page('nci',1,4426,3)

--now dump out a page from the 2nd level of the nci(cuse a childpageid from the above dbcc output)
dbcc page('nci',1,4431,3)

--now dump out a data page/leaf of the nci(cuse a childpageid from the above dbcc output)
dbcc page('nci',1,5331,3)

use master;
go 
drop database nci;
go

create database onlystatsNoIndexCol
go
use onlystatsNoIndexCol
go

--stats are used to create a efficient execution plan and index are used faster retreival of data. But since index creation creates stats as well
--so we get both benefits. the use of non-indexed(or non leading in case of compound key) column in a predicate leads to autocreation of stats on that
--col(if autocreate stats option is on. autocreatestats option does not apply to index as for index stats are always created)


--nested loop join operator
use AdventureWorks2014
go

--the stats on SalesOrderID gives the query optimizer an estimate of 1 row for soh and 24.076 for d. that is quite a small number of rows
--so optimizer decides to use nested loop join..the query with lesser number of rows is always on the outer loop. if we parallelize the nested
-- loop, it helps if the inner loop is the bigger one so that thread running it are kept busy. otherwise the overhead of starting a new thread and
--then collecting work after it has finished overshadows the performance gain we could have expected by running the loop in parallel. 
--and since the inner loop should be bigger and is run for each iteration of outer loop, it is important that the join column for the inner loop
--is indexed so that seek operations are peformed instead of scan
select soh.*, d.*
from Sales.SalesOrderHeader as soh 
inner join Sales.SalesOrderDetail as d on d.SalesOrderID = soh.SalesOrderID
where soh.SalesOrderID = 71832
go

--find the index or stats name by executing sp_help
--dbcc show_statistics('Sales.SalesOrderHeader', 'PK_SalesOrderHeader_SalesOrderID')
--dbcc show_statistics('Sales.SalesOrderDetail', 'PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID')

--now demonstrate nested loop join operator with bookmark lookups
select EmailAddressID, EmailAddress, ModifiedDate
from Person.EmailAddress
where EmailAddress like 'sab%'

--find the index or stats name by executing sp_help
--dbcc show_statistics('Person.EmailAddress', 'IX_EmailAddress_EmailAddress')

--note that a table variable does not have stats and for it a '1' is the hard coded no. of rows returned as an estimate to query otpimizer.
--that means a table variable is always used as an outer table in case of a join with another table.

declare @tVar as table
(
id int identity(1,1) primary key,
firstname char(4000),
lastname char(4000)
)

--inserting 20000 rows. by the way it is a bad practise as we should use table variables with only a few records. for larger no of rows
--use temp table instead as temp table has stats on it(either through index or through the use of a col in a predicate(autocreation))
insert into @tVar 
select top 20000 name,name from master.dbo.syscolumns

select * from Person.Person as p
inner join @tVar as t on  t.id = p.BusinessEntityID;
go

--if we are not able to use temp table to use stats, then a workaround is to use query hint option(recompile)
declare @tVar as table
(
id int identity(1,1) primary key,
firstname char(4000),
lastname char(4000)
)

insert into @tVar 
select top 20000 name,name from master.dbo.syscolumns

--this time, as stats are available on table var, merge join is used as the total number of rows involved is large enough
select * from Person.Person as p
inner join @tVar as t on  t.id = p.BusinessEntityID
option(recompile);
go


create database tippingpoint
go

set statistics io on
set statistics time on
go

use tippingpoint
go

--20 records on one data page. 8060/400=20.15
create table customers
(
custid int not null,
custname char(100) not null,
custaddr char(100) not null,
comments char(185) not  null,
value int not null
)
go

create unique clustered index idx on customers(custid);
go

--insert 80000 records
--declare @i as int = 1;
--while(@i<80000)
--	begin
--	insert into customers values
--	(
--	@i, 'customername' + CAST(@i as char), 'customeraddr' + CAST(@i as char),
--	'comments' + CAST(@i as char), @i
--	)
--	set @i= @i+1;
--	end
--go

--do not run loops like the above as they will take a loooong time. Just use cross apply/cross to mimick loop using series of numbers(the numbers which you will then use as row values)
--helper function getnums is here:
IF OBJECT_ID(N'dbo.GetNums', N'IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO

insert into customers 
	select n, 'customername' + CAST(n as char), 'customeraddr' + CAST(n as char),'comments' + CAST(n as char), n
	from dbo.GetNums(1,80000) 

--4000 page reads
select * from customers;

create nonclustered index idxnci on customers(value)
go


--tipping point is between 25% and 33% of total pages. We have 4000 pages. Remeber we are talking about percentage of pages, not no. of records(as records size varies and thus the total number that fits on a page).
--but the 'number of pages' value we come up with will be equal to the 'number of rows' value in the sense that the same 'number of rows' read from NCI will cause that number of page reads into CI.
--25/100*4000 pages = 1000 pages. 
--33/100*4000 pages = 1320 pages.

--bookmark lookup performed. we are reading 1062 records, you are performing 1062 lookups in to the CI and thus 1062 page reads(remember nested loop join operator is used for bookmark lookups
--and the NCI is the outer table. Thus for each read from NCI, there is one corresponding page read from CI or heap). Now 1062 page reads into CI correspond to 1062 rows read from NCI. 
--if you check the logical reads from stat io, you will see that number something like 3186. That is because to seek to a page in CI, it has to read index pages as well. Now the CI has 3 levels.
--thus 3*1062 total logical IO
--if this plan is cached and reused for a bigger parameter value, it would be bad performance wise as it would still perform bookmark lookups. Parameter sniffing is the issue(not outdated stats)
select * from customers 
where value<1063

--shows the index depth
SELECT
    [index_depth],
    [index_level],
    [page_count],
    [record_count],
	*
FROM sys.dm_db_index_physical_stats (DB_ID (N'tippingpoint'), OBJECT_ID (N'customers'), -1, 0, 'DETAILED');
GO
--this performs CI scan..reading 1063 rows(the tipping point) would have led to 1063 page reads from CI which sql server deems to be costly. thus it performed a CI scan instead and read 
--the 4000 leaf pages(shows as total logical IO)
select * from customers 
where value<1064

use master
go
drop database tippingpoint
go

--13: hash join is used when joining big un-indexed tables. For data warehouse scenarios, it might be fine but for OLTP scenarios, u don't
--really want to see a hash join. Hash join suggest there is a problem with indexing strategy. Almost always Hash join requires a memory
--grant for the hashtable and if the stats are out of date/inaccurate, the memory grant might be too small and sql server has to spill 
--hash join to temp db. So the HASH JOIN operator could involve physical IO.
--Which hash function is used by SQL server is undocumented. Hash Join consists of 2 phases: in the first phase a hastable is built for 
--the outer table and in the second phase the inner table values(hashed values?) are probed in the hashtable to emit matching records.

use AdventureWorks2014
go

set statistics io on 
set statistics time on
go

--a memory grant of 8 MB was needed for this query. memory grant has to be granted before query can start executing.
select p1.FirstName, p1.LastName, p2.PhoneNumber
from Person.Person as p1
inner join Person.PersonPhone as p2
	on p1.BusinessEntityID = p2.BusinessEntityID

--now lets c how outOfDate statistics can lead to spills to tempdb (hjahsh spills).
create database hashspills;
go

use hashspills;
go

create table t1
(
col1 int identity primary key,
col2 int,
col3 char(2000)
)
go

create nonclustered index idx_t1col2 on t1(col2);
go

select top 1500 IDENTITY(int, 1,1) as n into #nums
from master.dbo.syscolumns as sc1

insert into t1(col2,col3)
select n, replicate('x',2000) from #nums
drop table #nums
go

select * from t1;

create table t2
(
col1 int identity primary key,
col2 int,
col3 char(2000)
)
go

create nonclustered index idx_t2col2 on t2(col2);
go

select top 1500 IDENTITY(int, 1,1) as n into #nums
from master.dbo.syscolumns as sc1

insert into t2(col2,col3)
select n, replicate('x',2000) from #nums
drop table #nums
go

--execute our problematic statement in 1rst step. This will cause tehe caching of a sub-optimal execution plan
select *
from t1 inner hash join t2 on t1.col2 = t2.col2
where t1.col2=2;
go

--insert 799 new rows. to trigger a stats update we need 800 rows(20% + 500)
select top 799 IDENTITY(int, 1,1) as n into #nums
from master.dbo.syscolumns as sc1

insert into t1(col2,col3)
select 2, replicate('x',2000) from #nums
drop table #nums
go

--this will cause a hashspill as because of inaccurate stats. SQL server esitmates 1 row for hash join and requests a memory grant of 1 mb. 
--that memory is needed to create the hashtable and if memory grant is less, the hashtable is spilled to tempdb
select *
from t1 inner hash join t2 on t1.col2 = t2.col2
where t1.col2=2;
go

--update stats to estimate number of rows and thus the memory grant correctly.
update statistics t1 with fullscan
update statistics t2 with fullscan
go

--Since stats were updated, sql server recompiles the execution plan and this time memory grant is around 4mb and hashtable is not spilled to tempdb
select *
from t1 inner hash join t2 on t1.col2 = t2.col2
where t1.col2=2;
go


create database mergejoin
go

use mergejoin
go

create table t1
(
col1 int primary key,
col2 int
)

create table t2
(
col1 int primary key,
col2 int
)

insert into t1 
select top(1500) ROW_NUMBER() over (order by column_id ), ROW_NUMBER() over (order by column_id)
from sys.all_columns

insert into t2
select top(1500) ROW_NUMBER() over (order by column_id ), ROW_NUMBER() over (order by column_id)
from sys.all_columns


--use hint to force merge join. An explicit sort operator is used to be able to use Merge Join. Also, the Merge Join is Many-to-Many
--and it creates a worktable in TempDb. It assumes ManyToMany incorrectly as there is no supporting index on outer table to suggest that 
--values in the outer table are unique.
--And due to the sort operation, the query also requests memory which can be seen in 'Memory Grant'
select t1.*, t2.*
from t1 inner merge join t2 on t1.col2 = t2.col2

create unique nonclustered index idx on t2(col2)

--now when we run our query, we do not neet to provide Merge join hint. It automatically uses merge join. This t2 is the outer table
--as query optimizer knows that we have unique values in col2 in t2 and also the merge join is not executed as ManyToMany.
--The explicit sort operator is also eliminated as we sorted result from the index. therefore no worktable is created in tempdb
--but there is still one sort operator remaining on t1
select t1.*, t2.*
from t1 inner join t2 on t1.col2 = t2.col2

create unique nonclustered index idx1 on t1(col2)
--no sort operator used this time
select t1.*, t2.*
from t1 inner join t2 on t1.col2 = t2.col2


use master
go

alter database mergejoin set single_user with rollback immediate 
drop database mergejoin
go


create database dbShrinking
go

use dbShrinking
go

--create a table that would be near the beginning of the data file
create table t1
(
col1 int identity,
col2 char(8000) default 'dummy'
)
go

--inset 10 mb data
--insert into t1 default values 
--go 1280
insert into t1 
select top(1280) ROW_NUMBER() over(order by (select null))
from sys.columns as b1 cross join sys.columns as b2

--now create a table with a unique clustered index. this table would be come after the table t1 in the data file. To show the 
--negative side effects of db shrinking, you need to have some indexes, clustered or nonclustered, after the address space in the 
--data file that is going to made free and hence needs to be reclaimed after shrinking the db.
create table cust
(
c1 int identity,
c2 char(7800),
c3 char(200) 
);

create unique clustered index id1 on cust(c1)
go
create nonclustered index idx2 on cust(c3)
go

--inset 10 mb data
insert into cust
select top(1280) ROW_NUMBER() over(order by b1.column_id, b2.column_id), ROW_NUMBER() over(order by b1.column_id, b2.column_id)
from sys.columns as b1 cross join sys.columns as b2


--check clustered index fragmentation of cust..It would be very small.
select avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID('dbShrinking'), OBJECT_ID('cust'), 1, null, 'limited')

--check nonclustered index fragmentation of cust..It would also be very small but a little more than clustered. why?
select avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID('dbShrinking'), OBJECT_ID('cust'), 2, null, 'limited')

--now drop the table t1 that comes before cust on the address space of the data file. now the size of the data file before the 'drop'
drop table t1;

--dropping the table did not make SQL server reclaim the space back in the data file.
--now shrink db. This will reduce the size of data file
dbcc shrinkdatabase(dbShrinking)

--now again check clustered and nonclustered index fragmentation of cust..i can see high fragmentation(95 and 97%)
--that is because the to fill the space that has been emptied, sql server starts moving the pages from the end of the file to the
--the empty space. So if a index has leaf/data pages 80,81,82 they will will be moved to the empty space and will be placed in the physical
--order 82,81,80. That is 100% external fragmentation(logical order differs from physical order)
select avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID('dbShrinking'), OBJECT_ID('cust'), 1, null, 'limited')
select avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID('dbShrinking'), OBJECT_ID('cust'), 2, null, 'limited')

--rebuild indexes to defrag. But notice the size of the data file after defrag. The size even larger than before we performed drop! why?
alter index id1 on cust rebuild;
alter index idx2 on cust rebuild;
select avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID('dbShrinking'), OBJECT_ID('cust'), 1, null, 'limited')
select avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID('dbShrinking'), OBJECT_ID('cust'), 2, null, 'limited')

--Autoshrink causes index fragmentation and autogrowth causes file fragmentation. if u have to shrink, shrink manually and then rebuild indexes
use master
go

alter database dbShrinking set single_user with rollback immediate 
drop database dbShrinking 
go

--round robin policy sql server uses for datafiles makes sure that all the datafiles in the file group become completely full at around the same time. So if the files sizes in a file group
--have different sizes, SQL server will fill them proportionally to make sure, in the end, they become full at the same time. So you get an IO imbalance and a performance hit.
create database multipleFilegroups on primary
(
--primary filegroup
Name= 'multipleFilegroups',
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\multipleFilegroups.mdf' , 
SIZE = 5MB, MAXSIZE=unlimited, FILEGROWTH = 1024KB 
),
--secondary file group. this filegroup will have multiple files
FileGroup FileGroup1
(
Name= 'multipleFilegroups1',
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\multipleFilegroups1.ndf' , 
SIZE = 1MB, MAXSIZE=unlimited, FILEGROWTH = 1024KB 
),
--second file in the first secondary file group
(
Name= 'multipleFilegroups2',
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\multipleFilegroups2.ndf' , 
SIZE = 1MB, MAXSIZE=unlimited, FILEGROWTH = 1024KB 
)
LOG ON 
( NAME = N'multipleFilegroups_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\multipleFilegroups_log.ldf' , SIZE = 5MB, MAXSIZE=unlimited, FILEGROWTH = 1024KB )
go

--FileGroup1 becomes the default file group where new database objects will be created.
alter database multipleFilegroups modify FileGroup FileGroup1 Default
go

use multipleFilegroups;
go

--1 row stored on 1 data page. Table would be create on FileGroup1
create table t1
(filler char(8000)
)
go

--inset 40000 rows resulting in 312 MB of data. They would be distributed in a round robin fashion between the files in the file group. Each file will be around 160 MB.
--while this query is still running, you can have a look at the files to note that they are growing sort of equally in a round robin fashion. Since the smallest allocation unit is an 
--extent, file 1 allocates an extent, then file 2 and then file 1 and so on
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO
insert into t1
	select REPLICATE('x',8000)
	from GetNums(1,40000)

--retreive file stats 
declare @dbid as int;
select @dbid=database_id from sys.databases where name='multipleFilegroups';
select b.type_desc,
		b.physical_name,
		a.*
from sys.dm_io_virtual_file_stats(@dbid,null) as a 
inner join sys.database_files as b on b.file_id = a.file_id
go

use master
go

alter database multipleFilegroups set single_user with rollback immediate 
drop database multipleFilegroups
go

--demonstrates halloween problem that can come up during an update execution plan. Spool operator(where the records that satify the where predicate are written to the temp) is used to protect against halloween problem.
--Spool operator separates the table from which data is being read and the table to which data is being written
create database HalloweenProtection
go

use HalloweenProtection
go

create table t
(
col1 int primary key,
col2 int,
col3 int 
)
go

create nonclustered index idx1 on t(col3);
go

insert into t(col1,col2,col3) values
(1,1,1),(2,2,2),(3,3,3)
go

update t
set col3 = col3*2 
from t with(index(idx1))--specifying the table again here just to use the index hint. Wonder if hints like these can be provided at the update statement level which would have avoided this!!
where col3<3 
go

use master
go

alter database HalloweenProtection set single_user with rollback immediate 
drop database HalloweenProtection
go


--cxpacket is not a indication of an problem always. In a parallel execution plan you will always have a cxpacket wait for the co-ordinator thread even if the worker threads finish on the same time.
--the co-ordinator thread initially dispatches the worker threads with work and then sits there waiting for them all to complete so to then combine the output of worker threads before the start of 
--the serial region of execution plan. If the worker threads do not finish on the same time, then the worker threads that have finished will also incur cxpacket waits.
use ContosoRetailDW
go

set statistics io on 
set statistics time on 
go

--. it runs a parallel execution plan in a endless loop
create procedure workload 
as 
begin
	while(1=1)
		Begin
			select StoreKey, count(*) from FactOnlineSales 
			group by StoreKey
		end
end 
go

dbcc sqlperf('sys.dm_os_wait_stats',clear);

----run the sp in a separate session
--use ContosoRetailDW
--exec workload;

--it will only show the co-ordinator thread
select * from sys.dm_exec_requests where wait_type='cxpacket'

select * from sys.dm_os_waiting_tasks where wait_type='cxpacket';
select * from sys.dm_os_wait_stats where wait_type='cxpacket' order by waiting_tasks_count;

--the session executing the request. status is set to 'suspended'
--the only thread we see in dm_exec_requests is the co-ordinator thread that runs the single threaded region of parallel plan. 
select wait_type, status, * from sys.dm_exec_requests where session_id = 55

--dm_os_waiting_tasks shows the threads running the parallel regions but in a indirect way. The rows you will see here all have exec_context_id=0 which is for co-ordinator thread. 
--But the column blocking_exec_context_id shows the thread on which the co-ordinator thread is waiting/bocked by and this thread is the thread running in parallel region.
select * from sys.dm_os_waiting_tasks where wait_type='cxpacket';

--now in this case since all the threads in parallel region were finishing at the same time, the cxpacket wait that is being shows in the dmvs is for the co-ordinator thread and it is not harmful.
--but if we had threads in dm_os_waiting_tasks with exec_context_id!=0, then that would mean one of the parallel thread is waiting for other prarallel threads to complete and that is something we have
--to investigate

--it is actually a demo for wait stats analysis as well
create database xeventsdemo;
go

use xeventsdemo;
go

--create a table and track wait stats for it
create table dummyTable
(
col1 int identity(1,1) not null primary key,
col2 int,
col3 char(8000)
);
go


--in a separate session run the following. Do not run it now but just open the session which will run it.. to trace the wait stats for this session we have to note the session id
--use xeventsdemo;
--go

--declare @i as int = 0;
--while(@i<200)
--	Begin
--		Begin tran
--			insert into dummyTable values
--			(@i,REPLICATE('x',8000));
--		commit tran
--		set @i+=1;
--	End
--go

--create a new 'extended event session' that collects wait stats for the session that is doing the 200 inserts above.
create event session CollectWaitStats
on server
add event sqlos.wait_info
(
	where sqlserver.session_id = 55
)
add target package0.event_file
(
	set filename = 'c:\temp\CollectWaitStats.xel'
)

--every extended event session is initiated with 'stop' state. So we have to start it
alter event session CollectWaitStats
on server
state = start
go

--now run the '200 insert' script from above in the separate session


drop event session CollectWaitStats
on server
go

--now open the exented events log file in ssms and add 'duration' and 'wait_type' columns to table. Then do grouping on 'wait_type' using the grouping button in toolbar.
--i only got 'writelog' and 'network_io' wait_type but it should have generated other wait_types as per demo?? Then use sum aggregation on duratin col and sort by descending to show which wait_types
--took most time. Now in my case 'writelog' had a sum of duration of 0. had the transaction log been on a slower drive, it would have shown up as bottleneck with a non-zero value.

use master
go


alter database CollectWaitStatsset set single_user with rollback immediate 
drop database CollectWaitStats
go

--this session tells you how many logical and physical reads a specific query needed during its execution
set statistics io on
go

use ContosoRetailDW
go

--this reports 47309 logical reads. 47309*8kb = around 369.6015625 MB was read from buffer pool to read the rowcount! But out of it only 47309 * 8060(payload size) = 363 MB is payload
select COUNT(*) from FactOnlineSales;
go

--lets review the buffer pool. It returns one row for every page cached in the buffer pool. This dmv seems to be only referring to the data cache section(and not the plan cache) of buffer pool??
--the size of plan-cache section of buffer pool can be found using sys.dm_exec_cached_plans
--178421 * 8KB = 1.3 GB of memory being used by buffer pool in sql server. Buffer pool is the largest component in RAM available to SQL server. How do we find the non-buffer pool memory total for sql server?
select * from sys.dm_os_buffer_descriptors
select distinct page_type from sys.dm_os_buffer_descriptors
select distinct database_id from sys.dm_os_buffer_descriptors
go

--now we find out which db takes how much space in buffer pool. it shows constosodb is taking around 366 MB(as we had run the query above on FactOnlineSales table)
select bd.database_id, DB_NAME(bd.database_id), COUNT_big(*) * 8192 /1024/1024 as [mb]
from sys.dm_os_buffer_descriptors as bd
group by bd.database_id
order by COUNT_BIG(*) desc

--now break down the memory usage at table level to find which table uses most space. since the following query also returns the allocation_unit_id to which the cached page belongs.
--now alllocation unit always belongs to a partition and a partition always belongs to a table(check the first demo in this script as well as the screen shot in doc file). 
select * from sys.dm_os_buffer_descriptors as bd
where database_id = DB_ID('ContosoRetailDW');

--now use allocation_unit_id to navigate upto the table level through metadata dmvs
select OBJECT_NAME(p.object_id) as [TableName],
 COUNT_big(*) * 8192 /1024 as [kb]
from sys.dm_os_buffer_descriptors as bd
inner join sys.allocation_units as au on au.allocation_unit_id = bd.allocation_unit_id
inner join sys.partitions as p on p.partition_id = au.container_id
inner join sys.tables as t on t.object_id = p.object_id
where database_id =  DB_ID('ContosoRetailDW') 
	and t.is_ms_shipped = 0 --exclude system tables
group by p.object_id
order by COUNT_big(*) desc

--24.
--reorganize and rebuild for index fragmentation. 
--rebuild builds a new index in your data file and then deallocated the old one. That means if the index size is 1 GB, then another 1GB would be used in the 
--data file and 1GB in transaction log(as rebuild is just one large transaction) for rebuild.
use AdventureWorks2012;
go

--we have 1 CI, 2 NCI and multiple XML indexes. 'avg_fragmentation_in_percent' as given by the dmv is the external fragmentation where the logical order of pages does not 
--match the physical order. The guideline is if the total number of pages is greater than 10,000, then:
--1) if the fragmentation is between 10% and 30%, then reorganize the index
--2) if the fragmentation is greater than 30%, then rebuild the index.
--you can pass these 3 parameters to olla hallengren's script 'indexoptimize'.
select *
from sys.dm_db_index_physical_stats(DB_ID('AdventureWorks2012'), OBJECT_ID('Person.Person'), null, null, 'limited');


--25.  isolation levels. isolation from acId is implemented by locks. READ COMMITED is default.
--when we specify isolation levels in sql server, we are only changing the how long the shared locks are held(S) and we have no control over 
--exclusive (X) locks. So we can only control how long a reader is holding a shared lock and we have no control over writers and the asscociated X lock
--read committed has problem of non-repeatable reads..if u read some data multiple times in a transaction, you might get different results.

use AdventureWorks2014;

--session 1(sessionid = 54)
begin tran 
update Person.Person
	set Title='mr'
	where BusinessEntityID=1

--u can still read the row in this session even though there is X lock(because it is in the same session?)
select * from Person.Person
where BusinessEntityID=1

rollback tran 

--session2(sessionid = 55). try to read. We are trying to acquire S lock but there already exists a incompatible X lock on the row. 
--The reader is blocked by the writer seesion(uncommited tran means the X lock is held even after the update finishes but you can 
--read the data in session1??). This session will wait indefinitely until S lock can be acquired
select * from Person.Person
where BusinessEntityID=1

--session 3. this situation can be analzyed the locks that were acquired using dbvs. now there is a shared lock acquired for select statement
--this leads to a blocking situation because we already have an exclusive lock.
--this dmv returns a row for every lock stored in the hashtable for the lock manager
select * from sys.dm_tran_locks 
where request_session_id in('54','55') and resource_type <> 'metadata'

--analyze the waiting tasks. the 2nd session is waiting for another session(column "blocking_session_id")
--the column "resource_description" tells us for which lock on which object we are waiting
select * from sys.dm_os_waiting_tasks
where session_id in('54','55') 

--the blocked session is currently suspended('status' column)
select * from sys.dm_exec_requests
where session_id in('54','55') 


--25. Repeatable read isolation level of a transaction. Once a shared lock is acquired(when a row is read), then that shared lock is held till the end of the transaction
--(rollback or commit). So if u have some rows in a transaction and then read them again, those rows would have no change. It is another matter there might be
-- some rows added to the result set(phantom rows).

--session 1: 55
use AdventureWorks2012;
go

set transaction isolation level repeatable read

-- shared locks are acquired as soon as we first access row and held until the end
begin tran
select * from Person.Person
--where ModifiedDate = '20030208'
where BusinessEntityID = 1;


--session 2: 53
use AdventureWorks2012;
go

--this update statement will be blocked. cannot acquire X lock as shared lock on the 
update Person.Person
set Title='Mr.'
where BusinessEntityID = 1;


--session 3. look into lock manager's hash table with the dmv. 
select * from sys.dm_tran_locks
where request_session_id in (53)
and resource_type = 'key'

select * from sys.dm_tran_locks
where request_session_id in (55)
and resource_type = 'key'

--session 1 
commit

--27. read uncommitted. Reader does not acquire a shared lock. It simply reads the data stored on the data page. Read uncommitted transaction isolation level is 
--the same as the query hint NOLOCK but is for the whole session(transaction). 

--session 1
use AdventureWorks2014;
go

begin tran
update Person.Person
set Title='mr'
where BusinessEntityID = 1;

--session 2 ..read uncommitted tran value which would be rolled back. dirty read.
use AdventureWorks2014;
go
set transaction isolation level read uncommitted
select * from Person.Person
where BusinessEntityID = 1;--could have also used NOCLOCK hint

--session 1
rollback

--28. Serializable. This is the last of the four psssimistic isolation levels. This is used to prevent phantom rows/records. No new rows would be added, existing rows deleted or updated in the range of rows read.
--sql server uses something called KEY RANGE LOCKING which uses specialized LOCKs on every row read. For KEY RANGE LOCKING, there has to be a NCI on the key being used to read the rows(search predicate). If no NCI present,
--SQL server uses shared lock(S) on the individual rows(which i think would not prevent phantom rows). And if you have more than 5000 S locks are taken on individual rows, then SQL server places a shared (S) table lock on the table. That makes the table reaonly. 
--Therefore it is important that your table has a supporting NCI.
use AdventureWorks2014;
go

set transaction isolation level serializable
go

--session 1
begin tran
--shared locks(actually KEY RANGE LOCKS as we have an NCI for the search predicate) are taken as soon as we first access the resource. The shared lock that is taken here is held until the end of the transaction.
select *
from Person.Address 
where StateProvinceID between 10 and 12	

--rollback

----session 2
--use AdventureWorks2014;
--go

--begin tran

----try to insert a row in the range locked by another tran(10 to 12). this would be blocked by the previous tran. Reader(SELECT) blocks the writer(INSERT).
--insert into person.Address (AddressLine1,AddressLine2,City,StateProvinceID,PostalCode,SpatialLocation,rowguid,ModifiedDate)
--values('','','',11,'',null,NEWID(),GETDATE());

--rollback

--session 3...now look in the hash table of the lock manager, we see that 21 KEY RANGE LOCKs have been acquired. But we have read just 20 rows??
--the insert statements waits to inserts in the range
select * from sys.dm_tran_locks
where request_session_id in (55)
and resource_type = 'key'
and resource_associated_entity_id = '72057594050117632'

--29. READ COMMITTED SNAPSHOT ISOLATION(RCSI). This is the first optimistic isolation level and is the optimistic implementation of pessimistic transaction isolation level READ COMMITTED. Pessimistic isolation levels 
--means we use locks for providing isolation. Shared Locks(S) are used for reads and Exclusive locks(X) for writes. Different pessimistic isolation levels differ in the time for which the S locks are held 
--and their granularity(for example single row S locks or key range locks). In optimistic isolation levels, readers do not acquire a shared lock(S) anymore. 
--RCSI does not give you dirty reads(as it name suggests as well).

--before we can use RCSI, it has to be enabled at the database level(as tempdb/version-store is used to hold old rows if we are making changes to them). As soon as you enable, there is nothting else u need to do and it 
--becomes the default isolation level.
alter database AdventureWorks2014 set read_committed_snapshot on;
go

--session 1:
use AdventureWorks2014;
go

begin tran
update Production.Product
set ReorderPoint = 1000--the old val is 750 which is copied to tempdb/version-store and other transactions will read 750 before session1 tran commits
where ProductID = 1;

--rollback tran

--session 2 
--use AdventureWorks2014;
--go

--begin tran
----these is no locking and blocking involved. in pessimistic isolation levels, the session 1 would have had a X lock on the row and that would have blocked session 2 from reading the row. There are no shared locks(S) anymore.
----It would have been a dirty read if value returned was 1000.
----It does not have read stability if we are reading the data multiple times in session2, session1 might complete and we will get different values here(750 while session1 is uncommited and 1000 when session 1 is committed)
--select ReorderPoint  from Production.Product
--where ProductID = 1;

----rollback

--30. Snapshot Isolation(SI). This again is an optimistic isolation level. It provides you with read stability: if you read data multiple times in a transaction, 
--you will always get back the same data and without locking. But you can get into update conflicts with snapshot isolation. Since some other transaction might 
--update the data in the meantime and then if your current transaction tries to update the data, it would encounter an error.

--this again is a database level option to be enabled before hand.
--alter database AdventureWorks2014 set allow_snapshot_isolation on

--session 1:
use AdventureWorks2014;
go

begin tran
	update Production.Product
	set ReorderPoint = 7500 --the old val is 750 which is copied to tempdb/version-store and other transactions will read 750 before session1 tran commits
	where ProductID = 1

--commit tran

--session 2
use AdventureWorks2014;
go

set transaction isolation level snapshot
go

begin tran
----these is no locking and blocking involved. in pessimistic isolation levels, the session 1 would have had a X lock on the row and that would have blocked session 2 from reading the row. There are no shared locks(S) anymore.
----It would have been a dirty read if value returned was 1000.
----It has read stability as if we are reading the data multiple times in session2 and session1 completes, we will still get the same value here(750 
---- for both when session1 is uncommited and 1000 when session 1 is committed)
--select ReorderPoint  from Production.Product
--where ProductID = 1;

----rollback

--the point to note is that SI does not mean you will get dirty reads as compared to RCSI. Both will return you committed values(as soon a tran starts 
--making changes, the old values are transferred to version store in tempdb) but that SI will keep returning
--the same value as it read at start even if the committed value changes due to changes made by some other tran. SI is a serializable optimistic isolation
--level. RCSI is not serializable. But because SI is serializable, you are not working with the latest committed value. And updating a stale value will result 
--in error 3960 (update conflict)


--31. Database Snapshots

--32: Temp tables vs table variables
--Temp tables introduce execution plan recompilations. If you are creating temp tables in a stored procedure, that table creation leads to a schema change(an addition of an index would also lead to schema change) which 
--invalidates the existing sp execution plan. So the stored procdeure creating the temp table is compiled again. Now when you add data to the temp table, its stats are are updated and if you try to select the use the temp
--table later in sp, the stats change will cause a further recompile. So you get 2 recompiles of sp, once on creation of temp table(due to shcema change) and once on its usage(after inserting some data into it which changes the stats)
--Table vars don't suffer from recompile issues(which is still persisted in tempdb). first table var is not counted as a schema change(as it onl a variable not a table) and second, stats on table vars are not maintained. They have
--a fixed cardinality value of 1. And because of this fixed cardinality, table vars are only sutiable for storing small amount of data. For larger number of rows, temp tables might be a better choice(as they have stats and hence 
--query optimizer can use that info to generate a decent query plan).

--to demo the recompiles, create a sql server profiler trace with following events:
--	1. Stored Procedures/SP:Recompile
--	2. TSQL/SQL:StmtRecompile

use AdventureWorks2014;
go

create proc DemonstrateTempTableRecompiles
as 
begin
	
	--recompile because of schema change
	create table #temptable
	(
		id int identity(1,1) primary key,
		firstname char(4000),
		lastname char(4000)
	)

	insert into #temptable(firstname, lastname)
	select top 1000 name, name from master.dbo.syscolumns


	--recompile because of stats change
	select * from #temptable

	drop table #temptable
end

exec DemonstrateTempTableRecompiles
go

create proc DemonstrateTableVarNoRecompiles
as 
begin
	
	--recompile because of schema change
	declare @temptable table
	(
		id int identity(1,1) primary key,
		firstname char(4000),
		lastname char(4000)
	)

	insert into @temptable(firstname, lastname)
	select top 1000 name, name from master.dbo.syscolumns
		
	select * from @temptable	
end

exec DemonstrateTableVarNoRecompiles
go

--33: Deadlocks
use tempdb;
go

create table t1
(
	c1 int
)
go

insert into t1 values(1)
go

create table t2
(
	c1 int
)
go

insert into t2 values(1)
go

--session 1 
begin tran
	--step1
	update t1
	set c1=2

	--step4
	--use Locks/Deadlock graph in profiler to capture deadlock graph
	update t2
	set c1=2

--commit tran

--session 2 
begin tran
	--step2
	update t2
	set c1=2

	--step3
	update t1
	set c1=2

--commit tran

--34: Statistics. Stats help the query optimizer estimate cardinality or the number of rows returned for a query so that it can compile a reasonably efficient physical execution plan. If the stats are out of data, query optimizer
--might produce a sub-optimal execution plan. Take an example of non covering NCI and a query filtering on the nci columns. out of date stats might cause the query optimizer to seek into the nci and perform a bookmark lookup into
--the heap or CI to get the other columns whereas it might be cheaper to just do a scan of heap or CI.

use MyDB;
go
set statistics io on

create table t
(
	col1 int,
	col2 int 
)
go

--insert 1500 records into table
insert into t(col1,col2)
select top 1500 ROW_NUMBER() over(order by (select null)), ROW_NUMBER() over(order by (select null)) 
from master.dbo.syscolumns 

--create nci on col2
create nonclustered index nci_test on t(col2);
go

--select a record by filtering on col2 so that seek into the NCI is done. check the estimated and actual number of rows in execution plan 
-- 3 logical reads
select *
from t where col2 =2

--sql server will auto update stats when 20% + 500 rows are updated/added. So we need 300 + 500 (800) data changes to trigger auto update of stats. adding 799 does not trigger update
--we added a lot more '2' values this time but the query optimizer still thinks there is only one value of 2 in col2. 
insert into t(col1,col2)
select top 799 ROW_NUMBER() over(order by (select null)), 2 
from master.dbo.syscolumns 

--out of date stats still cause seek into the NCI. check the estimated and actual number of rows in execution plan
-- 809 logical reads
select *
from t where col2 =2

--but doing a scan of the actual table costs us only 9 logical reads
select *
from t 

--now insert 1 additional row causing stats update.
insert into t(col1,col2)
select top 1 ROW_NUMBER() over(order by (select null)), 2 
from master.dbo.syscolumns 

--up to date stats cause scan of the underlying table instead of a NCI seek with a bookmark lookup. check the estimated and actual number of rows in execution plan
-- 9 logical reads
select *
from t where col2 =2


--35: crash recovery

create database crashrecovery
go

use crashrecovery
go

create table foo
(
col1 char(100) not null,
col2 char(100) not null,
col3 char(100) not null
)
go

--this mirrors transaction that has committed
insert into foo values
(
	replicate('a',100),
	replicate('b',100),
	replicate('c',100)
)
go

--this mirrors transaction that has not committed
begin tran 

update foo
	set col1 = 	replicate('x',100)

--run this in a separate session and then using sql server configuration manager, restart the sql server service
shutdown with nowait
go

--after the sql server was restarted, all the transactions that we committed since last checkpoint are redone(redo) and then all the transactions
--that were inflight/not committed are undone(undo). 
select * from foo

--40: columnstore indexes. in rowstore indexes, each page(8k size) stores all the column values for all the rows. In column store index, each page stores all the
--values for one column for all the rows. Don't we sort of do the same when we create a NCI on that column(albeit it also stores RID or CI key)?
use ContosoRetailDW;
go

--although we are only interested in 2 columns, all the other columns are also read into buffer pool from storage since we 
--store all columns on the data pages(in this case CI pages). So a lot of unnecessary IO and logical reads
select YEAR(datekey), MONTH(datekey), sum(salesamount)
from FactOnlineSales 
group by year(DateKey), month(DateKey)
order by year(DateKey), month(DateKey)

--create nonclustered columnstore index. clustered columnstore index were introduced in 2014. But note that there can be only 1 
--clustered index, so it can either be columnstore or rowstore.
create nonclustered columnstore index idx_cs_datekey_salesamount
on factonlinesales
(
datekey,
salesamount
)
go

--now the same query runs faster and a lot less logical reads
select YEAR(datekey), MONTH(datekey), sum(salesamount)
from FactOnlineSales 
group by year(DateKey), month(DateKey)
order by year(DateKey), month(DateKey)

--41: Simple recovery model. Recovery models tell us which database backups we can perform and how much data loss we might experience
--if we have to restore ur db. Suppose if you have Simple recovery model and are taking Full and Differential backups.
--Transaction log backups are not possible with recovery model simple. And that is the problem. You loose all your committed
-- tranactions between Full and differential backups. SIMPLE recovery model is good for dbs where have mostly static data/no changes 
--like datawarehousing dbs. Take into account the data and log files while talking about recovery models

create database testdb
go

--by default FULL recovery model is used. Change it to SIMPLE
alter database testdb
	set recovery simple with no_wait

use testdb
go

create table tt
(
FID int 
)
go

--this won't work due to incompatible recovery model
backup log testdb to disk = 'c:\temp\testLogbkp.trn'

--FULL backup works
backup database testdb to disk = 'c:\temp\testLogbkp.bak'

--this transaction will be lost if we do not perform FULL or Differential backups after this
insert into tt values(1)

use master
go
drop database testdb

--42: FULL recovery model (default for a db) enables the use of transaction log backups which have to be performed regularly to not loose 
--committed transactions in case of a crash. FULL and differential backups can be very big in size as they are total or accumulative backups.
--Transaction log backup remains small in size as they are in a sense truely differential in nature(and for that reason they also take 
--less time to perform). But a long chain of log backups might take long time to restore wherease FULL and Differential might take less time.
--You can still loose data as if a crash happens after the last transaction log backup, then all transactions committed after it will be lost. 
--So it all comes down to how regularly u perform log backups (or for that matter other backups in general)
--You restore your latest FULL, latest Differential and then all the transaction log backups after the differential backup to just before 
--the point where crash happened.
--Why can't we just take FULL backups(or FULL_Differential) at the same regular intervals as transaction log backups? Time taken to complete
--the transaction log backup would be small(assuming you haven't changed the all the data in the db in that time frame) and thus chances of 
--data loss are minimal. But Full or Differential would take a lot longer and hence there is a chance that if crash happens before backup is 
--complete, the transactions committed during that time would be lost. Keeping the time frame same, the first differential backup would take 
--same time as first transation log backup after a full backup. But after the first differential backup, the succeeding differential backups
--would take a lot longer(as well mcuh bigger in size) as they are accumulative compared to succeeding tran log backups. Tran log backups 
--are the true differential backups!
--If using FULL recovery model, take regular tran log backups as otherwise the tran log will keep on growing? Why does not the tran log keeps
--on growing when using SIMPLE recovery? Take into account the data and log files while talking about recovery models

create database testdb
go

--by default FULL recovery model is used. 
use testdb
go

create table tt
(
FID int 
)
go

--this won't work as we have not taken a FULL backup as yet
backup log testdb to disk = 'c:\temp\testLogbkp.trn'

--FULL backup has to be performed before a tran log backup can be taken
backup database testdb to disk = 'c:\temp\testLogbkp.bak'

--now it works
backup log testdb to disk = 'c:\temp\testLogbkp.trn'

--this transaction will be lost if we do not perform FULL or Differential backups after this
insert into tt values(1)

--take another log backup
backup log testdb to disk = 'c:\temp\testLogbkp1.trn'


use master
go
drop database testdb

--43: Bulk-Logged recovery model helps keep your transaction log small if you are working with minimally loggged operations(like bcp, bulk insert, insert select
-- create or alter index, etc.) in sql server. When you are going to perform minimally logged operation, you can switch your database to Bulk-logged recovery model
--Say if you are running a CI rebuild on a table of 1 GB in full recovery model(what happens in simple?), then the transaction log would grow by 1 GB in size. But 
--if you are running the same operation under Bulk logged recovery model, then sql server just marks/logs those extents that have changed in data file. So the tran 
--log stays quite small. You should change the recovery model immediately after minimally loged operation is complete. If you then take a tran log backup afterwards 
--(ideally after changing recovery model), sql server copies individual changed records from tran log but also copies all the extents, marked as changed,
-- from your data file into your tran log backup. So that means ultimately the size of the tran log backup is same as that would have been in recovery model full
--but the size of tran log itself is smaller.

use ContosoRetailDW
go

--assuming simple recovery model, tran log file size remains same while data file size increases by 340 mb as to do a rebuild it needs free space equivalent 
--to size of table.
--assuming full recovery model, the tran log file size increases by 260 mb and data file size remains same
--assuming bulk logged recovery model, both log and data file sizes remain unchanged!
alter index pk_FactOnlineSales_SalesKey on FactOnlineSales rebuild
go

--assuming we were using full recovery model and had taken a Full backup, the tran log file size increases by 260 mb and data file size remains same

--now backup the tran log. this backup file is around 360 mb large
backup log ContosoRetailDW to disk = 'c:\temp\delLog1.trn'
go


--change the recovery model to simple, so that we can shrink the whole transaction log to get rid of old transaction log records
--and then switch recovery mode to bulk logged
alter database ContosoRetailDW set recovery simple with no_wait

dbcc shrinkfile('ContosoRetailDW2.0_log',0)

alter database ContosoRetailDW set recovery bulk_logged with no_wait

--now we only generate 80mb of data in tran log
alter index pk_FactOnlineSales_SalesKey on FactOnlineSales rebuild
go

--the following throws an error saying there is no current database backup. so log backup can't be performed
--now again backup the tran log. this backup file is again the same size, around 260 mb large
backup log ContosoRetailDW to disk = 'c:\temp\delLog_bloklogged.trn'
go

--so bulk logged recovery model has no influence on tran log backups but only minimizes the tran log size when you run minimally logged operations.