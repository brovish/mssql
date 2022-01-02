/*============================================================================
  File:     02c_TestDiskTables.sql

  SQL Server Versions: 2016 onwards
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

/*
	Test performance of disk-based table
*/

USE [InMemTesting]
GO

SET NOCOUNT ON;

DECLARE @NumRowsToInsert INT = 100000;
DECLARE @TestName VARCHAR(200) = 'DiskTable Insert - ' + CAST(@NumRowsToInsert AS VARCHAR(10)) + ' rows';

DECLARE @TestID INT;

/* 
	Setup test info
*/

INSERT INTO [TestTracking].[dbo].[TrackTests] ([TestName]) VALUES (@TestName);
SELECT @TestID = MAX(TestID) FROM [TestTracking].[dbo].[TrackTests];



/* 
	set start time 
*/
UPDATE [TestTracking].[dbo].[TrackTests] 
SET [TestStartTime] = SYSDATETIME() 
WHERE [TestID] = @TestID;

/*
	run inserts
*/
EXEC [dbo].[DiskTable_Inserts] @NumRowsToInsert;

/* 
	set the stop time 
*/
UPDATE [TestTracking].[dbo].[TrackTests] SET [TestEndTime] = SYSDATETIME() WHERE [TestID] = @TestID;

