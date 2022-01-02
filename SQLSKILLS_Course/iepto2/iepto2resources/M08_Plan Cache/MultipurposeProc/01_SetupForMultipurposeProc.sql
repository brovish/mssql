/*============================================================================
  File:     SetupForMultipurposeProc.sql

  Summary:  This is the "setup" procedure for our demo.
  
  SQL Server Version: 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-----------------------------------------------------
-- SETUP
-----------------------------------------------------

-- First, restore / setup the credit database

-- Second, tweak a few things for this demo...

-----------------------------------------------------
-- Demo Setup 
-----------------------------------------------------

USE [Credit];
GO

--SELECT * FROM [member]
--SELECT * FROM [AdventureWorks2014].[Person].[Address]

-- Let's bring over a few more rows...
-- (you don't have to do this part but a bit more data
-- makes the demo more interesting)
-- Can use AdventureWorks2012 OR AdventureWorks2014

INSERT [member] ([region_no], [firstname], [middleinitial]
    , [lastname], [member_code], [street], [city]
    , [state_prov], [mail_code], [country])
SELECT ([p].[BusinessEntityID] % 9) + 1 AS [region_no]
      ,SUBSTRING([FirstName], 1, 15) AS [firstname]
      ,ISNULL(SUBSTRING(ISNULL([MiddleName]
        , SUBSTRING(LastName, 2, 1)), 1, 1), 'S') AS [middleinitial]
      ,SUBSTRING([LastName], 1, 15) AS [Lastname]
      , ([p].[BusinessEntityID] % 29) + 1 AS [member_code]
      , ISNULL (SUBSTRING ([a].[AddressLine1], 1, 15), '')
      , ISNULL (SUBSTRING ([a].[city], 1, 15), '')
      , ISNULL (SUBSTRING(CONVERT(VARCHAR, [a].[StateProvinceID]), 1, 2), '')
      , ISNULL (SUBSTRING(CONVERT(VARCHAR, [a].[PostalCode]), 1, 5), '')
      , ''
FROM [AdventureWorks2012].[Person].[Person] AS [p]
    LEFT OUTER JOIN [AdventureWorks2012].[Person].[BusinessEntityAddress] AS [be]
        ON [p].BusinessEntityID = [be].BusinessEntityID
    LEFT OUTER JOIN [AdventureWorks2012].[Person].[Address] AS [a]
        ON [be].[AddressID] = [a].[AddressID];
GO

-- You MUST do these modifications
-- Create another unique column in the member table
ALTER TABLE [dbo].[member]
ADD [Email] NVARCHAR (128);
GO

-- Give all employees a middle initial
UPDATE [dbo].[member]
    SET [middleinitial]
        = UPPER(ISNULL(SUBSTRING([firstname], 3, 1), 'Q'));
GO

-- Add a couple of "interesting" rows ;-)
UPDATE [dbo].[member]
	SET [lastname] = 'Tripp'
        , [firstname] = 'Kimberly'
        , [middleinitial] = 'L'
	WHERE [member_no] = 1234;
GO

UPDATE [dbo].[member]
	SET [lastname] = 'Randal'
        , [firstname] = 'Paul'
        , [middleinitial] = 'S'
	WHERE [member_no] = 2479;
GO

-- Give all employees an email
UPDATE [dbo].[member]
    SET [member_code] = ([member_no] % 29) + 1
        , [Email] = CONVERT(NVARCHAR, [firstname])
                + N'.'
                + CONVERT(NVARCHAR, [middleinitial])
                + N'.'
                + CONVERT(NVARCHAR, [lastname])
                + N'@company'
                + RIGHT ('00' + CONVERT(VARCHAR, 
                    ([member_no] % 29) + 1), 2)
                + N'.com';
GO

SELECT COUNT(*) 
FROM [Member]; -- 29996
GO

SELECT TOP 1000 *
FROM [Credit].[dbo].[member]
WHERE [member_no] % 100 = 0
ORDER BY [lastname];
GO 

-- ***** THE DATA *****
-- names are everything from goofy to realistic
-- not every field has been populated...
-- biggest problem is that the data set is very
-- small

-- ***** THE SEARCHES *****
-- And, because we're going to have these columns in
-- a WHERE clause, let's also make sure there's an 
-- index on each of these columns.

-- IMPORTANT NOTE:
-- I'm not saying this is a good idea but it's
-- often done to "help" these types of searches

-- Add an index to SEEK for FirstNames
CREATE INDEX [MemberFirstName] 
ON [dbo].[member] ([FirstName]);
GO

-- Add an index to SEEK for LastNames
CREATE INDEX [MemberLastName] 
ON [dbo].[member] ([LastName]);
GO

-- Add an index to SEEK for Email
CREATE INDEX [MemberEmail] 
ON [dbo].[member] ([Email]);
GO

-- Add an index to SEEK for member_code
CREATE INDEX [MemberCode] 
ON [dbo].[member] ([member_code]);
GO

-- If you want to see all of the indexes currently on
-- the member table:
EXEC [sp_helpindex] '[dbo].[member]';
GO