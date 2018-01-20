-- Demo script for Secondary Errors demo.

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

CREATE INDEX [LargeVariableWidthTable_NCIND_col2_col3] 
ON [LargeVariableWidthTable]
([col2], [col3]);
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

-- Insert a large value for col3
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	('x'
	, REPLICATE ('y', 8000)
	, REPLICATE ('z', 8000),
	'a', 'b');
GO

-- Insert a large combined value for col2 + col3
INSERT [LargeVariableWidthTable]
		([col2]
		, [col3]
		, [col4]
		, [col5]
		, [col6])
VALUES	(REPLICATE ('x', 450)
	, REPLICATE ('y', 451)
	, 'z',
	'a', 'b');
GO
