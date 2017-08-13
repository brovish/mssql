/*============================================================================
  File:     Viewing Statistics Information.sql

  Summary:  See how statistics get automatically created based on query 
			scan. View sys.indexes,	use stats_date, use dbcc show_statistics 
			and use dbcc show_statistics to produce multiple tabular data sets.
  
  Date:     June 2006

  SQL Server Version: 9.00.2047.00 (SP1)
------------------------------------------------------------------------------
  Copyright (C) 2005-2006 Kimberly L. Tripp, SYSolutions, Inc.
  All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE CREDIT
go

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/resources/conferences/CreditBackup80.zip

-- NOTE: This is a SQL Server 2000 backup and MANY examples will work on 
-- SQL Server 2000 in addition to SQL Server 2005.

sp_helpindex Member
exec sp_helpstats Member
go

CREATE INDEX MemberName ON Member(Lastname, FirstName, MiddleInitial)
go

DBCC SHOW_STATISTICS('Member', 'MemberName')
go

-- Using Density for LastName
SELECT 10000 * 0.03846154 

-- Using Density for LastName, FirstName Combo
SELECT 10000 * 9.9999997E-5

-- Is it true?
-- FOR LastName
SELECT m.LastName, COUNT(*)
FROM dbo.member AS m
GROUP BY m.LastName
go

SELECT AVG(Counts.GroupCounts)
FROM (SELECT m.LastName, COUNT(*) AS GroupCounts
		FROM dbo.member AS m
		GROUP BY m.LastName) AS Counts
go

-- FOR LastName, FirstName
SELECT m.LastName, m.FirstName, COUNT(*)
FROM dbo.member AS m
GROUP BY m.LastName, m.FirstName
go

SELECT AVG(Counts.GroupCounts)
FROM (SELECT COUNT(*) AS GroupCounts
		FROM dbo.member AS m
		GROUP BY m.LastName, m.FirstName) AS Counts
go

-- So - what does this tell us about the relationship between LastNames and FirstNames?
exec sp_helpindex member
exec sp_helpstats member -- look at messages window (Object does not have any stats)

-- Update a few rows to later seach on, etc. (not enough to change distribution OR statistics)
UPDATE dbo.Member
	SET LastName = 'Tripp'
	WHERE Member_no IN (678, 9234)
go

UPDATE dbo.Member
	SET LastName = 'Tripp',
		FirstName = 'Kimberly'
	WHERE Member_no = 1234
go

sp_helpstats Member
go

-- What would you expect this query to do?
SET STATISTICS IO ON --(turn on showplan with Ctrl+K)
go

SELECT m.LastName, m.FirstName, m.MiddleInitial, m.Phone_no, m.City
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kim%'

-- Table Scan (always an option)
-- No Indexes to help find FIRSTNAMES...
-- What about scanning the NC index on LN,FN,MI and then doing bookmarks lookups...
-- seems risky? Would be good if we were guaranteed to only find a VERY small 
-- number of people with firstnames like 'Kim%'?

-- Is this always a good - generally it works well BUT nothing beats REAL statistics? 
-- In fact, SQL Server created statistics on the FirstName column...
exec sp_helpindex member
exec sp_helpstats member

-- Does the existence of "statistics" mean that you MUST create an index... NO but it 
-- is likely that the column is being used in SARGs and/or Join Conditions so it's 
-- something to think about - asking ITW/DTA?

sp_helpstats Member
go

DBCC SHOW_STATISTICS('Member', '_WA_Sys_00000003_0CBAE877')
go

SELECT m.Firstname, count(*) 
FROM dbo.Member AS m
where m.FirstName BETWEEN 'BNXLYLDIIIMRT' AND 'BYGJS'
GROUP BY m.Firstname HAVING count(*) > 1
go

-- To see all of your indexes and the last time the stats were updated
SELECT 
	object_name(si.[object_id]) 	AS [TableName]
	, CASE 
		WHEN si.[index_id] = 0 then 'Heap'
		WHEN si.[index_id] = 1 then 'CL'
		WHEN si.[index_id] BETWEEN 2 AND 250 THEN 'NC ' + RIGHT('00' + convert(varchar, si.[index_id]), 3)
		ELSE ''
	  END 							AS [IndexType]
	, si.[name] 					AS [IndexName]
	, si.[index_id]					AS [IndexID]
	, CASE
		WHEN si.[index_id] BETWEEN 1 AND 250 AND STATS_DATE (si.[object_id], si.[index_id]) < DATEADD(m, -1, getdate()) 
			THEN '!! More than a month OLD !!'
		WHEN si.[index_id] BETWEEN 1 AND 250 AND STATS_DATE (si.[object_id], si.[index_id]) < DATEADD(wk, -1, getdate()) 
			THEN '! Within the past month !'
		WHEN si.[index_id] BETWEEN 1 AND 250 THEN 'Stats recent'
		ELSE ''
	  END 							AS [Warning]
	, STATS_DATE (si.[object_id], si.[index_id]) 	AS [Last Stats Update]
FROM sys.indexes AS si
WHERE OBJECTPROPERTY(si.[object_id], 'IsUserTable') = 1
ORDER BY [TableName], si.[index_id]
go

-- Quick query w/subquery to see stats_date
SELECT stats_date(object_id('member'), 
	(SELECT index_id 
	FROM sys.indexes AS si
	WHERE object_name(si.[object_id]) = 'Member'
		AND name = 'MemberName'))
go

-- Seeing each tabular set from DBCC SHOW_STATISTICS 

DBCC SHOW_STATISTICS('Member', 'MemberName')
WITH STAT_HEADER 
go

DBCC SHOW_STATISTICS('Member', 'MemberName')
WITH DENSITY_VECTOR
go

DBCC SHOW_STATISTICS('Member', 'MemberName')
WITH HISTOGRAM
go

-- How do you use these programmatically
-- First, create a table into which this information will be inserted
-- Second, use dynamic string execution with an insert...exec to populate

CREATE TABLE MemberNameHistogram
(
	RANGE_HI_KEY			nvarchar(900),
	RANGE_ROWS				bigint,
	EQ_ROWS					bigint,
	DISTINCT_RANGE_ROWS		bigint,
	AVG_RANGE_ROWS			bigint,
)
go

INSERT MemberNameHistogram
EXEC ('DBCC SHOW_STATISTICS(''Member'', ''MemberName'') WITH HISTOGRAM')
go

SELECT * FROM MemberNameHistogram
go

SELECT 
	object_name(si.[object_id]) 	AS [TableName]
	, CASE 
		WHEN si.[stats_id] = 0 then 'Heap'
		WHEN si.[stats_id] = 1 then 'CL'
		WHEN INDEXPROPERTY ( si.[object_id], si.[name], 'IsAutoStatistics') = 1 THEN 'Stats-Auto'
		WHEN INDEXPROPERTY ( si.[object_id], si.[name], 'IsHypothetical') = 1 THEN 'Stats-HIND'
		WHEN INDEXPROPERTY ( si.[object_id], si.[name], 'IsStatistics') = 1 THEN 'Stats-User'
		WHEN si.[stats_id] BETWEEN 2 AND 250 THEN 'NC ' + RIGHT('00' + convert(varchar, si.[stats_id]), 3)
		ELSE 'Text/Image'
	  END 							AS [IndexType]
	, si.[name] 					AS [IndexName]
	, si.[stats_id]					AS [IndexID]
	, CASE
		WHEN si.[stats_id] BETWEEN 1 AND 250 AND STATS_DATE (si.[object_id], si.[stats_id]) < DATEADD(m, -1, getdate()) 
			THEN '!! More than a month OLD !!'
		WHEN si.[stats_id] BETWEEN 1 AND 250 AND STATS_DATE (si.[object_id], si.[stats_id]) < DATEADD(wk, -1, getdate()) 
			THEN '! Within the past month !'
		WHEN si.[stats_id] BETWEEN 1 AND 250 THEN 'Stats recent'
		ELSE ''
	  END 							AS [Warning]
	, STATS_DATE (si.[object_id], si.[stats_id]) 	AS [Last Stats Update]
FROM sys.stats AS si
WHERE OBJECTPROPERTY(si.[object_id], 'IsUserTable') = 1
--	AND (INDEXPROPERTY ( si.[object_id], si.[name], 'IsAutoStatistics') = 1 
--			OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsHypothetical') = 1 
--			OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsStatistics') = 1)
ORDER BY [Last Stats Update] DESC
go

sp_updatestats
go

sp_createstats 'indexonly', 'fullscan'
go

sp_helpstats member
go
-- New stats are listed as User-Stats
