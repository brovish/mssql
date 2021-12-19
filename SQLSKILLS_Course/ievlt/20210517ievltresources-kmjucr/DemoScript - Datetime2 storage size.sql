create table test1
(
	c1	int	identity,
	c2	datetime
);

create table test2
(
	c1	int	identity,
	c2	datetime2(7)
);
go

create table test3
(
	c1	int	identity,
	c2	datetime2(4)
);

create table test4
(
	c1	int	identity,
	c2	datetime2(2)
);
go

insert test1 values (getdate());
insert test2 values (getdate());
insert test3 values (getdate());
insert test4 values (getdate());
go

select object_name(object_id), min_record_size_in_bytes, max_record_size_in_bytes from sys.dm_db_index_physical_stats(db_id(), object_id('test1'), null, null, 'detailed')
select object_name(object_id), min_record_size_in_bytes, max_record_size_in_bytes from sys.dm_db_index_physical_stats(db_id(), object_id('test2'), null, null, 'detailed')
select object_name(object_id), min_record_size_in_bytes, max_record_size_in_bytes from sys.dm_db_index_physical_stats(db_id(), object_id('test3'), null, null, 'detailed')
select object_name(object_id), min_record_size_in_bytes, max_record_size_in_bytes from sys.dm_db_index_physical_stats(db_id(), object_id('test4'), null, null, 'detailed')
go
