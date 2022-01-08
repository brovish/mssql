/*============================================================================
	File: SQLskills_BufferCacheSummary.sql

	Summary: This script provides a summary of the buffer cache usage by
	database, providing information about the amount of memory used by
	database and how much of that memory is storing empty data pages.

	Date: May 2011 

	SQL Server Versions:
		10.0.2531.00 (SS2008 SP1)
		9.00.4035.00 (SS2005 SP3)
------------------------------------------------------------------------------
	Copyright (C) 2010 Paul S. Randal, SQLskills.com
	All rights reserved. 

	For more scripts and sample code, check out
		http://www.sqlskills.com/ 

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit. 

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/ 

:Setvar SQLCMDMAXVARTYPEWIDTH 0
:Setvar SQLCMDHEADERS 5000

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULL_DFLT_ON ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ANSI_NULLS ON

SELECT '-- SQLskills_BufferCacheSummary'

SELECT 
   (CASE WHEN ([database_id] = 32767)
       THEN 'Resource Database'
       ELSE DB_NAME ([database_id]) END) AS [DatabaseName],
   COUNT (*) * 8 / 1024 AS [MBUsed],
   SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [MBEmpty]
FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id];
GO 
