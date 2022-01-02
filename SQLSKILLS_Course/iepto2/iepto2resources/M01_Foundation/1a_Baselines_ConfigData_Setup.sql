/*============================================================================
  File:     1a_Baselines_ConfigData_Setup.sql

  Summary:  This script creates the table to hold
			configuration data, the statement to use
			in a scheduled job to snapshot the data
			regularly, and the stored procedure
			to report on the data.

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

USE [BaselineData];
GO

IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'SQLskills_ConfigData'))

CREATE TABLE [dbo].[SQLskills_ConfigData] (
    [ConfigurationID] [int] NOT NULL ,
    [Name] [nvarchar](35) NOT NULL ,
    [Value] [sql_variant] NULL ,
    [ValueInUse] [sql_variant] NULL ,
    [CaptureDate] [datetime]
) ON  [PRIMARY];
GO

CREATE CLUSTERED INDEX [CI_SQLskills_ConfigData] ON [dbo].[SQLskills_ConfigData] ([CaptureDate],[ConfigurationID]);

ALTER TABLE [dbo].[SQLskills_ConfigData] ADD  DEFAULT (SYSDATETIME()) FOR [CaptureDate];
 

/*
	Statement to use in scheduled job
*/	
INSERT  INTO [dbo].[SQLskills_ConfigData] ( 
	[ConfigurationID] ,
    [Name] ,
    [Value] ,
	[ValueInUse] 
	)
SELECT  [configuration_id] ,
	[name] ,
    [value] ,
    [value_in_use] 
FROM [sys].[configurations];


