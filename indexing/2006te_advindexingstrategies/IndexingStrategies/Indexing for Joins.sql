/*============================================================================
  File:     Indexing for Joins - Credit.sql

  Summary:  Various tests and index access patterns using 5 table joins.
  
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

-- Let's start to analyze some queries and their performance:
SET STATISTICS IO ON
go

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c
		INNER JOIN dbo.provider AS p 
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s 
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r 
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500

-- Where is all the cost? (Highest number in showplan output...)
	-- Should be in charge!

-- SO - what does the charge table need in this query?
-- SELECT List		statement_no, charge_amt
-- Join Cond1		member_no
-- Join Cond2		provider_no
-- Join Cond3		statement_no
-- Search Arg		charge_amt

-------------------------------------------------------------------------------
-- First, let's get this plan as our base test case... review the 
-- showplan and FORCE every single index listed.
-------------------------------------------------------------------------------

-- USE:
--	0 = Table Scan
--	1 = Clustered Index Seek/Scan
--	name = for all non-clustered indexes (or name for all, name is a bit safer)

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c WITH (INDEX (1))
		INNER JOIN dbo.provider AS p WITH (INDEX (provider_ident))
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m WITH (INDEX (member_ident)) 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s WITH (INDEX (statement_ident))
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r WITH (INDEX (region_ident))
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500

-------------------------------------------------------------------------------
-- Let's move to phase II 
-------------------------------------------------------------------------------

-- Create "test" Indexes with priority (first column - or high order element) 
-- given to the search argument or the join and come up with some test cases... 
-- Try out the query again and see which one it chooses! Always put the cols of the
-- select list last!!!! They are the least significant!

-- First try just covering the sarg and join - in this case there is no sarg
-- Realize that phase II RARELY works for LOW selectivity. You need to have
-- better join density than we do in order for this to help... but, let's 
-- give it a shot for the join that's really expensive (to member):
CREATE INDEX testa_1 
	ON charge(charge_amt, member_no)
go

CREATE INDEX testa_2 
	ON charge(member_no, charge_amt)
go

-- Compare against first plan
SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c WITH (INDEX (1))
		INNER JOIN dbo.provider AS p WITH (INDEX (provider_ident))
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m WITH (INDEX (member_ident)) 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s WITH (INDEX (statement_ident))
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r WITH (INDEX (region_ident))
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c
		INNER JOIN dbo.provider AS p 
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s 
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r 
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

-------------------------------------------------------------------------------
-- As expected, Phase II didn't help us. The join density is just NOT
-- selective enough. So, let's move to phase III.
-------------------------------------------------------------------------------

DROP INDEX charge.testa_1 
DROP INDEX charge.testa_2 
go

-- You have two options here... figure out Phase III manually OR use DTA
-- DTA will review A LOT more than just the "expensive" table, it will
-- review the entire query. Is that always good or always bad?! Let's see!

-- What about covering the QUERY...
-- CREATE INDEX testb_1 
--	ON charge(charge_amt, member_no, provider_no, statement_no)
-- CREATE INDEX testb_2 
--	ON charge(member_no, charge_amt, provider_no, statement_no)

-- Let's do this a bit iteratively though... I'm not going to blindly 
-- implement ALL of DTAs indexes. I'm going to start slowly - with 
-- just the indexes against charge:
SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c WITH (INDEX (1))
		INNER JOIN dbo.provider AS p WITH (INDEX (provider_ident))
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m WITH (INDEX (member_ident)) 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s WITH (INDEX (statement_ident))
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r WITH (INDEX (region_ident))
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c
		INNER JOIN dbo.provider AS p 
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s 
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r 
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

-- What changed... OK, add the new DTA index into the second plan below and
-- then go back and add ALL of DTAs recommendations... then compare:

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c WITH (INDEX (1))
		INNER JOIN dbo.provider AS p WITH (INDEX (provider_ident))
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m WITH (INDEX (member_ident)) 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s WITH (INDEX (statement_ident))
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r WITH (INDEX (region_ident))
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
--	FROM dbo.Charge AS c WITH (INDEX (***DTA_INDEX_NAME_HERE***))
	FROM dbo.Charge AS c WITH (INDEX ([_dta_index_charge_6_229575856__K2_K6_K3_K7]))
		INNER JOIN dbo.provider AS p WITH (INDEX (provider_ident))
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m WITH (INDEX (member_ident)) 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s WITH (INDEX (statement_ident))
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r WITH (INDEX (region_ident))
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c
		INNER JOIN dbo.provider AS p 
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s 
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r 
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500
go

-- Is it really worth it to add ALL of DTAs recommended indexes???
-- It depends on how much you really gain and whether or not your
-- data modification statements suffer as a result of these extra 
-- indexes! I can't answer that... you'll need to! ;-)