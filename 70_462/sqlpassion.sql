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
