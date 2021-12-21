create database TestRowLen
go

USE TestRowLen;
go

create table dbo.testssn
(
    ID  int identity
    , SSN char(11)    NOT NULL  default '123-45-6789'
    , SSN2 char(11)   NULL      
)
go

create unique clustered index CLind ON testssn (ID)
go

create unique nonclustered index NCind on testssn (SSN)
-- Header (TagA)    = 1
-- Fixed width      = 4 + 11

go

create nonclustered index NCind2 on testssn (SSN)
go

create unique nonclustered index NCind3 on testssn (SSN2)
go

create nonclustered index NCind4 on testssn (SSN2)
go

insert testssn (ssn, ssn2) 
select ssn, ssn from IndexInternals.dbo.Employee
go

select * from testssn;

sp_SQLskills_helpindex testssn;
go

SELECT index_depth AS D
    , index_level AS L
    , record_count AS 'Count'
    , page_count AS PgCnt
    , avg_page_space_used_in_percent AS 'PgPercentFull'
    , min_record_size_in_bytes AS 'MinLen'
    , max_record_size_in_bytes AS 'MaxLen'
    , avg_record_size_in_bytes AS 'AvgLen'
FROM sys.dm_db_index_physical_stats
    (DB_ID ('TestRowLen')
    , OBJECT_ID ('testssn')
    , 2
    , NULL
    , 'DETAILED');
GO

SELECT index_depth AS D
    , index_level AS L
    , record_count AS 'Count'
    , page_count AS PgCnt
    , avg_page_space_used_in_percent AS 'PgPercentFull'
    , min_record_size_in_bytes AS 'MinLen'
    , max_record_size_in_bytes AS 'MaxLen'
    , avg_record_size_in_bytes AS 'AvgLen'
FROM sys.dm_db_index_physical_stats
    (DB_ID ('TestRowLen')
    , OBJECT_ID ('TestRowLen.dbo.testssn')
    , 3
    , NULL
    , 'DETAILED');
GO

SELECT index_depth AS D
    , index_level AS L
    , record_count AS 'Count'
    , page_count AS PgCnt
    , avg_page_space_used_in_percent AS 'PgPercentFull'
    , min_record_size_in_bytes AS 'MinLen'
    , max_record_size_in_bytes AS 'MaxLen'
    , avg_record_size_in_bytes AS 'AvgLen'
FROM sys.dm_db_index_physical_stats
    (DB_ID ('TestRowLen')
    , OBJECT_ID ('TestRowLen.dbo.testssn')
    , 4
    , NULL
    , 'DETAILED');
GO

SELECT index_depth AS D
    , index_level AS L
    , record_count AS 'Count'
    , page_count AS PgCnt
    , avg_page_space_used_in_percent AS 'PgPercentFull'
    , min_record_size_in_bytes AS 'MinLen'
    , max_record_size_in_bytes AS 'MaxLen'
    , avg_record_size_in_bytes AS 'AvgLen'
FROM sys.dm_db_index_physical_stats
    (DB_ID ('TestRowLen')
    , OBJECT_ID ('TestRowLen.dbo.testssn')
    , 5
    , NULL
    , 'DETAILED');
GO

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (TestRowLen, testssn, 2)');
go

SELECT IndexLevel
    , PageFID
    , PagePID
    , PrevPageFID
    , PrevPagePID
    , NextPageFID
    , NextPagePID
FROM sp_tablepages
ORDER BY IndexLevel DESC, PrevPagePID;
go

-- The Root Page is PageFID = 1, PagePID = 4328
DBCC TRACEON (3604)
go

DBCC PAGE (JunkD, 1, 13586, 1);
go