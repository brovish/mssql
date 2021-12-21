/*============================================================================
  File:     RestoreCredit.sql

  Summary:  Restore the Credit Database to give us a clean start between demos.
			THIS IS A SQLCMD SCRIPT! Be sure to turn that on before running.
  
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

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 backup and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to any version of 2008 and higher

-- IMPORTANT NOTES: 
-- 1) This is a compressed SQL Server 2008 backup and will restore to ALL versions
--    of SQL Server - SQL Server 2008 and higher.
-- 2) All examples expect a database name of Credit. However, if you
--    already have a database with this name, you can change it. In all other
--    scripts, you'll need to be sure to continue to change this based on your
--    new database name. (LINE 50)
-- 3) Be sure to set your complete path\file based on where the 
--    IndexInternals2008.BAK is located. (LINE 51)
-- 4) Be sure to set the server/instance name for restore. (LINES 53-56)
-- 5) Be sure to set your instance directory structure based on your
--    version/installation. (LINES 58-61) NOTE: You only need ONE setting
--    for RestoreToDirectory. The others are just samples.
-- 6) Be sure to set your COMPATIBILITY LEVEL to the correct setting...
--    this is a bit of a can of worms. Read lines 96 to the end!

-- In general, this script should take less than 30 seconds to execute.

:ON ERROR EXIT
go

:SETVAR DB Credit
:SETVAR CreditBackup "D:\SQLskills\CreditBackup100.BAK"

-- Server/Instance for restore
--:SETVAR RestoreToServer (local)\SQL2016dev
--:SETVAR RestoreToServer (local)\SQL2017dev
:SETVAR RestoreToServer (local)\SQL2019dev

-- Instance directory path OR another suitable path...
--:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016Dev\MSSQL\data"
--:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017Dev\MSSQL\data"
:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019Dev\MSSQL\data"
go

:CONNECT $(RestoreToServer)
go

SET NOCOUNT ON;
go

USE master;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE [$(DB)]
		SET RESTRICTED_USER 
		WITH ROLLBACK AFTER 5;
go

IF substring(convert(varchar, SERVERPROPERTY('ProductVersion')), 1, 2) >= '10' 
	RESTORE DATABASE [$(DB)] 
	FROM  DISK = N'$(CreditBackup)' 
	WITH  FILE = 1,  
		MOVE N'CreditData' 
			TO N'$(RestoreToDirectory)\CreditData.mdf',  
		MOVE N'CreditLog' 
			TO N'$(RestoreToDirectory)\CreditLog.ldf',
	STATS = 10, REPLACE;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE [$(DB)]
		SET MULTI_USER 
		WITH ROLLBACK IMMEDIATE;
go

--IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
--	ALTER DATABASE [$(DB)]
--		SET COMPATIBILITY_LEVEL = 110; -- Legacy CE by default
--go

--Here are the valid values for Compatibility Level
--80	SQL Server 2000
--90	SQL Server 2005
--100	SQL Server 2008 and SQL Server 2008 R2
--110	SQL Server 2012
--120	SQL Server 2014
--130   SQL Server 2016 (introduced scoped configurations)
--140   SQL Server 2017
--150   SQL Server 2019

-- NOTE: As a general recommendation, you might choose
-- the Legacy CE by default (compat mode 110) but then
-- as you're troubleshooting, try the New CE with
-- OPTION (QUERYTRACEON 2312);

-- If you're in compat mode 120 (or higher) then you can access the
-- Legacy CE with:
-- OPTION (QUERYTRACEON 9481);

-- Or, if you're on 2016 and higher, use the CURRENT compat mode:
-- (so you get optimizer enhancements but still use the legacy CE
-- NOTE: You only get QE fixes up to RTM unless you ALSO turn on
-- QUERY_OPTIMIZER_HOTFIXES [IMO - TEST FIRST])

-- So, this code will set the compat mode to the current version
-- for anything UNDER 2014. In 2014, we will set the compat mode
-- to 110 to use the legacy CE. In 2016 and higher, we'll set 
-- the compat mode to the CURRENT version (for optimizer fixes)
-- and then use the scoped configuration to set the database's 
-- CE to the legacy CE.

DECLARE @ServerVersion		char(3) = '100'
		, @LegacyCEScoped	bit = 0;

SELECT  @ServerVersion = 
	CONVERT(char(2), SERVERPROPERTY('ProductMajorVersion')) + '0';

IF CONVERT(TINYINT, SERVERPROPERTY('ProductMajorVersion')) > 12
	SET @LegacyCEScoped = 1;

-- Testing
-- SELECT @ServerVersion, @LegacyCEScoped

DECLARE @ExecStr varchar(512) = ('ALTER DATABASE ' + QUOTENAME('$(DB)', N']') + ' SET COMPATIBILITY_LEVEL = ' + @ServerVersion);
EXEC (@ExecStr);

USE [$(DB)];

IF @LegacyCEScoped = 1
	ALTER DATABASE SCOPED CONFIGURATION 
		SET LEGACY_CARDINALITY_ESTIMATION = ON;
go

EXEC sp_dbcmptlevel [$(DB)];
go