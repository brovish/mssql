/*============================================================================
  File:     Index Rebuild Walkthrough.sql

  Summary:  This script walks you though all of the concepts/processes
			in rebuilding indexing.

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
 
-- In this exercise you will walk through a scenario using the sample database CREDIT.
-- You will modify a relatively low percentage of rows however, the fragmentation created as 
-- a result is high. Performance is affected - both for insert speed as well as in needed 
-- maintenance costs.

USE Credit
go

---------------------------------------------------------------------------------------------------
--1) Create a working version of the Member table called Member2. 
---------------------------------------------------------------------------------------------------

IF OBJECTPROPERTY(object_id('Member'), 'IsUserTable') = 1
	DROP TABLE dbo.Member2 
go

SELECT * 
INTO dbo.Member2
FROM dbo.Member

---------------------------------------------------------------------------------------------------
--2) Create indexes on the Member2 table to simulate a realworld environment.
---------------------------------------------------------------------------------------------------

ALTER TABLE dbo.Member2
ADD CONSTRAINT Member2PK
	PRIMARY KEY CLUSTERED (Member_no)
go

CREATE INDEX Member2NameInd 
ON dbo.Member2(LastName, FirstName, MiddleInitial)
go

CREATE INDEX Member2RegionFK
ON dbo.Member2(region_no)
go

CREATE INDEX Member2CorpFK
ON dbo.Member2(corp_no)
go

---------------------------------------------------------------------------------------------------
--3)  Verify the indexes
---------------------------------------------------------------------------------------------------
EXEC sp_helpindex Member2
go
SELECT object_name(id) AS tablename, indid, name
FROM sysindexes
WHERE object_id('Member2') = id
go
SELECT object_name([object_id]) AS tablename, [index_id], name
FROM sys.indexes
WHERE object_id('Member2') = [object_id]
go

---------------------------------------------------------------------------------------------------
--4) Verify the fragmentation of the indexes
---------------------------------------------------------------------------------------------------
-- 	NOTE: Because the indexes have just been created no fragmentation should exist.
--	In other words, the scan density should be 100% and the extent scan fragmentation 
--	will likely be 0 (however, this is not necessarily guaranteed).

-- Prior to SQL Server 2000 you needed the object ID (so you might run into this "snippet" of code)
	DECLARE @ObjID	int
	SELECT @ObjID = object_id('Member2')
	DBCC SHOWCONTIG(@ObjID)
-- but
-- SQL Server 2000+ supports the object name 
	DBCC SHOWCONTIG('Member2') 
-- and
-- SQL Server 2005 uses DMVs to review density and fragmentation
-- must be in SQL Server 2005 compatibility mode or you'll get syntax errors
sp_dbcmptlevel credit, 90;
go

SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')

---------------------------------------------------------------------------------------------------
-- 5) Simulate Data Modifications/Activity
---------------------------------------------------------------------------------------------------

-- By updating varchar data you will cause the row size to change. Modifications against the 
-- Member2 table will be performed by executing a single update statement that updates 
-- roughly 5% of the table. For completeness, the script takes note of the total time it takes to 
-- execute the modification (this can be helpful to compare).

DECLARE @StartTime	datetime, 
		@EndTime	datetime,
		@NumRowsMod		int,
		@TotalTime			int
SELECT @StartTime = getdate()
UPDATE Member2
	SET street = '1234 Main St.',
		city = 'Anywhere'
WHERE Member_no % 19 = 0
SELECT @NumRowsMod = @@RowCount
SELECT @EndTime = getdate()
SELECT  @TotalTime = datediff (ms, @StartTime, @EndTime) 
SELECT @NumRowsMod AS 'RowsModified', @TotalTime AS 'TOTAL TIME (ms)',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime AS 'Rows per ms',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime*1000 AS 'Estimated Rows per sec'
go
-- Keep track of the time: 93
-- Keep track of the number of rows: 526
-- Keep track of the rows/ms: 5.7

---------------------------------------------------------------------------------------------------
-- 6) Let's look at the effect that this has had on our Member2 table.
---------------------------------------------------------------------------------------------------

-- Use the DMV to review the table's fragmentation
SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go

-- 	NOTE: the fragmentation should be extreme as the 
--  avg_fragmentation_in_percent will probably be a VERY high
-- 	number. (should be somewhere around 83%)
--	For such a "fast" operation, I bet you didn't really
--  expect that much fragmentation?

---------------------------------------------------------------------------------------------------
-- 7) How do we fix this fragmentation?
---------------------------------------------------------------------------------------------------

-- Can we rebuild or must we defrag (HA requirements?)
-- To REBUILD - Many Options
--	2005 ONLY
--		ALTER INDEX ... REBUILD
--			WITH (ONLINE = ON)
--		ALTER INDEX ... REBUILD
--			WITH (ONLINE = OFF)
--	7.0 and higher
-- 		CREATE with DROP_EXISTING
--  6.5 and higher
-- 		DBCC DBREINDEX (added in SQL Server 6.5)
--	Any version
-- 		DROP and reCREATE (any version)

-- To DEFRAG - 1 Option - 2000 and Higher
-- 		DBCC INDEXDEFRAG (added in SQL Server 2000)

-- 	Why REBUILD?
--	  Pros
-- 		Rebuilding not only defrags but moves the object for better location
-- 		and more effective scans. Not only should you see the SCAN DENSITY
-- 		go up (to 100 after the rebuild) but you will should also see EXTENT SCAN
-- 		fragmentation drop (closer to 0 - but that's not guaranteed).  Additionally,
--		once rebuilt the statistics will be as accurate as they could possibly be.
--		A rebuild restructures your table and updates the information needed
--		for the optimizer to make better decisions.
--	  Cons - Availability
--		Rebuilding the clustered index requires an exclusive table level lock
--		Rebuilding the nonclustered index requires a shared table level lock
--	  Cons - Transaction Log Space & Time
--		Rebuilding an index when the database recovery model is FULL will
--		take more time and log space. Additionally, the transaction log cannot
--		be cleared until the index rebuild has completed. You can save BOTH
--		time and space by setting the database recovery model to BULK_LOGGED.
--		However, making that change has other possibly negative side-effects.
--		There are some trade-offs in using this recovery model and you should
--		take some time to fully understand the impact that this change may have
-- 		on both the ability to backup the transaction log (accessing the "tail" of 
--		the log for up-to-the-minute recovery is NOT supported) as well as the 
--		options available when restoring a log (Point-in-time recovery is not supported 
--		when restoring a log that was successfully backed up while the database 
--		was in the bulk_logged recovery model - and a bulk operation has occurred).
--	  NOTE: Rebuilding a clustered index does NOT typically require the 
--		non-clustered indexes to be rebuilt. However, if the clustered index
--		has been created on a non-unique column(s) then rebuilding the 
--		clustered index will also rebuild ALL of that table's non-clustered indexes.


--	Why DEFRAG?
--	  Pros - Availability
--		Defraging a table does NOT require table level locks and therefore it does
--		not require a table to be taken "offline." 
--	  Pros - Not a single LARGE transaction
--		One benefit of defraging is that while the transaction log will be filled with 
--		potentially more information than rebuilding; it will not be performed in
--		one single transaction. Instead the defrag operation is performed as many
--		mini-transactions. Depending on the severity of the table's fragmentation this
--		may create more or less log rows.
--   	    syntax
--            DBCC INDEXDEFRAG(credit, Member2, Member2cl)

------------------------
-- Considering the level of fragmentation we need to rebuild or defrag... But which?
-- 	* DROP and RECREATE
-- 	    	This is more challenging than it sounds considering our clustered index is our Primary Key. 
-- 		Because of this it is not realistic to drop and recreate because we would have to drop all of the
-- 		foreign keys which reference it. Because of this requirement, SQL Server added DBCC DBREINDEX in
--		SQL Server 6.5. Additionally because the non-clustered indexes depend on the clustered index value
-- 		dropping and recreating will cause the non-clustered indexes to be rebuilt twice! If you ever need to
-- 		drop and recreate a clustered index make sure you perform the drops/creates in this order:
--			Drop ALL non-clustered indexes
--			Drop the clustered index
--			Recreate the clustered index
--			Recreate ALL non-clustered indexes
-- 
-- 	* DBCC DBREINDEX (added in SQL Server 6.5)
-- 	    	This is said to be in SQL Server 2000 for backward compatibility however it does have one big 
--		advantage over the other [and newer 7.0] option in that it's a lot easier to programmatically execute
--		due to its easier syntax.  
-- 	    syntax
-- 		DBCC DBREINDEX (Member2, Member2PK, 90) 	--sets the new fillfactor
-- 		DBCC DBREINDEX (Member2, Member2PK) 		-- Use the OrigFillFactor (from sysindexes)
--
-- 	* CREATE with DROP_EXISTING (added in SQL Server 7.0)
-- 	    	Because indexing strategies changed between 6.5 and 7.0 this command was added to allow the 
--	 	clustered index to be changed easily. If used with the same definition as the current cl/nc index
--		then this does not provide any benefit over DBCC DBREINDEX. The greatest benefit is that you can
--		CHANGE the defintion of the clustered index and only have to rebuild the non-clustered indexes 
--		once. This command is much more complex to automate as the syntax requires the entire
--		CREATE INDEX statement to be recreated. Also, it requires that the original index name be used.
--		If you want to change the name of the index you can use sp_rename before or after the change to
--		better reflect the new definition.
--
--        CREATE WITH DROP_EXISTING when you DO NOT CHANGE the definition of the CL index
--            WILL NOT rebuild the nonclustered indexes
--        CREATE WITH DROP_EXISTING when you CHANGE the definition of the CL index
--            WILL rebuild the nonclustered indexes using their OrigFillFactor (from sysindexes)
-- 	    syntax
-- 		CREATE UNIQUE CLUSTERED INDEX Member2pk
-- 			ON Member2(Member_no)
-- 			WITH FILLFACTOR = 90, DROP_EXISTING
-- 
--	IF original index is 
-- 		CREATE  CLUSTERED INDEX Member2CL
-- 			ON Member2(lastname, firstname, middleinitial)

-- 		CREATE UNIQUE CLUSTERED INDEX Member2CL  --requires the same name
-- 			ON Member2(Member_no)
-- 			WITH FILLFACTOR = 90, DROP_EXISTING

-- Finally, after all that - we're going to REBUILD our index in this example. For simplicity
-- we're going to choose DBCC DBREINDEX. However, we need to also choose a better 
-- FILLFACTOR. The server defaults to 100 so to reduce the level of fragmentation that occurs
-- after this rebuild we're going to rebuild while leaving a small amount of free space for
-- future modifications to use and not cause page splits.

---------------------------------------------------------------------------------------------------
-- 8) So how do we choose our fillfactor?
---------------------------------------------------------------------------------------------------

-- I wish there were a trivial number to choose for fillfactor but this one will need to be determined
-- by a number of factors. First, you have to look at what's causing fragmentation.
-- Are Inserts and/or Updates are causing the splits???
-- Inserts?
--	If the table has a clustered index on an ever increasing key (such as an identity column) then 
--	INSERTs will not cause page splits. If you can focus on clustering on an ever-increasing key
-- 	you can naturally minimize splits. 
-- 	If you do have splits due to inserts and cannot change the clustering key then you will want a lower fillfactor
--	If you don't then you can go for a relatively high number - depending on the impact of updates?
-- Updates?
-- 	If the table has updates to variable width fields and the values increase in the number of bytes then you 
--	need to determine the likely number of modifications and number of bytes that each page should have available
--	for these changes. If ONLY updates cause splits then it's not as troublesome as when BOTH INSERTs and UPDATEs 
--	cause splits. To reduce splits due to updates consider using DEFAULT constraints as place holders (instead of NULL)
--	and consider fixed-width columns for some of the smaller columns (although the DEFAULT option is more realistic).

-- Finally, let's put the two options together...
ALTER INDEX Member2PK ON Member2 REBUILD
	WITH (ONLINE = ON, FILLFACTOR = 90)
go
ALTER INDEX Member2PK ON Member2 REBUILD
	WITH (ONLINE = OFF, FILLFACTOR = 90)
go
ALTER INDEX Member2PK ON Member2 REBUILD
	WITH (FILLFACTOR = 90)
go

-- Here's the syntax to the old way to do this:
-- DBCC DBREINDEX (Member2, Member2PK, 90)
go

---------------------------------------------------------------------------------------------------
-- 9) Recheck the fragmentation
---------------------------------------------------------------------------------------------------
SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go

-- At this point the avg_fragmentation_in_percent should be 100% and the extent scan fragmentation may
-- be higher but will likely be lower. This is hard to know because the index was "moved"
-- due to the rebuild and it's not certain that contiguous space will be available for the
-- rebuild. 
-- Also, the average page density should show that there's 10% available on each page.
-- This is what we expect as we chose 90% for the fillfactor.

---------------------------------------------------------------------------------------------------
-- 10) Execute another modification - of more rows with the potential for more fragmentation....
---------------------------------------------------------------------------------------------------

DECLARE @StartTime	datetime, 
		@EndTime	datetime,
		@NumRowsMod		int,
		@TotalTime			int
SELECT @StartTime = getdate()
UPDATE Member2
	SET street = '1234 Main St.',
		city = 'Anywhere'
WHERE Member_no % 17 = 0
SELECT @NumRowsMod = @@RowCount
SELECT @EndTime = getdate()
SELECT  @TotalTime = datediff (ms, @StartTime, @EndTime) 
SELECT @NumRowsMod AS 'RowsModified', @TotalTime AS 'TOTAL TIME (ms)',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime AS 'Rows per ms',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime*1000 AS 'Estimated Rows per sec'
go
-- Keep track of the time: 33
-- Keep track of the number of rows: 588
-- Keep track of the rows/ms: 17.8

---------------------------------------------------------------------------------------------------
-- 11) Again, check the fragmentation....
---------------------------------------------------------------------------------------------------

SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go

-- NOTE: While more rows were modified it took less time and did not create fragmentation.

---------------------------------------------------------------------------------------------------
-- 12) Execute another modification - of even more rows with the potential for even more fragmentation....
---------------------------------------------------------------------------------------------------

DECLARE @StartTime	datetime, 
		@EndTime	datetime,
		@NumRowsMod		int,
		@TotalTime			int
SELECT @StartTime = getdate()
UPDATE Member2
	SET street = '1234 Main St.',
		city = 'Anywhere'
WHERE Member_no % 11 = 0
SELECT @NumRowsMod = @@RowCount
SELECT @EndTime = getdate()
SELECT  @TotalTime = datediff (ms, @StartTime, @EndTime) 
SELECT @NumRowsMod AS 'RowsModified', @TotalTime AS 'TOTAL TIME (ms)',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime AS 'Rows per ms',
	convert(decimal(8,3), @NumRowsMod)/@TotalTime*1000 AS 'Estimated Rows per sec'
go
-- Keep track of the time: 30
-- Keep track of the number of rows: 909
-- Keep track of the rows/ms: 30.3

---------------------------------------------------------------------------------------------------
-- 13) Again, check the fragmentation....
---------------------------------------------------------------------------------------------------

SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), OBJECT_ID('Credit.dbo.Member2'), 1, NULL, 'detailed')
go