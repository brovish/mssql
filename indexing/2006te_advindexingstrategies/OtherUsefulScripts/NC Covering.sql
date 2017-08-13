/*============================================================================
  File:     NC Covering.sql

  Summary:  Uses a series of options to return the data for a given range query.
			Create the indexes first (they're currently commented out) and then
			use the statistics io and showplan to see how the forced plans for
			each of the queries execute.
  
  Date:     June 2005

  SQL Server Version: 9.00.1116.08 (April CTP)
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

SET STATISTICS IO ON
-- Turn Graphical Showplan ON (Ctrl+K)

USE CREDIT
go

SELECT m.LastName, m.FirstName, m.Phone_No
FROM dbo.Member AS m WITH (INDEX (0))
WHERE m.LastName LIKE '[S-Z]%'
go

--CREATE INDEX MemberLastName ON Member(LastName)
go

SELECT m.LastName, m.FirstName, m.Phone_No
FROM dbo.Member AS m WITH (INDEX (MemberLastName))
WHERE m.LastName LIKE '[S-Z]%'
go

--CREATE INDEX NCLastNameCombo ON Member(LastName, FirstName, Phone_No)
go

SELECT m.LastName, m.FirstName, m.Phone_No
FROM dbo.Member AS m
WHERE m.LastName LIKE '[S-Z]%'
go

--CREATE INDEX NCLastNameCombo2 ON Member(FirstName, LastName, Phone_No)
go

SELECT m.LastName, m.FirstName, m.Phone_No
FROM dbo.Member AS m WITH (INDEX (NCLastNameCombo2))
WHERE m.LastName LIKE '[S-Z]%'
go

-- If you want to clean up the indexes:
--DROP INDEX Member.MemberLastName
--DROP INDEX Member.NCLastNameCombo
--DROP INDEX Member.NCLastNameCombo2