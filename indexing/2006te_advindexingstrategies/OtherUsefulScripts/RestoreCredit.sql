/*============================================================================
  File:     RestoreCredit.sql

  Summary:  Restore the Credit Database to give us a clean start between
			demos.
  
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

-- This script takes about 20 seconds to execute

SET NOCOUNT ON
go

USE master
go

IF DATABASEPROPERTYEX('Credit', 'Collation') IS NOT NULL
	ALTER DATABASE Credit
		SET RESTRICTED_USER 
		WITH ROLLBACK IMMEDIATE
go

RESTORE DATABASE [credit] 
	FROM  DISK = N'C:\SQLskills\CreditBackup80.BAK' 
WITH  FILE = 1,  
	MOVE N'CreditData' 
		TO N'c:\Program Files\Microsoft SQL Server\MSSQL.1\mssql\Data\CreditData.mdf'
	, MOVE N'CreditLog' 
		TO N'c:\Program Files\Microsoft SQL Server\MSSQL.1\mssql\Data\CreditLog.ldf',  
NOUNLOAD,  STATS = 10,
REPLACE
GO
