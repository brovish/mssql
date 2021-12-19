/*============================================================================
  File:     CreditPV-Setup.sql

  Summary:  This script has all of the syntax needed to create the a partitioned
			table structure to compare/contrast partitioned views and partitioned
			tables within the Credit database.
			
			This will allow you to see the differences between PVs and PTs
			using two comparable partitioning stategies.

  SQL Server Version: 2008+ (script updated for SQL 2019)
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com
  All rights reserved.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills.com  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Walk your way through this script... there's a TON of cool stuff in here. 
-- (1) You'll setup for Partitioned Views by creating four files and four filegroups 
--     for the Partitioned View and a last file/filegroup for staging data. 
-- (2) You'll copy data into a staging area and then build the clustered indexes
--     on the appropriate filegroup.
-- (3) Once all of the data is partitioned then you'll create a partitioned view using 
--     UNION ALL.
-- (4) You'll run queries against the Partitioned View and you'll see how the optimizer
--     removes redundant data from the execution plan. 
-- (5) What about indexed views used with partitioned views. No, you can't index a partitioned
--     view however, you can create views and then index them - against the base tables.
--     Take for example the sum of charge by member. If you've partitioned June/July/Aug, etc.
--     then summing charges means summing the sums (from the partitions). Is the optimizer
--     smart enough... I guess you'll have to get to the end of the script to see ;).

-- Have fun,
-- kt

-- You can get sample databases from here: https://www.sqlskills.com/sql-server-resources/sql-server-demos/
USE [master];
GO

IF DATABASEPROPERTYEX('CreditPV', 'Collation') IS NOT NULL
    DROP DATABASE [CreditPV];
GO

-- If you need to manually delete any files...
--!! del "C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019Dev\MSSQL\Data\CreditPV*"
--!! del "H:\CreditPV*"
--!! del "D:\SQLskills\Demos\CreditPV*"
GO

USE [master];
GO

/* ******* pre-step *******  */

RESTORE DATABASE [CreditPV]
          FROM DISK = 'C:\Temp\creditbackup100\CreditBackup100.BAK'
WITH MOVE N'CreditData' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\mssql\data\CreditPVData.mdf'
        , MOVE N'CreditLog' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\mssql\data\CreditPVLog.ldf'
        , REPLACE;
GO

USE [CreditPV];
GO

------
-- Discussion about restores, CE, Optimizer fixes, testing...
------

--ALTER DATABASE CreditPV SET COMPATIBILITY_LEVEL = 130 -- for 2016
--ALTER DATABASE CreditPV SET COMPATIBILITY_LEVEL = 140 -- for 2017
ALTER DATABASE CreditPV SET COMPATIBILITY_LEVEL = 150 -- for 2019

-- For 2016+
ALTER DATABASE SCOPED CONFIGURATION 
		SET LEGACY_CARDINALITY_ESTIMATION = ON

/* ******* pre-step ******* */

ALTER DATABASE [CreditPV] 
	ADD FILEGROUP [PartitionedViewsFilegroup1];
GO

ALTER DATABASE [CreditPV]
	ADD FILE
		(NAME = N'CreditPVFGFile1', 
		FILENAME = N'C:\database\CreditPVFGFile1.NDF' , 
        --FILENAME = N'H:\CreditPVFGFile1.NDF' , 
		SIZE = 50, FILEGROWTH = 10%) 
		TO FILEGROUP [PartitionedViewsFilegroup1];
GO

ALTER DATABASE [CreditPV] 
	ADD FILEGROUP [PartitionedViewsFilegroup2];
GO

ALTER DATABASE [CreditPV]
	ADD FILE
		(NAME = N'CreditPVFGFile2', 
		FILENAME = N'C:\database\CreditPVFGFile2.NDF' , 
		--FILENAME = N'H:\CreditPVFGFile2.NDF' , 
        SIZE = 50, FILEGROWTH = 10%) 
		TO FILEGROUP [PartitionedViewsFilegroup2];
GO

ALTER DATABASE [CreditPV]
	ADD FILEGROUP [PartitionedViewsFilegroup3];
GO

ALTER DATABASE [CreditPV]
	ADD FILE
		(NAME = N'CreditPVFGFile3', 
		FILENAME = N'C:\database\CreditPVFGFile3.NDF' , 
		SIZE = 50, FILEGROWTH = 10%) 
		TO FILEGROUP [PartitionedViewsFilegroup3];
GO

ALTER DATABASE [CreditPV]
	ADD FILEGROUP [PartitionedViewsFilegroup4];
GO

ALTER DATABASE [CreditPV]
	ADD FILE
		(NAME = N'CreditPVFGFile4', 
		FILENAME = N'C:\database\CreditPVFGFile4.NDF' , 
		SIZE = 50, FILEGROWTH = 10%) 
		TO FILEGROUP [PartitionedViewsFilegroup4];
GO

-- Create a "staging" filegroup...
ALTER DATABASE [CreditPV]
	ADD FILEGROUP [ChargesStaging];
GO

ALTER DATABASE [CreditPV]
	ADD FILE
		(NAME = N'ChargesStaging', 
		FILENAME = N'C:\database\CreditPVChargesStaging.NDF' , 
		SIZE = 100, FILEGROWTH = 10%) 
		TO FILEGROUP [ChargesStaging];
GO

EXEC [sp_helpfile];
GO

-- Load the data into the Staging Area and then rebuild the clustered index on the filegroup to move
-- the object once and to get better contiguousness...

----------------------------------------------------------------------------------------------
--------------------------------------- JUNE --------------------------------------------
----------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[Charges202006]
( 	[charge_no]		numeric_id		NOT NULL	IDENTITY(1,1),
	member_no		numeric_id 	NOT NULL
						CONSTRAINT Charges202006MemberNoFK
							REFERENCES dbo.Member(Member_No),
	provider_no		numeric_id
						CONSTRAINT Charges202006ProviderNoFK
							REFERENCES dbo.Provider(Provider_No),
	category_no	numeric_id
						CONSTRAINT Charges202006CategoryNoFK
							REFERENCES dbo.Category(Category_No),
	charge_dt		datetime 	NOT NULL
						CONSTRAINT Charges202006ChargeDtCK
							CHECK (Charge_dt >= '20200601' 
								AND Charge_dt < '20200701'),
	charge_amt		money		NOT NULL,
	statement_no	numeric_id,
	charge_code	status_code
) ON [ChargesStaging];
go

INSERT [dbo].[Charges202006] (member_no, provider_no, category_no
						, charge_dt, charge_amt
						, statement_no, charge_code)
	SELECT member_no, provider_no, category_no
			, dateadd(yy, 21, charge_dt)
            , (charge_amt + charge_no)/10
			, statement_no, charge_code 
	FROM [CreditPV].[dbo].[Charge]
	WHERE month(charge_dt) = 6
	ORDER BY charge_dt, charge_no
go

EXEC sp_help Charges202006
-- Will be on ChargesStaging
go

ALTER TABLE [dbo].[Charges202006]
ADD CONSTRAINT [Charges202006PK]
		PRIMARY KEY CLUSTERED ([charge_dt], [charge_no])
			ON [PartitionedViewsFilegroup1]
go

EXEC sp_help Charges202006
-- Will be on PartitionedViewsFilegroup1
go

----------------------------------------------------------------------------------------------
--------------------------------------- JULY --------------------------------------------
----------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[Charges202007]
( 	charge_no		numeric_id		NOT NULL	IDENTITY(202321,1),
	member_no		numeric_id 	NOT NULL
						CONSTRAINT Charges202007MemberNoFK
							REFERENCES dbo.Member(Member_No),
	provider_no		numeric_id
						CONSTRAINT Charges202007ProviderNoFK
							REFERENCES dbo.Provider(Provider_No),
	category_no	numeric_id
						CONSTRAINT Charges202007CategoryNoFK
							REFERENCES dbo.Category(Category_No),
	charge_dt		datetime 	NOT NULL
						CONSTRAINT Charges202007ChargeDtCK
							CHECK (Charge_dt >= '20200701' 
								AND Charge_dt < '20200801'),
	charge_amt		money		NOT NULL,
	statement_no	numeric_id,
	charge_code	status_code
) ON [ChargesStaging];
go

INSERT [dbo].[Charges202007] (member_no, provider_no, category_no
						, charge_dt, charge_amt
						, statement_no, charge_code)
	SELECT member_no, provider_no, category_no
			, dateadd(yy, 21, charge_dt), (charge_amt + charge_no)/10
			, statement_no, charge_code 
	FROM [CreditPV].[dbo].[Charge]
	WHERE month(charge_dt) = 7
	ORDER BY charge_dt, charge_no
go

EXEC sp_help Charges202007
-- Will be on ChargesStaging
go

ALTER TABLE [dbo].[Charges202007]
ADD CONSTRAINT Charges202007PK
		PRIMARY KEY CLUSTERED (charge_dt, charge_no) 
			ON [PartitionedViewsFilegroup2]
go

EXEC sp_help Charges202007
-- Will be on PartitionedViewsFilegroup2
go

----------------------------------------------------------------------------------------------
--------------------------------------- August-------------------------------------------
----------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[Charges202008]
( 	charge_no		numeric_id		NOT NULL	IDENTITY(611009,1),
	member_no		numeric_id 	NOT NULL
						CONSTRAINT Charges202008MemberNoFK
							REFERENCES dbo.Member(Member_No),
	provider_no		numeric_id
						CONSTRAINT Charges202008ProviderNoFK
							REFERENCES dbo.Provider(Provider_No),
	category_no	numeric_id
						CONSTRAINT Charges202008CategoryNoFK
							REFERENCES dbo.Category(Category_No),
	charge_dt		datetime 	NOT NULL
						CONSTRAINT Charges202008ChargeDtCK
							CHECK (Charge_dt >= '20200801' 
								AND Charge_dt < '20200901'),
	charge_amt		money		NOT NULL,
	statement_no	numeric_id,
	charge_code	status_code
) ON [ChargesStaging]
go

INSERT [dbo].[Charges202008] (member_no, provider_no, category_no
						, charge_dt, charge_amt
						, statement_no, charge_code)
	SELECT member_no, provider_no, category_no
			, dateadd(yy, 21, charge_dt), (charge_amt + charge_no)/10
			, statement_no, charge_code 
	FROM [CreditPV].[dbo].[Charge]
	WHERE month(charge_dt) = 8
	ORDER BY charge_dt, charge_no
go

EXEC sp_help Charges202008
-- Will be on ChargesStaging
go

ALTER TABLE [dbo].[Charges202008]
ADD CONSTRAINT Charges202008PK
		PRIMARY KEY CLUSTERED (charge_no) 
			ON [PartitionedViewsFilegroup3]
go

--ALTER TABLE [dbo].[Charges202008]
--DROP CONSTRAINT Charges202008PK
--go

--ALTER TABLE [dbo].[Charges202008]
--ADD CONSTRAINT Charges202008PK
--		PRIMARY KEY CLUSTERED (charge_dt, charge_no) 
--			ON [PartitionedViewsFilegroup3]
--go

EXEC sp_help Charges202008
-- Will be on PartitionedViewsFilegroup3
go

----------------------------------------------------------------------------------------------
--------------------------------------- Sept ----------------------------------------------
----------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[Charges202009]
( 	charge_no		numeric_id	NOT NULL	IDENTITY(1023329,1),
	member_no		numeric_id 	NOT NULL
						CONSTRAINT Charges202009MemberNoFK
							REFERENCES dbo.Member(Member_No),
	provider_no		numeric_id
						CONSTRAINT Charges202009ProviderNoFK
							REFERENCES dbo.Provider(Provider_No),
	category_no	numeric_id
						CONSTRAINT Charges202009CategoryNoFK
							REFERENCES dbo.Category(Category_No),
	charge_dt		datetime 	NOT NULL
						CONSTRAINT Charges202009ChargeDtCK
							CHECK (Charge_dt >= '20200901' 
								AND Charge_dt < '20201001'),
	charge_amt		money		NOT NULL,
	statement_no	numeric_id,
	charge_code	status_code
) ON [ChargesStaging]
go

INSERT [dbo].[Charges202009] (member_no, provider_no, category_no
						, charge_dt, charge_amt
						, statement_no, charge_code)
	SELECT member_no, provider_no, category_no
			, dateadd(yy, 21, charge_dt), (charge_amt + charge_no)/10
			, statement_no, charge_code 
	FROM [CreditPV].[dbo].[Charge]
	WHERE month(charge_dt) = 9
	ORDER BY charge_dt, charge_no
go

EXEC sp_help Charges202009
-- Will be on ChargesStaging
go

ALTER TABLE [dbo].[Charges202009]
ADD CONSTRAINT Charges202009PK
		PRIMARY KEY CLUSTERED (charge_no) 
			ON [PartitionedViewsFilegroup4]
go

--ALTER TABLE [dbo].[Charges202009]
--DROP CONSTRAINT Charges202009PK
--go

--ALTER TABLE [dbo].[Charges202009]
--ADD CONSTRAINT Charges202009PK
--		PRIMARY KEY CLUSTERED (charge_dt) 
--			ON [PartitionedViewsFilegroup4]
--go

EXEC sp_help Charges202009
-- Will be on PartitionedViewsFilegroup4
go

----------------------------------------------------------------------------------------------
---------------------------------- Create View --------------------------------------
----------------------------------------------------------------------------------------------

CREATE VIEW [dbo].[ChargePV]
AS
SELECT * 
FROM [dbo].[Charges202006]
UNION ALL
SELECT * 
FROM [dbo].[Charges202007]
UNION ALL
SELECT * 
FROM [dbo].[Charges202008]
UNION ALL
SELECT * 
FROM [dbo].[Charges202009];
GO


----------------------------------------------------------------------------------------------
------------------------------ SET RECOVERY TO FULL and BACKUP! ------------------------------
----------------------------------------------------------------------------------------------

-- You should always backup the database (or the new filegroups/files)
-- after you change the structure. You CAN restore the change with a 
-- log backup but it's always a good practice to protect the structure
-- of the database!
ALTER DATABASE [CreditPV]
	SET RECOVERY FULL;
GO

BACKUP DATABASE [CreditPV]
TO DISK = N'C:\database\CreditPV.bak' 
WITH INIT, STATS = 10;
GO

RESTORE HEADERONLY 
FROM DISK = N'c:\database\CreditPV.bak';
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Elimination: query the view -------------------------
----------------------------------------------------------------------------------------------

SET STATISTICS IO ON;
go

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt] >= '20200714' 
	AND [cpv].[charge_dt] < '20200715'; 
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt] >= '20200903' 
	AND [cpv].[charge_dt] < '20200904';
GO
  
-- This queries all constraints for the DB  
SELECT OBJECT_NAME(object_id),
       CASE WHEN
            OBJECTPROPERTY(
            OBJECT_ID(name), 
	        'CnstIsNotTrusted') = 0 THEN 'Trusted'
            WHEN OBJECTPROPERTY(
            OBJECT_ID(name), 
	        'CnstIsNotTrusted') = 1 THEN 'Untrusted'
            ELSE 'Invalid Constraint'
            END AS [TrustedConstraint]
FROM [sys].[check_constraints]
GO

-- And, because of the PKs, 
--    we can't update through the view:
-- (1) they're not even consistent
-- (2) they don't all have the partitioning key as the leading column

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_no] = 348872 
    AND [cpv].[charge_dt] = '20200712 10:45:23.027';
GO

UPDATE [dbo].[ChargePV]
SET [charge_amt] = 1234
WHERE [charge_no] = 348872  
    AND [charge_dt] = '20200712 10:45:23.027';
GO

--Msg 4445, Level 16, State 11, Line 1
--UNION ALL view 'CreditPV.dbo.ChargePV' is not updatable 
-- because the primary key of table '[CreditPV].[dbo].[Charges202008]' 
-- is not unioned with primary keys of preceding tables.

-- Or, FYI, if the keys don't have the PK then you'll get this:
--Msg 4436, Level 16, State 13, Line 1
--UNION ALL view 'CreditPV.dbo.ChargePV' is not updatable because a 
--partitioning column was not found.


-- Drop/recreate the constraints
ALTER TABLE [dbo].[Charges202008]
DROP CONSTRAINT [Charges202008PK];
go

ALTER TABLE [dbo].[Charges202008]
ADD CONSTRAINT [Charges202008PK]
		PRIMARY KEY CLUSTERED ([charge_dt], [charge_no]) 
			ON [PartitionedViewsFilegroup3];
GO

sp_help '[dbo].[Charges202008]'
go

ALTER TABLE [dbo].[Charges202009]
DROP CONSTRAINT [Charges202009PK];
GO

ALTER TABLE [dbo].[Charges202009]
ADD CONSTRAINT [Charges202009PK]
	PRIMARY KEY CLUSTERED ([charge_dt], [charge_no]) 
		ON [PartitionedViewsFilegroup4];
GO


-- What if?
--ALTER TABLE [dbo].[Charges202009]
--ADD CONSTRAINT [Charges202009PK]
--		PRIMARY KEY CLUSTERED ([charge_dt], [member_no], [provider_no], [charge_amt]) 
--			ON [PartitionedViewsFilegroup4];
GO

sp_help '[dbo].[Charges202009]'
go

BEGIN TRAN
UPDATE [dbo].[ChargePV]
    SET [charge_amt] = 1234
    WHERE [charge_dt] BETWEEN '20200831' AND '20200902';
SELECT [c].[charge_dt], [c].[charge_no], [c].[charge_amt] 
    FROM [dbo].[ChargePV] AS [c]
    WHERE [charge_dt] BETWEEN '20200730' AND '20200802'
    ORDER BY [c].[charge_dt];
ROLLBACK;     
GO

SELECT count(*) from [dbo].[Charges202007]
SELECT count(*) from [dbo].[Charges202008]
go

-- Question: Can you update across the views
UPDATE [dbo].[ChargePV]
SET [charge_dt] = '20200812 6:06:06.000'
WHERE [charge_no] = 348872  
    AND [charge_dt] = '20200712 10:45:23.027';
GO

SET IDENTITY_INSERT [dbo].[Charges202008] ON;
go

UPDATE [dbo].[ChargePV]
SET [charge_dt] = '20200812 6:06:06.000'
WHERE [charge_no] = 348872  
    AND [charge_dt] = '20200712 10:45:23.027';
GO

SET IDENTITY_INSERT [dbo].[Charges202006] ON;
SET IDENTITY_INSERT [dbo].[Charges202007] ON;
SET IDENTITY_INSERT [dbo].[Charges202009] ON;
go

-- YES - you can move rows acroess tables... but you need to test
-- to see if there's a secondary problem -> Identity
-- You CANNOT insert into a PV if any base tables have identity.

-- Application Directed Inserts!!

-- What about a second filtering capability and lookups by ID?
CREATE UNIQUE INDEX [Charges202006ID] 
ON [dbo].[Charges202006] ([charge_no]);
GO

CREATE UNIQUE INDEX [Charges202007ID] 
ON [dbo].[Charges202007] ([charge_no]);
GO

CREATE UNIQUE INDEX [Charges202008ID] 
ON [dbo].[Charges202008] ([charge_no]);
GO

CREATE UNIQUE INDEX [Charges202009ID] 
ON [dbo].[Charges202009] ([charge_no]);
GO

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_no] = 651234;
GO

SELECT min(charge_no), max(charge_no) FROM [dbo].[Charges202006];
SELECT min(charge_no), max(charge_no) FROM [dbo].[Charges202007];
SELECT min(charge_no), max(charge_no) FROM [dbo].[Charges202008];
SELECT min(charge_no), max(charge_no) FROM [dbo].[Charges202009];
GO

-- Since you might have date-related data that also correlates
-- with numeric ranges, you can constrain those as well:
ALTER TABLE [dbo].[Charges202006]
ADD CONSTRAINT [Charges202006IDMin]
		CHECK ([charge_no] >= 1);
GO

ALTER TABLE [dbo].[Charges202006]
ADD CONSTRAINT [Charges202006IDMax]
		CHECK ([charge_no] < 202321);
GO

ALTER TABLE [dbo].[Charges202007]
ADD CONSTRAINT [Charges202007IDMin]
		CHECK ([charge_no] >= 202321);
GO

ALTER TABLE [dbo].[Charges202007]
ADD CONSTRAINT [Charges202007IDMax]
		CHECK ([charge_no] < 611009);
GO

ALTER TABLE [dbo].[Charges202008]
ADD CONSTRAINT [Charges202008IDMin]
		CHECK ([charge_no] >= 611009);
GO

ALTER TABLE [dbo].[Charges202008]
ADD CONSTRAINT [Charges202008IDMax]
		CHECK ([charge_no] < 1023329);
GO

ALTER TABLE [dbo].[Charges202009]
ADD CONSTRAINT [Charges202009IDMin]
		CHECK ([charge_no] >= 1023329);
GO

SET STATISTICS IO ON;
go

SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_no] = 651234;
GO

-- Note: you won't get elimination on modifications but with
-- highly selective values and good indexing, this will be an
-- inexpensive update regardless. Definitely important to keep
-- in mind though!

BEGIN TRAN
UPDATE [dbo].[ChargePV]
    SET [charge_amt] = 1234
    WHERE [charge_no] = 651234;
ROLLBACK;     
GO

-----------------------------------------------------------------------
-- Indexed Views
-----------------------------------------------------------------------

-- From here, we could go on to some advanced scenarios as well
-- such as indexed views on the base tables of a partitioned view.
-- You CANNOT create an indexed view on a PV but if you create IVs
-- on the base tables, then SQL Server CAN use them. But, the
-- big problem when you're NOT on EE is that you can only use
-- them when referencing the IV directly. 

-- So, the point - you might still want to use PVs (even on EE) and 
-- when you do, then you can still get FANTASTIC benefits with
-- IVs!

-- The next section is an added benefit of Partitioning in that you can create indexed views
-- on the base tables and then have SQL Server aggregate the aggregates in a single query.

CREATE VIEW [dbo].[SumOfAllChargesByMember202006]
	WITH SCHEMABINDING  -- required if you plan to index this view!
AS
SELECT [c].[member_no] AS [MemberNo], 
	COUNT_BIG(*) AS [NumberOfCharges], -- required when GROUP BY is in an indexed view!
	SUM(c.charge_amt) AS [TotalSales]
FROM [dbo].[Charges202006] AS [c]
GROUP BY [c].[member_no];
GO

CREATE UNIQUE CLUSTERED INDEX [SumofAllChargesIndex]
	ON [dbo].[SumOfAllChargesByMember202006] ([MemberNo]); 
GO

CREATE VIEW [dbo].[SumOfAllChargesByMember202007]
	WITH SCHEMABINDING  -- required if you plan to index this view!
AS
SELECT [c].[member_no] AS [MemberNo], 
	COUNT_BIG(*) AS [NumberOfCharges], -- required when GROUP BY is in an indexed view!
	SUM(c.charge_amt) AS [TotalSales]
FROM [dbo].[Charges202007] AS [c]
GROUP BY [c].[member_no];
GO

CREATE UNIQUE CLUSTERED INDEX [SumofAllChargesIndex]
	ON [dbo].[SumOfAllChargesByMember202007] ([MemberNo]); 
GO

CREATE VIEW [dbo].[SumOfAllChargesByMember202008]
	WITH SCHEMABINDING  -- required if you plan to index this view!
AS
SELECT [c].[member_no] AS [MemberNo], 
	COUNT_BIG(*) AS [NumberOfCharges], -- required when GROUP BY is in an indexed view!
	SUM(c.charge_amt) AS [TotalSales]
FROM [dbo].[Charges202008] AS [c]
GROUP BY [c].[member_no];
GO

CREATE UNIQUE CLUSTERED INDEX [SumofAllChargesIndex]
	ON [dbo].[SumOfAllChargesByMember202008] ([MemberNo]);
GO

CREATE VIEW [dbo].[SumOfAllChargesByMember202009]
	WITH SCHEMABINDING  -- required if you plan to index this view!
AS
SELECT [c].[member_no] AS [MemberNo], 
	COUNT_BIG(*) AS [NumberOfCharges], -- required when GROUP BY is in an indexed view!
	SUM(c.charge_amt) AS [TotalSales]
FROM [dbo].[Charges202009] AS [c]
GROUP BY [c].[member_no];
GO

CREATE UNIQUE CLUSTERED INDEX [SumofAllChargesIndex]
	ON [dbo].[SumOfAllChargesByMember202009] ([MemberNo]);
GO

-- Aggregating the aggregates!
SELECT [c].[member_no] AS [MemberNo], 
	COUNT_BIG(*) AS [NumberOfCharges], -- required when GROUP BY is in an indexed view!
	SUM([c].[charge_amt]) AS [TotalSales]
FROM [dbo].[ChargePV] AS [c]
GROUP BY [c].[member_no]
ORDER BY [c].[member_no];
GO

SELECT [c].[member_no] AS [MemberNo], 
	AVG([c].[charge_amt]) AS [AvgSales]
FROM [dbo].[ChargePV] AS [c]
GROUP BY [c].[member_no]
ORDER BY [c].[member_no];
GO

-- This would work on non-EE editions
CREATE VIEW [dbo].[SumOfAllChargesPV]
AS
SELECT * 
FROM [dbo].[SumOfAllChargesByMember202006] WITH (NOEXPAND)
UNION ALL
SELECT * 
FROM [dbo].[SumOfAllChargesByMember202007] WITH (NOEXPAND)
UNION ALL
SELECT * 
FROM [dbo].[SumOfAllChargesByMember202008] WITH (NOEXPAND)
UNION ALL
SELECT * 
FROM [dbo].[SumOfAllChargesByMember202009] WITH (NOEXPAND);
GO

-- On EE then this query would work:
SELECT [c].[member_no] AS [MemberNo], 
	AVG([c].[charge_amt]) AS [AvgSales]
FROM [dbo].[ChargePV] AS [c]
GROUP BY [c].[member_no]
ORDER BY [c].[member_no];
GO

-- On SE you'd need another ChargePV with NOEXPAND 
-- hints (like the one above) to get averages of sales.

-- On All other editions you MUST use the PV where
-- the IVs are UNIONed (UNION ALL) and where they
-- use the NOEXPAND hint
-- So this is the AVG of the totals...
SELECT [c].[memberNo] AS [MemberNo], 
	AVG([c].[TotalSales]) AS [AvgSales]
FROM [dbo].[SumOfAllChargesPV] AS [c]
GROUP BY [c].[memberNo]
ORDER BY [c].[memberNo];
GO


-- From a question...
-- What's the plan when a row can't exist
-- The date exists and the charge_no exists but in DIFFERENT
-- partitions:
SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_no] = 651234
	AND charge_dt = '2019-07-03 10:50:59.980';
GO

-- Another discussion about the use of IVs
-- What if we want an aggregate over a partition
-- AND we have an IV. Unfortunately, SQL won't
-- realize that your predicate matches the table
-- perfectly so they won't use the IV :-( 
SELECT [c].[member_no] AS [MemberNo], 
	COUNT_BIG(*) AS [NumberOfCharges], -- required when GROUP BY is in an indexed view!
	SUM([c].[charge_amt]) AS [TotalSales]
FROM [dbo].[ChargePV] AS [c]
WHERE [c].[member_no] = 4460
	--AND Charge_dt >= '20200901' AND Charge_dt < '20191001'
GROUP BY [c].[member_no];
GO

-- Looking at structures
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('Charges202006'), NULL, NULL, 'detailed');
go

SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('Charges202007'), NULL, NULL, 'detailed');
go

SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('Charges202008'), NULL, NULL, 'detailed');
go

SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('Charges202009'), NULL, NULL, 'detailed');
