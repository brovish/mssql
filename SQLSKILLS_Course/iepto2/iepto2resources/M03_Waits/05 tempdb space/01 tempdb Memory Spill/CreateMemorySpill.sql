/*============================================================================
  File:     CreateMemorySpill.sql

  Summary:  Create a tempdb memory spill

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [master];
GO

IF DATABASEPROPERTYEX (N'SalesDB', N'Version') > 0
BEGIN
	ALTER DATABASE [SalesDB] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SalesDB];
END
GO

-- Make sure we start with a clean database
RESTORE DATABASE [SalesDB]
	FROM DISK = N'D:\SQLskills\DemoBackups\SalesDB2014.bak'
WITH STATS = 10, REPLACE;
GO

USE [SalesDB];
GO

-- Large query spill to tempdb
--
-- Nasty query
--
SELECT [S].*, [P].* from [Sales] [S]
JOIN [Products] [P] ON [P].[ProductID] = [S].[ProductID]
ORDER BY [P].[Name];
GO

-- Go troubleshoot...

