/*============================================================================
  File:     RestoreIndexInternalsSampleDatabase.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script restores the IndexInternals sample database 
            as used in Chapter 6 of SQL Server 2008 Internals.
  
  Date:     Tweaked for SQL 2016+ (See notes: 23-35 for what to change)
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- IMPORTANT NOTES: 
-- 1) This is a compressed SQL Server 2008 backup and will restore to ALL versions
--    of SQL Server - SQL Server 2008 and higher.
-- 2) All examples expect a database name of IndexInternals. However, if you
--    already have a database with this name, you can change it. In all other
--    scripts, you'll need to be sure to continue to change this based on your
--    new database name. (LINE 45)
-- 3) Be sure to set your complete path\file based on where the 
--    IndexInternals2008.BAK is located. (LINE 46)
-- 4) Be sure to set the server/instance name for restore. (LINES 48-51)
-- 5) Be sure to set your instance directory structure based on your
--    version/installation. (LINES 53-56) NOTE: You only need ONE setting
--    for RestoreToDirectory. The others are just samples.
-- 6) Be sure to set your COMPATIBILITY LEVEL to the correct setting...
--    this is a bit of a can of worms. Read lines 103 to the end!


-- In general, this script should take less than 30 seconds to execute.

:ON ERROR EXIT
go

:SETVAR DB IndexInternals
:SETVAR IndexInternalsBackup "d:\IndexInternals\01_IndexInternals\IndexInternals2008.bak"

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
	ALTER DATABASE $(DB)
		SET RESTRICTED_USER 
		WITH ROLLBACK IMMEDIATE;
go

IF SUBSTRING(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 1, 2) < '10' 
BEGIN
	RAISERROR('The IndexInternals backup can only be restored on SQL Server 2008 and higher.', 16, -1)
	RETURN
END;
go

IF substring(convert(varchar, SERVERPROPERTY('ProductVersion')), 1, 2) >= '10' 
	RESTORE DATABASE $(DB) 
	FROM  DISK = N'$(IndexInternalsBackup)'
	WITH  FILE = 1,  
		MOVE N'IndexInternalsData' 
			TO N'$(RestoreToDirectory)\IndexInternalsData.mdf',  
		MOVE N'IndexInternalsLog' 
			TO N'$(RestoreToDirectory)\IndexInternalsLog.ldf',
	STATS = 10, REPLACE;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE $(DB)
		SET MULTI_USER 
		WITH ROLLBACK IMMEDIATE;
go

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

SELECT  @ServerVersion = CONVERT(char(2), SERVERPROPERTY('ProductMajorVersion')) + '0';

IF CONVERT(TINYINT, SERVERPROPERTY('ProductMajorVersion')) > 12
	SET @LegacyCEScoped = 1;

-- Testing
-- SELECT @ServerVersion, @LegacyCEScoped

DECLARE @ExecStr varchar(512) = 
	('ALTER DATABASE ' 
	+ QUOTENAME('$(DB)', N']') 
	+ ' SET COMPATIBILITY_LEVEL = ' 
	+ @ServerVersion);

EXEC (@ExecStr);

USE [$(DB)];

IF @LegacyCEScoped = 1
	ALTER DATABASE SCOPED CONFIGURATION 
		SET LEGACY_CARDINALITY_ESTIMATION = ON;
go

EXEC sp_dbcmptlevel [$(DB)];
go