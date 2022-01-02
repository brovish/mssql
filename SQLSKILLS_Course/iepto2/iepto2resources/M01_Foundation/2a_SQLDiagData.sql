/*============================================================================
  File:     2a_SQLDiagData.sql

  Summary:  This script queries the stored configuration
			data.

  Date:     April 2021

  SQL Server Version: 2005/2008/2008R2/2012/2014/2016/2017/2019
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com

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

USE [sqlnexus];
GO

/*
	https://sqlserverbuilds.blogspot.com/
*/
SELECT [Name], [Character_Value]
FROM [dbo].[tbl_XPMSVER]
WHERE [Index] IN (1, 2, 8, 16, 19);

SELECT *
FROM [dbo].[SQLskills_sysconfigurations]
ORDER BY NonDefault DESC, Name;
GO

SELECT *
FROM [dbo].[SQLskills_Cores_vs_MaxDop];
GO

SELECT *
FROM [dbo].[sys_dm_os_schedulers];
GO

SELECT *
FROM [dbo].[SQLskills_LastCheckDBDate];
GO

SELECT *
FROM [dbo].[SQLskills_LastCheckDBDate];

