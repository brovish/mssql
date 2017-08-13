/*============================================================================
  File:     Indexing for Aggregates.sql

  Summary:  This script sets up the queries and indexes needed to show performance
			gains for indexing aggregate queries.

  Date:     June 2006

  SQL Server Version: 9.00.2047.00 (SP1)
------------------------------------------------------------------------------
  Copyright (C) 2005 Kimberly L. Tripp, SYSolutions, Inc.
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

-- Review your index list
EXEC sp_helpindex charge
go

-- Let's start to analyze some queries and their performance:
SET STATISTICS IO ON
go

-------------------------------------------------------------------------------
-- Start with a simple aggregate
-------------------------------------------------------------------------------

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c	
GROUP BY c.member_no
go

-- Notice that the data does not come back ordered by the GROUP BY
-- HASH aggregates do NOT return the data ordered. 
-- You MUST add order by if you want the data ordered.

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c	
GROUP BY c.member_no
ORDER BY c.member_no
go
-- Notice that adding the ORDER BY also adds an additional step to sort
-- the data. Depending on the result size, this could be expensive!

-------------------------------------------------------------------------------
-- What if we didn't need to TABLE SCAN to get the data
-- What if another index was created for another higher priority
-- query - that covered this query??!
-------------------------------------------------------------------------------

CREATE INDEX Covering1 
ON dbo.charge(charge_amt, member_no) 
	-- Not in order by the Group By 
go

SELECT member_no AS MemberNo, 
	sum(charge_amt) AS TotalSales
FROM dbo.charge 
GROUP BY member_no
ORDER BY member_no
go
-- Notice that we still see a HASH AGGREGATE but on a narrower
-- set... When we compare all of these you'll see that this yields 
-- fewer I/Os and is therefore a less expensive plan.
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(0))
GROUP BY c.member_no
ORDER BY c.member_no
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
GROUP BY c.member_no
ORDER BY c.member_no
go

-------------------------------------------------------------------------------
-- What if we didn't need to do a HASH aggregate to access/sum the data
-- What if we covered this query in the order of the GROUP BY?
-- Then you can "stream" the aggregates as you move through the data...
-------------------------------------------------------------------------------

-- There are two ways of doing this really:
CREATE INDEX Covering2 
ON charge(member_no, charge_amt) 
go

-- Or use include:
CREATE INDEX CoveringWithInclude 
ON dbo.charge (member_no)
INCLUDE (charge_amt)
go

-- In terms of size, there's NO difference:
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('charge'), NULL, NULL, NULL)
go

-- Incorrect syntax??! Why? Cause we're not in SQL 2005 compat mode:
sp_dbcmptlevel credit, 90
go

SELECT index_id, [name]
FROM sys.indexes
WHERE object_id = object_id('charge')
go

SELECT * 
FROM sys.dm_db_index_physical_stats(db_id(), object_id('charge'), NULL, NULL, 'detailed')
WHERE index_id IN (7,8)
go

-------------------------------------------------------------------------------
-- OK, so they're the same structures but what about query perf
-------------------------------------------------------------------------------

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(Covering2))
GROUP BY c.member_no
ORDER BY c.member_no
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(CoveringWithInclude))
GROUP BY c.member_no
ORDER BY c.member_no
go

-------------------------------------------------------------------------------
-- Now - let's compare ALL three
-------------------------------------------------------------------------------

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX (0))
GROUP BY c.member_no
ORDER BY c.member_no
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX (Covering1))
GROUP BY c.member_no
ORDER BY c.member_no
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(CoveringWithInclude))
GROUP BY c.member_no
ORDER BY c.member_no
go

-- But.. in all cases we still needed to compute the aggregate!
