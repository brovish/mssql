/*============================================================================
  File:     Bookmark Lookup v Table Scan.sql

  Summary:  At what point is a bookmark query NOT selective enough to
			warrant the overhead of the relatively "random" I/Os that
			occur? Is it 50%, 30%, 10% or ???.
  
  Date:     June 2006

  SQL Server Version: 9.00.2047.00 (SP1)
------------------------------------------------------------------------------
  Copyright (C) 2006 Kimberly L. Tripp, SYSolutions, Inc.
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

-------------------------------------------------------------------------------
-- (1) Create two tables which are copies of charge:
-------------------------------------------------------------------------------

-- Create the HEAP
SELECT *
INTO ChargeHeap
FROM Charge
go

-- Create the CL Table
SELECT *
INTO ChargeCL
FROM Charge
go

CREATE CLUSTERED INDEX ChargeCL_CLInd 
	ON ChargeCL (member_no, charge_no)
go

-------------------------------------------------------------------------------
-- (2) Add the same non-clustered indexes to BOTH of these tables:
-------------------------------------------------------------------------------

-- Create the NC index on the HEAP
CREATE INDEX ChargeHeap_NCInd ON ChargeHeap (Charge_no)
go

-- Create the NC index on the CL Table
CREATE INDEX ChargeCL_NCInd ON ChargeCL (Charge_no)
go

-------------------------------------------------------------------------------
-- (3) Begin to query these tables and see what kind of access and I/O returns
-------------------------------------------------------------------------------

-- Get ready for a bit of analysis:
SET STATISTICS IO ON
-- Turn Graphical Showplan ON (Ctrl+K)

-- First, a point query (also, see how a bookmark lookup looks in 2005)
SELECT * FROM ChargeHeap
WHERE Charge_no = 12345
go

SELECT * FROM ChargeCL
WHERE Charge_no = 12345
go

-- What if our query is less selective?
-- 1000 is .0625% of our data... (1,600,000 million rows)
SELECT * FROM ChargeHeap
WHERE Charge_no < 1000
go

SELECT * FROM ChargeCL
WHERE Charge_no < 1000
go

-- What if our query is less selective?
-- 16000 is 1% of our data... (1,600,000 million rows)
SELECT * FROM ChargeHeap
WHERE Charge_no < 16000
go

SELECT * FROM ChargeCL
WHERE Charge_no < 16000
go

-------------------------------------------------------------------------------
-- (4) What's the EXACT percentage where the bookmark lookup isn't worth it?
-------------------------------------------------------------------------------

-- What happens here: Table Scan or Bookmark lookup?
SELECT * FROM ChargeHeap
WHERE Charge_no < 4000
go

SELECT * FROM ChargeCL
WHERE Charge_no < 4000
go

-- What happens here: Table Scan or Bookmark lookup?
SELECT * FROM ChargeHeap
WHERE Charge_no < 3000
go

SELECT * FROM ChargeCL
WHERE Charge_no < 3000
go

-- And - you can narrow it down by trying the middle ground:
-- What happens here: Table Scan or Bookmark lookup?
SELECT * FROM ChargeHeap
WHERE Charge_no < 3500
go

SELECT * FROM ChargeCL
WHERE Charge_no < 3500
go

-- And again:
SELECT * FROM ChargeHeap
WHERE Charge_no < 3250
go

SELECT * FROM ChargeCL
WHERE Charge_no < 3250
go

-- And again:
SELECT * FROM ChargeHeap
WHERE Charge_no < 3375
go

SELECT * FROM ChargeCL
WHERE Charge_no < 3375
go

-- Don't worry, I won't make you go through it all :)








-- For the Heap Table (in THIS case), the cutoff is: 0.21%
SELECT * FROM ChargeHeap
WHERE Charge_no < 3383
go
SELECT * FROM ChargeHeap
WHERE Charge_no < 3384
go


-- For the Clustered Table (in THIS case), the cut-off is: 0.21%
SELECT * FROM ChargeCL
WHERE Charge_no < 3438

SELECT * FROM ChargeCL
WHERE Charge_no < 3439
go