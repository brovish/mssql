/*============================================================================
  File:     Using dm_db_index_physical_stats.sql

  Summary:  This script goes through all of the different types
			of execution related to index physical statistics.
			Also, includes tips and tricks if executing outside
			of the current database.

  Date:     June 2006

  SQL Server Version: 9.00.2047.00 (SP1)
------------------------------------------------------------------------------
  Copyright (C) 2005-2006 Kimberly L. Tripp, SYSolutions, Inc.
  All rights reserved.

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE Master
go

-- All base objects, ALL databases
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), NULL, NULL, NULL, NULL)
go

database_id	object_id
14	1941581955
select db_name(14)
select object_name(1941581955)

select * from sys.indexes where object_id = 1941581955 and index_id = 3

sp_helpindex ticketsalesq3

-- All base objects, Only in specified database
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id('Credit'), NULL, NULL, NULL, NULL)
go

-- All base objects, Only in specified database
-- NULL and DEFAULT have same meaning within this function.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id('Credit'), DEFAULT, DEFAULT, DEFAULT, DEFAULT)
go

-- Specified object, in specified database
-- NOTE: Must use FULLY qualified names if executing
-- outside of the database.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id('Credit')
	, object_id('Credit.dbo.Charge')
	, NULL
	, NULL
	, 'DETAILED')
go

USE Credit
go

-- All base objects, in CURRENT database
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), NULL, NULL, NULL, NULL)
go

-- All previous executions use the default MODE of 'Limited'
-- Specifying limited doesn't change the results...

-- Limited returns the leaf level only 
-- and only external fragmentation details.
-- Places an IS lock on table. 
-- Concurrent modifications (except X-Table lock) ARE allowed.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('Charges')
	, NULL, NULL, 'LIMITED')
go

-- Sampled returns details about the leaf level only 
-- but includes internal fragmentation as well as external.
-- Useful on larger tables as it does NOT read the entire
-- table. Good for a detailed (relatively fast) estimate.
-- Places an IS lock on table. 
-- Concurrent modifications (except X-Table lock) ARE allowed.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), object_id('Charges'), NULL, NULL, 'SAMPLED')
go
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), object_id('Charge'), INDEX_ID(, NULL, 'SAMPLED')
go

-- Detailed should be used for a thorough evaluation of ALL
-- levels of an index, including the b-tree. However, this
-- may take a considerable amount of time on large tables 
-- and may cause blocking.
-- Places a S-lock on the table. 
-- Concurrent modifications are **NOT** allowed.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), object_id('Charges'), NULL, NULL, 'DETAILED')
go

-- What about partitions?
-- One requirement is that you MUST state the index
-- for which you want to see partitions.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id(), object_id('Charges'), 1, 0, 'DETAILED')
go

sp_helpfile


select * from sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL, 'LIMITED')
select object_name(object_id), * from sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'LIMITED')
select object_name(object_id), * from sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'LIMITED')