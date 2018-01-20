-- Demo script for Analyzing Table Structures demo.

-- Cleanup from any previous demo
USE [master];
GO

IF DATABASEPROPERTYEX (N'JunkDB', N'Version') > 0
BEGIN
	ALTER DATABASE [JunkDB] 
		SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [JunkDB];
END
GO

-- Create a "scratch" database
CREATE DATABASE [JunkDB];
GO

USE [JunkDB];
GO

CREATE TABLE [LargeFixedWidthTable]
(
	[col1]	INT				IDENTITY,
	[col2]	CHAR (8000)		DEFAULT 'overflow',
	[col3]	CHAR (8000)		DEFAULT 'overflow',
	[col4]	CHAR (8000)		DEFAULT 'overflow',
	[col5]	VARCHAR (max)	DEFAULT 'LOB',
	[col6]	VARCHAR (max)	DEFAULT 'LOB'
);
-- This will generate the following error:
-- Msg 1701, Level 16, State 1, Line 2
-- Creating or altering table 'LargeFixedWidthTable' 
-- failed because the minimum row size would be 24011, 
-- including 7 bytes of internal overhead. This exceeds 
-- the maximum allowable table row size of 8060 bytes.
GO

CREATE TABLE [LargeVariableWidthTable]
(
	[col1]	INT				IDENTITY,
	[col2]	VARCHAR (8000)	DEFAULT 'overflow',
	[col3]	VARCHAR (8000)	DEFAULT 'overflow',
	[col4]	VARCHAR (8000)	DEFAULT 'overflow',
	[col5]	VARCHAR (MAX)	DEFAULT 'LOB',
	[col6]	VARCHAR (MAX)	DEFAULT 'LOB'
);
GO

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, NULL); -- Limited mode
GO

-- Insert a few very small (narrow) rows
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	('x', 'y', 'z', 'a', 'b');
GO 10

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, NULL); -- Limited mode
GO

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, N'DETAILED'); -- detailed mode
GO

-- Insert a wide (but under 8060 bytes) row
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	('x', 'y'
	, REPLICATE ('x', 8000),
	'a', 'b');
GO

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, N'DETAILED'); -- detailed mode
GO
-- LOBs and SLOBs are stored in the IN_ROW_DATA structure
-- IF they fit.

-- Insert a slightly wider row but only
-- wider for limited lob values
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	
	('x'
	, REPLICATE ('x', 8000)
	, REPLICATE ('x', 8000),
	'a', 'b');
GO

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, N'DETAILED'); -- detailed mode
GO
-- This row was larger than 8060 bytes and so one
-- of the columns has overflowed to a newly created
-- overflow structure.
-- Notice that the LOBs columns are still stored in
-- the IN_ROW_DATA structure. IF they fit under the
-- 8060 byte row structure.

-- Insert a slightly wider row AND a wider
-- lob value (but not over 8000 bytes)
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	
	('x'
	, REPLICATE ('x', 8000)
	, REPLICATE ('x', 8000),
	REPLICATE ('a', 1000), 'b');
GO

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, N'DETAILED'); -- detailed mode
GO
-- Both of the overflow values were pushed off page
-- and the IN_ROW_DATA still stored the LOB value.
-- In this case, because the LOB value is small
-- and the limited LOB values are larger.

-- Insert a slightly wider row AND a true lob 
-- value (LOB values can be up to 2GB in size)
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	
	('x'
	, REPLICATE ('x', 8000)
	, REPLICATE ('x', 8000),
	REPLICATE (CONVERT (VARCHAR (MAX), 'a'), 10000), 'b');
GO

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'LargeVariableWidthTable')
		, NULL
		, NULL
		, N'DETAILED'); -- detailed mode
GO
-- Now, we see the addition of the LOB data structure