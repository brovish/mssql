/*============================================================================
  File:     Indexed Views Quick Setup.sql

  Summary:  Quickly setup indexed views so that we can do a comparison!

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

-- DROP VIEW dbo.SumOfAllChargesByMember

CREATE VIEW dbo.SumOfAllChargesByMember
	WITH SCHEMABINDING  -- required if you plan to index this view!
AS
SELECT c.member_no AS MemberNo, 
	COUNT_BIG(*) AS NumberOfCharges, -- required when GROUP BY is in an indexed view!
	SUM(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
GROUP BY c.member_no
go

--DROP INDEX dbo.SumOfAllChargesByMember.SumofAllChargesIndex

CREATE UNIQUE CLUSTERED INDEX SumofAllChargesIndex
	ON dbo.SumOfAllChargesByMember (MemberNo) 
go

