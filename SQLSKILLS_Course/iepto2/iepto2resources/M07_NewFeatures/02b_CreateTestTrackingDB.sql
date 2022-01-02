/*============================================================================
  File:     02b_CreateTestTrackingDB.sql

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

USE [master];
GO

DROP DATABASE IF EXISTS [TestTracking];
GO

CREATE DATABASE [TestTracking]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TestTracking', FILENAME = N'C:\Databases\TestTracking.mdf' , SIZE = 256MB , FILEGROWTH = 524288KB )
 LOG ON 
( NAME = N'TestTrackingLog', FILENAME = N'C:\Databases\TestTracking_log.ldf' , SIZE = 524288KB , FILEGROWTH = 524288KB )
GO

  
ALTER DATABASE [TestTracking] SET RECOVERY SIMPLE;
GO

USE [TestTracking];
GO


CREATE TABLE [TrackTests] (
	[TestID] INT IDENTITY(1,1), 
	[TestName] VARCHAR (200),
	[TestStartTime] DATETIME2,
	[TestEndTime] DATETIME2)


   	     