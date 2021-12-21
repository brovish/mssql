/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures06-NCIndexOnClusteredTable.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 06 of Analyze Structures is about the key in a nonclustered
			index when created on a clustered table.
  
  Date:     April 2009 (for Inside SQL Server, version SQL Server 2008)
  UPDATED:	For SQL Server 2012+ with DMV queries
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [IndexInternals];
go

-- To review the physical structures of a nonclustered index created 
-- on a table that is clustered, we review the UNIQUE constraint on 
-- the SSN column of the Employee table.
sp_helpindex [Employee];
go

-- To see the index ID assigned to this nonclustered index, we can 
-- use a query against sys.indexes:
SELECT name AS IndexName, index_id
FROM sys.indexes
WHERE [object_id] = OBJECT_ID ('Employee');
go

-- Or, you can use my modified version of sp_helpindex
-- You can grab sp_SQLskills_helpindex here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC [sp_SQLskills_helpindex] 'dbo.FactInternetSales';
GO

--RESULT:

-- IndexName        index_id
-- ---------------- --------
-- EmployeePK       1
-- EmployeeSSNUK    2

-- Once we know the index ID then we can use that for parameter 3.
SELECT [PS].[index_depth] AS [D]
    , [PS].[index_level] AS [L]
    , [PS].[record_count] AS [RCount]
    , [PS].[page_count] AS [PCount]
    , [PS].[avg_page_space_used_in_percent] AS [PgPercentFull]
    , [PS].[min_record_size_in_bytes] AS [MinLen]
    , [PS].[max_record_size_in_bytes] AS [MaxLen]
    , [PS].[avg_record_size_in_bytes] AS [AvgLen]
FROM [sys].[dm_db_index_physical_stats]
    (DB_ID ('IndexInternals')
    , OBJECT_ID ('IndexInternals.dbo.Employee')
    , 2
    , NULL
    , 'DETAILED') AS [PS];
go

-- Notice that the default behavior does NOT match our slide/numbers...
-- Why? Because the table has not been upgraded to 2012 structures...
ALTER INDEX ALL ON [dbo].[employee] REBUILD;
GO

-- The first step is to go to the root page of the nonclustered index:

SELECT [PA].[page_level] AS [IndexLevel]
	, [PA].[allocated_page_file_id] AS [PageFID]
	, [PA].[allocated_page_page_id] AS [PagePID]
	, [PA].[previous_page_file_id] AS [PrevPageFID]
	, [PA].[previous_page_page_id] AS [PrevPagePID]
	, [PA].[next_page_file_id] AS [NextPageFID]
	, [PA].[next_page_page_id] AS [NextPagePID]
	--, *
FROM [sys].[dm_db_database_page_allocations]
	(DB_ID()
	, OBJECT_ID('Employee')
	, 2
	, NULL
	, 'DETAILED') AS [PA]
WHERE [PA].[is_allocated] = 1
ORDER BY [IndexLevel] DESC, [PrevPagePID];
go


-- The Root Page is PageFID = 1, PagePID = 8768
DBCC TRACEON (3604)
go

DBCC PAGE (IndexInternals, 1, 8768, 3);
go

-- Leaf-level pages are labeled with an IndexLevel of 0
-- The first page of the leaf level is on page 4,264 of File ID 1. 
DBCC PAGE (IndexInternals, 1, 8762, 3);
go

-----------------------------------------------------------------------------
-- Navigate the Employee table from the nonclustered SSN Index to find a row
------------------------------------------------------------------------------

SELECT e.*
FROM dbo.Employee AS e
WHERE e.SSN = '123-45-6789'; -- '123-07-9786';
go

-- We already know the root page from above, PageFID = 1, PagePID = 4328
DBCC PAGE (IndexInternals, 1, 4328, 3);
go

-- Review the values. For the 24th row, you can see a low value of 123-07-8319, 
-- and for the 25th row, a low value of 140-02-4721. So if the value 123-45-6789 exists, 
-- it would have to be on ChildFileId = 1 and ChildPageId = 4287.

DBCC PAGE (IndexInternals, 1, 4287, 3);
go

-- Reviewing the output, does 123-45-6789 exist? 
--
-- NO. The values go from 
--  SSN: 123-07-9980 for EmployeeID 37281 TO
--  SSN: 140-00-0079 for EmployeeID	26561

-- NOTE: The data looks a bit strange but that because of 
--       how it was generated.  


-----------------------------------------------------------------------------
-- Identical indexes aren't always as obvious as you might think?!
-- And, some look the same but aren't!
------------------------------------------------------------------------------

-- What do our indexes look like right now:
EXEC sp_helpindex '[dbo].[Employee]';
EXEC sp_SQLskills_helpindex '[dbo].[Employee]';
go

-- What if??
CREATE INDEX [SSN_NonUnique] 
	ON [dbo].[Employee] ([SSN]);
go

CREATE INDEX [SSNEmpID_NonUnique] 
	ON [dbo].[Employee] ([SSN], [EmployeeID]);
go

CREATE UNIQUE INDEX [SSNEmpID_Unique] 
	ON [dbo].[Employee] ([SSN], [EmployeeID]);
go

EXEC sp_helpindex '[dbo].[Employee]';
EXEC sp_SQLskills_helpindex '[dbo].[Employee]';
go

EXEC sp_SQLskills_SQL2008_finddupes '[dbo].[Employee]';
-- you can get this code here: https://www.sqlskills.com/blogs/kimberly/removing-duplicate-indexes/
go
