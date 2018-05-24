--create database testdb
--go

--use testdb
--go
--create table tbl
--(
--	firstname char(50),
--	lastname char(50),
--	address char(100)
--)
--go

--insert into tbl values
--('ramneek','singh','sdfdsghgfh 32 esdfsdf,ewr')
--go 2


dbcc traceon(3604)--need for dbcc page command
--find which data pages belong to our tbl. columns PageFID and PagePID.
--this will return 2 pages: IAM page with pagetype 10 and data page
dbcc ind(testdb,tbl,-1)

--remember page header size is 96 bytes, then we have payload and then the rowoffset array(aslot array).
--row offset array need 2 bytes to store location for each record
--dump the first data page using FID and PID of the page. First record in data pages are at offset 96
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

drop database testdb

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

--execute in session 1
while(1=1)
begin
	update deadlock
	set col1 = col1 + 1
	where col3 =1;
end


--execute in session 2
set transaction isolation level repeatable read
--set transaction isolation level  read committed
go

while(1=1)
begin
	select * from deadlock with (index(idx_col3))
	where col3 =1
end


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

--insert 80,000 records
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

drop database UniqueCIStructure;

