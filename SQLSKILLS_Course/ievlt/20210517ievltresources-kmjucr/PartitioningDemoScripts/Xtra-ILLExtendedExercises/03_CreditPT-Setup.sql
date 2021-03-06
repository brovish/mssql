/*============================================================================
  File:     CreditPT-Setup.sql

  Summary:  This script sets up the same database used in the Partitioned View
			scenario shown in CreditPV-Setup.sql and the CreditPTUSB-Setup.sql
			scenario. However, in this script the entire configuration is on 
			Drive C:. This is so that you can see all of
			the Partitioning Aspects without having 4 external drives.

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

-- Before this script will work you will need to:
-- (1) Create a D:\SQLskills subdirectory.
--		Copy the CreditBackup100.bak file (from the zip) to this directory.
--		You can find the zip on the Past Events page from SQLskills.com.
-- (2) Create the multiple filegroup and partitioned table scenario
--		using the script: "CreditPTOnDriveC.sql" 
-- Once CreditPT is created, you can use this script to create a snapshot!
-- NOTE: This script has many comments which are not commented out...
-- In other words, don't try to just "execute" this script, you should
-- work your way through it slowly!

-- You can get sample databases from here: https://www.sqlskills.com/sql-server-resources/sql-server-demos/
USE [master];
GO

IF DATABASEPROPERTYEX('CreditPT', 'Collation') IS NOT NULL
  DROP DATABASE [CreditPT];
GO


----------------------------------------------------------------------------------------------
-------------------------------- Database Setup ------------------------------------
----------------------------------------------------------------------------------------------

USE [master];
GO

/* ******* pre-step *******  */

-- Sample databases are on SQLskills: https://www.sqlskills.com/sql-server-resources/sql-server-demos/
RESTORE DATABASE [CreditPT]
	FROM DISK = 'C:\Temp\creditbackup100\CreditBackup100.BAK'
WITH MOVE N'CreditData' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\mssql\data\CreditPTData.mdf'
        , MOVE N'CreditLog' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\mssql\data\CreditPTLog.ldf'
        , REPLACE;
GO

/* ******* pre-step ******* */

USE [CreditPT];
GO

------
-- Same issue around restores, CE, Optimizer fixes, testing...
------

--ALTER DATABASE CreditPV SET COMPATIBILITY_LEVEL = 130 -- for 2016
--ALTER DATABASE CreditPT SET COMPATIBILITY_LEVEL = 140 -- for 2017
ALTER DATABASE [CreditPT] SET COMPATIBILITY_LEVEL = 150; -- for 2019
go

-- For 2016+
ALTER DATABASE SCOPED CONFIGURATION 
		SET LEGACY_CARDINALITY_ESTIMATION = ON;
go

/* ******* Setup same filegroups ******* */

ALTER DATABASE [CreditPT] 
	ADD FILEGROUP [PartitionedTablesFG1];
GO

ALTER DATABASE [CreditPT] 
	ADD FILE
		(NAME = N'CreditPTFG1File1', 
		FILENAME = N'C:\database\CreditPTFG1File1.ndf', 
		--FILENAME = N'F:\CreditPTFG1File1.ndf', 
		SIZE = 50, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG1];
GO

ALTER DATABASE [CreditPT] 
	ADD FILEGROUP [PartitionedTablesFG2];
GO

ALTER DATABASE [CreditPT] 
	ADD FILE
		(NAME = N'CreditPTFG2File1', 
		FILENAME = N'C:\database\CreditPTFG2File1.ndf', 
        --FILENAME = N'G:\CreditPTFG2File1.ndf', 
		SIZE = 50, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG2];
GO

ALTER DATABASE [CreditPT] 
	ADD FILEGROUP [PartitionedTablesFG3];
GO

ALTER DATABASE [CreditPT] 
	ADD FILE
		(NAME = N'CreditPTFG3File1', 
		FILENAME = N'C:\database\CreditPTFG3File1.ndf', 
        --FILENAME = N'H:\CreditPTFG3File1.ndf', 
		SIZE = 50, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG3];
GO

ALTER DATABASE [CreditPT] 
	ADD FILEGROUP [PartitionedTablesFG4];
GO

ALTER DATABASE [CreditPT] 
	ADD FILE
		(NAME = N'CreditPTFG4File1', 
		FILENAME = N'C:\database\CreditPTFG4File1.ndf', 
        --FILENAME = N'I:\CreditPTFG4File1.ndf', 
		SIZE = 50, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG4];
GO

-- Move a "staging" copy into it's own filegroup...
ALTER DATABASE [CreditPT] 
	ADD FILEGROUP [ChargesStaging];
GO

ALTER DATABASE [CreditPT] 
	ADD FILE
		(NAME = N'CreditPTChargesStaging', 
		FILENAME = N'C:\database\CreditPTChargesStaging.NDF' , 
		SIZE = 100, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [ChargesStaging];
GO

-- Use a "tiny" FG for the "empty" partition
ALTER DATABASE [CreditPT] 
	ADD FILEGROUP [Tiny];
GO

ALTER DATABASE [CreditPT] 
	ADD FILE
		(NAME = N'CreditPTTiny', 
		FILENAME = N'C:\database\CreditPTTiny.ndf', 
		SIZE = 2, FILEGROWTH = 0, MAXSIZE = 2) 
		TO FILEGROUP [Tiny];
GO

EXEC [sp_helpfile];
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Function --------------------------------------------
----------------------------------------------------------------------------------------------
CREATE PARTITION FUNCTION [Credit4MonthPFN](datetime)
AS 
RANGE RIGHT FOR VALUES ('20200601',		-- Jun 2020
						'20200701',		-- Jul 2020
						'20200801',		-- Aug 2020
						'20200901')		-- Sep 2020	
GO
----------------------------------------------------------------------------------------------
------------------------------ Partition Scheme ----------------------------------------------
----------------------------------------------------------------------------------------------
-- Can... n+2 (don't recommend) --> sets next used. I set next used when I actually use it...
-- Rec n+1
CREATE PARTITION SCHEME [Credit4MonthPS]
AS 
PARTITION [Credit4MonthPFN] TO 
		( [Tiny], [PartitionedTablesFG1], [PartitionedTablesFG2], 
		  [PartitionedTablesFG3], [PartitionedTablesFG4])
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Table -----------------------------------------------
----------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[ChargesPT]
( 	[charge_no]		int			NOT NULL	IDENTITY,
	[member_no]		int			NOT NULL
						CONSTRAINT [ChargesPTMemberNoFK]
							REFERENCES [dbo].[Member]([Member_No]),
	[provider_no]	int			NOT NULL
						CONSTRAINT [ChargesPTProviderNoFK]
							REFERENCES [dbo].[Provider]([Provider_No]),
	[category_no]	int			NOT NULL
						CONSTRAINT [ChargesPTCategoryNoFK]
							REFERENCES [dbo].[Category]([Category_No]),
	[charge_dt]		datetime 	NOT NULL
						CONSTRAINT [ChargesPTChargeDtCK]
                        -- check not required for partitioning (data integrity only)
							CHECK ([Charge_dt] >= '20200601' 
									AND [Charge_dt] < '20201101'),
	[charge_amt]	money		NOT NULL,
	[statement_no]	int			NOT NULL,
	[charge_code]		char(2)		NOT NULL
) ON [ChargesStaging];
GO

EXEC sp_help [ChargesPT];
GO

----------------------------------------------------------------------------------------------
--------------------------------- DATA LOAD --------------------------------------------------
----------------------------------------------------------------------------------------------
INSERT [dbo].[ChargesPT] ([member_no], [provider_no], [category_no]
						, [charge_dt], [charge_amt]
						, [statement_no], [charge_code])
	SELECT [member_no], [provider_no], [category_no]
			, dateadd(yy, 21, [charge_dt]), ([charge_amt] + [charge_no])/10
			, [statement_no], [charge_code]
	FROM [CreditPT].[dbo].[Charge]
	WHERE month([charge_dt]) IN (6, 7, 8, 9)
	ORDER BY [charge_dt], [charge_no];
GO

----------------------------------------------------------------------------------------------
--------------------------------- Partition --------------------------------------------------
----------------------------------------------------------------------------------------------

-- By creating the clustered index ON the parition scheme you move
-- all of the data to only the appropriate location defined by the
-- partition scheme (and the partition function it uses). 

ALTER TABLE [dbo].[ChargesPT]
ADD CONSTRAINT [ChargesPTPK]
		PRIMARY KEY CLUSTERED ([charge_dt], [charge_no]) 
			ON [Credit4MonthPS] ([charge_dt])
GO

EXEC sp_help [ChargesPT];
GO

----------------------------------------------------------------------------------------------
------------------------------ VERIFY DATA DISTRIBUTION --------------------------------------
----------------------------------------------------------------------------------------------
SELECT $partition.Credit4MonthPFN('20200805') 
SELECT $partition.Credit4MonthPFN('17530922') 
SELECT $partition.Credit4MonthPFN('99991230') 
go

SELECT $partition.Credit4MonthPFN([CPT].[Charge_dt]) 
			AS [Partition Number]
	, min([CPT].[Charge_dt]) AS [Min Order Date]
	, max([CPT].[Charge_dt]) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM [dbo].[ChargesPT] AS [CPT]
GROUP BY $partition.Credit4MonthPFN([CPT].[Charge_dt]) 
ORDER BY [Partition Number];
GO

-- Let's see all partitions of all indexes
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('ChargesPT'), NULL, NULL, 'detailed');
go

-- All partitions for just a specific index (Clustered = 1)
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('ChargesPT'), 1, NULL, 'detailed');
go

-- Just a specific partition (3) OF a specific index (Clustered = 1)
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('ChargesPT'), 1, 3, 'detailed');
go

----------------------------------------------------------------------------------------------
------------------------------ Query a partition ---------------------------------------------
----------------------------------------------------------------------------------------------
SET STATISTICS IO ON
go

-- DO NOT USE LIKE with dates - it's NOT a string!
SELECT [c].* 
FROM [dbo].[ChargesPT] AS [c]
WHERE [c].[Charge_dt] LIKE '20200830%';
go

-- Bounded queries! Partitions: 4..5
SELECT [c].* 
FROM [dbo].[ChargesPT] AS [c]
WHERE [c].[Charge_dt] >= '20200830' 
	AND [c].[Charge_dt] < '20200902';
go

-- Bounded queries! Partitions: 2,4
SELECT [c].* 
FROM [dbo].[ChargesPT] AS [c]
WHERE [c].[Charge_dt] >= '20200830' 
		AND [c].[Charge_dt] < '20200831' 
	OR [c].[Charge_dt] >= '20200605' 
		AND [c].[Charge_dt] < '20200606';
go

----------------------------------------------------------------------------------------------
------------------------------ SET RECOVERY TO FULL and BACKUP! ------------------------------
----------------------------------------------------------------------------------------------
ALTER DATABASE [CreditPT]
	SET RECOVERY FULL
GO

BACKUP DATABASE [CreditPT]
TO DISK = N'D:\SQLskills\Demos\CreditPT.bak' 
WITH INIT, STATS = 10
GO

RESTORE HEADERONLY FROM DISK = N'D:\SQLskills\Demos\CreditPT.bak' 
GO

--RESTORE DATABASE [CreditPT]
--FROM DISK = N'C:\SQLskills\CreditPT.bak' 
--WITH REPLACE, STATS = 10
--GO