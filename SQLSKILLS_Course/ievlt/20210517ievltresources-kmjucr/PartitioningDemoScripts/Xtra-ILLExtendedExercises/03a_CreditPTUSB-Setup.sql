/*============================================================================
  File:     CreditPTUSB-Setup.sql

  Summary:  This script takes roughly 5-15 mins to run, 
			depending on hardware. This script requires that you have
			additional drives (drives e:\, f:\. g:\, and h:\). This is
			best demonstrated by using an external USB HUB and simple
			USB keys for Partitioning. This is the setup script for the
			CreditPTUSB-QueryDamageAccessRepair.sql script.

  SQL Server Version: 2008+ (script updated for SQL 2014)
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

USE master
GO

IF DATABASEPROPERTYEX('CreditPTUSB', 'Collation') IS NOT NULL
  DROP DATABASE [CreditPTUSB]
GO

-- We need to do the specific deletes because a suspect database does not
-- delete the individual files (when it cannot connect to them).
SET NOCOUNT ON
GO

-- These will mostly likely generate "could not find...", except possibly drive H:\
!! del "C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\Data\CreditPTUSBPrimary.mdf"
!! del "C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\Data\CreditPTUSBTLog.ldf"
!! del "E:\CreditPTUSB*.ndf"
!! del "F:\CreditPTUSB*.ndf"
!! del "G:\CreditPTUSB*.ndf"
!! del "H:\CreditPTUSB*.ndf"
!! del "C:\SQLskills\CreditPTUSB*.ndf"
GO

SET NOCOUNT OFF
GO

----------------------------------------------------------------------------------------------
-------------------------------- Database Setup ------------------------------------
----------------------------------------------------------------------------------------------

USE master
GO

/* ******* pre-step *******  */
RESTORE DATABASE CreditPTUSB
          FROM DISK = 'C:\SQLskills\CreditBackup100.BAK'
WITH MOVE N'CreditData' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\Data\CreditPTUSBData.mdf'
        , MOVE N'CreditLog' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\Data\CreditPTUSBLog.ldf'
        , STATS = 10, REPLACE
go
/* ******* pre-step ******* */

USE CreditPTUSB
go

ALTER DATABASE [CreditPTUSB] 
	ADD FILEGROUP PartitionedTablesFG1
GO

ALTER DATABASE [CreditPTUSB] 
	ADD FILE
		(NAME = N'CreditPTUSBFG1File1', 
--		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\mssql\data\CreditPTUSBFG1File1.ndf', 
		FILENAME = N'E:\CreditPTUSBFG1File1.ndf', 
		SIZE = 100, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG1]
GO

ALTER DATABASE CreditPTUSB 
	ADD FILEGROUP PartitionedTablesFG2
GO

ALTER DATABASE CreditPTUSB 
	ADD FILE
		(NAME = N'CreditPTUSBFG2File1', 
--		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\mssql\data\CreditPTUSBFG2File1.ndf', 
		FILENAME = N'F:\CreditPTUSBFG2File1.ndf', 
		SIZE = 100, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG2]
GO

ALTER DATABASE CreditPTUSB 
	ADD FILEGROUP PartitionedTablesFG3
GO

ALTER DATABASE CreditPTUSB 
	ADD FILE
		(NAME = N'CreditPTUSBFG3File1', 
--		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\mssql\data\CreditPTUSBFG3File1.ndf', 
		FILENAME = N'G:\CreditPTUSBFG3File1.ndf', 
		SIZE = 100, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG3]
GO

ALTER DATABASE CreditPTUSB 
	ADD FILEGROUP PartitionedTablesFG4
GO

ALTER DATABASE CreditPTUSB 
	ADD FILE
		(NAME = N'CreditPTUSBFG4File1', 
--		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\mssql\data\CreditPTUSBFG4File1.ndf', 
		FILENAME = N'H:\CreditPTUSBFG4File1.ndf', 
		SIZE = 100, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [PartitionedTablesFG4]
GO

-- Move a "staging" copy into it's own filegroup...
ALTER DATABASE CreditPTUSB 
	ADD FILEGROUP ChargesStaging
GO

ALTER DATABASE CreditPTUSB 
	ADD FILE
		(NAME = N'CreditPTUSBChargesStaging', 
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\mssql\data\CreditPTUSBChargesStaging.NDF' , 
		SIZE = 100, FILEGROWTH = 10, MAXSIZE = 500) 
		TO FILEGROUP [ChargesStaging]
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Function --------------------------------------------
----------------------------------------------------------------------------------------------
CREATE PARTITION FUNCTION Credit4MonthPFN(datetime)
AS 
RANGE RIGHT FOR VALUES ('20040601',		-- Jun 2004
						'20040701',		-- Jul 2004
						'20040801',		-- Aug 2004
						'20040901')		-- Sep 2004	
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Scheme ----------------------------------------------
----------------------------------------------------------------------------------------------
CREATE PARTITION SCHEME [Credit4MonthPS]
AS 
PARTITION [Credit4MonthPFN] TO 
		( [PRIMARY], [PartitionedTablesFG1], [PartitionedTablesFG2], 
		  [PartitionedTablesFG3], [PartitionedTablesFG4])
GO

----------------------------------------------------------------------------------------------
------------------------------ Partition Table -----------------------------------------------
----------------------------------------------------------------------------------------------
CREATE TABLE ChargesPT
( 	charge_no		int			NOT NULL	IDENTITY,
	member_no		int			NOT NULL
						CONSTRAINT ChargesPTMemberNoFK
							REFERENCES dbo.Member(Member_No),
	provider_no		int			NOT NULL
						CONSTRAINT ChargesPTProviderNoFK
							REFERENCES dbo.Provider(Provider_No),
	category_no		int			NOT NULL
						CONSTRAINT ChargesPTCategoryNoFK
							REFERENCES dbo.Category(Category_No),
	charge_dt		datetime 	NOT NULL
						CONSTRAINT ChargesPTChargeDtCK
							CHECK (Charge_dt >= '20040601' 
									AND Charge_dt < '20041101'),
	charge_amt		money		NOT NULL,
	statement_no	int			NOT NULL,
	charge_code		char(2)		NOT NULL
) ON ChargesStaging 
GO

EXEC sp_help ChargesPT
GO

----------------------------------------------------------------------------------------------
--------------------------------- DATA LOAD --------------------------------------------------
----------------------------------------------------------------------------------------------
INSERT ChargesPT (member_no, provider_no, category_no
						, charge_dt, charge_amt
						, statement_no, charge_code)
	SELECT member_no, provider_no, category_no
			, dateadd(yy, 5, charge_dt), (charge_amt + charge_no)/10
			, statement_no, charge_code 
	FROM CreditPTUSB.dbo.Charge
	WHERE month(charge_dt) IN (6, 7, 8, 9)
	ORDER BY charge_dt, charge_no
GO

----------------------------------------------------------------------------------------------
--------------------------------- Partition --------------------------------------------------
----------------------------------------------------------------------------------------------

-- By creating the clustered index ON the parition scheme you move
-- all of the data to only the appropriate location defined by the
-- partition scheme (and the partition function it uses). 

ALTER TABLE ChargesPT
ADD CONSTRAINT ChargesPTPK
		PRIMARY KEY CLUSTERED (charge_dt, charge_no) 
			ON Credit4MonthPS (charge_dt)
GO

----------------------------------------------------------------------------------------------
------------------------------ VERIFY DATA DISTRIBUTION --------------------------------------
----------------------------------------------------------------------------------------------
SELECT $partition.Credit4MonthPFN(CPT.Charge_dt) 
			AS [Partition Number]
	, min(CPT.Charge_dt) AS [Min Order Date]
	, max(CPT.Charge_dt) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM dbo.ChargesPT AS CPT
GROUP BY $partition.Credit4MonthPFN(CPT.Charge_dt) 
ORDER BY [Partition Number]
GO

----------------------------------------------------------------------------------------------
------------------------------ Query a partition ---------------------------------------------
----------------------------------------------------------------------------------------------
SET STATISTICS IO ON
go

SELECT * FROM ChargesPT
WHERE Charge_dt >= '20040914' 
AND Charge_dt < '20040915' 

----------------------------------------------------------------------------------------------
------------------------------ SET RECOVERY TO FULL and BACKUP! ------------------------------
----------------------------------------------------------------------------------------------
ALTER DATABASE [CreditPTUSB]
	SET RECOVERY FULL
GO

BACKUP DATABASE [CreditPTUSB]
TO DISK = N'C:\SQLskills\CreditPTUSB.bak' 
WITH INIT, STATS = 10
GO

RESTORE HEADERONLY FROM DISK = N'C:\SQLskills\CreditPTUSB.bak' 
GO

--RESTORE DATABASE [CreditPTUSB]
--FROM DISK = N'C:\SQLskills\CreditPTUSB.bak' 
--WITH REPLACE, STATS = 10
--GO