/*============================================================================
  File:     02a_Setup.sql

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

DROP DATABASE IF EXISTS [InMemTesting];
GO

/*
	Create database 
*/
CREATE DATABASE [InMemTesting]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InMemTesting', FILENAME = N'C:\Databases\InMemTesting\InMemTesting.mdf', SIZE = 512MB , FILEGROWTH = 256MB )
 LOG ON 
( NAME = N'InMemTesting_log', FILENAME = N'C:\Databases\InMemTesting\InMemTesting_log.ldf', SIZE = 1024MB , FILEGROWTH = 1024MB )
GO

ALTER DATABASE [InMemTesting] ADD FILEGROUP [DiskTables];
GO
  
ALTER DATABASE [InMemTesting] ADD FILE  
    (NAME = [DiskTables_F1], FILENAME= 'C:\Databases\DiskTables\DiskTables_F1', SIZE = 1024MB , FILEGROWTH = 1024MB )  
    TO FILEGROUP [DiskTables];  
GO

ALTER DATABASE [InMemTesting] ADD FILEGROUP [InMem_OLTP]  
    CONTAINS MEMORY_OPTIMIZED_DATA;  
  
ALTER DATABASE [InMemTesting] ADD FILE  
    (NAME = [InMem_OLTP_F1], FILENAME= 'C:\Databases\InMemTable\InMem_OLTP_F1')  
    TO FILEGROUP [InMem_OLTP];  
GO

ALTER DATABASE [InMemTesting] SET RECOVERY FULL;
GO

USE [InMemTesting];
GO

/*
	Create disk based table and SP
*/
DROP TABLE IF EXISTS [DiskTable];  
GO

CREATE TABLE [dbo].[DiskTable] (
	[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED, 
	[Name] VARCHAR (100) NOT NULL, [Type] INT NOT NULL,
	[c4] INT NULL, [c5] INT NULL, [c6] INT NULL, [c7] INT NULL, 
	[c8] VARCHAR(255) NULL, [c9] VARCHAR(255) NULL,	[c10] VARCHAR(255) NULL, [c11] VARCHAR(255) NULL)
ON [DiskTables];
GO

DROP PROCEDURE IF EXISTS [DiskTable_Inserts];  
GO

CREATE PROCEDURE [DiskTable_Inserts]
	@NumRows INT
AS
BEGIN 

DECLARE @Name INT;
DECLARE @Type INT;
DECLARE @ColInt INT;
DECLARE @ColVarchar VARCHAR(255)
DECLARE @RowLoop INT = 1;

WHILE (@RowLoop < @NumRows)
	BEGIN

		SET @Name = CONVERT (INT, RAND () * 1000) + 1;
		SET @Type = CONVERT (INT, RAND () * 100) + 1;
		SET @ColInt = CONVERT (INT, RAND () * 850) + 1
		SET @ColVarchar = CONVERT (INT, RAND () * 1300) + 1


		INSERT INTO [dbo].[DiskTable] (
			[Name], [Type], [c4], [c5], [c6], [c7], [c8], [c9],	[c10], [c11]
			)
		VALUES (@Name, @Type, @ColInt, @ColInt + (CONVERT (INT, RAND () * 20) + 1), 
		@ColInt + (CONVERT (INT, RAND () * 30) + 1), @ColInt + (CONVERT (INT, RAND () * 40) + 1),
		@ColVarchar, @ColVarchar + (CONVERT (INT, RAND () * 20) + 1), @ColVarchar + (CONVERT (INT, RAND () * 30) + 1),
		@ColVarchar + (CONVERT (INT, RAND () * 40) + 1))
		
		SELECT @RowLoop = @RowLoop + 1
	END
END
GO

/*
	Create InMem table and regular SP
*/
DROP TABLE IF EXISTS [InMemOLTP_Inserts];  
GO

CREATE TABLE [dbo].[InMemOLTP_Inserts] (
	[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=1000000), 
	[Name] VARCHAR (100) NOT NULL, [Type] INT NOT NULL,
	[c4] INT NULL, [c5] INT NULL, [c6] INT NULL, [c7] INT NULL, 
	[c8] VARCHAR(255) NULL, [c9] VARCHAR(255) NULL,	[c10] VARCHAR(255) NULL, [c11] VARCHAR(255) NULL)
WITH (MEMORY_OPTIMIZED=ON, DURABILITY = SCHEMA_AND_DATA);
GO

DROP PROCEDURE IF EXISTS [StandardSP_Inserts];  
GO

CREATE PROCEDURE [StandardSP_Inserts]
	@NumRows INT
AS

DECLARE @Name INT;
DECLARE @Type INT;
DECLARE @ColInt INT;
DECLARE @ColVarchar VARCHAR(255)
DECLARE @RowLoop INT = 1;

WHILE (@RowLoop < @NumRows)
	BEGIN

		SET @Name = CONVERT (INT, RAND () * 1000) + 1;
		SET @Type = CONVERT (INT, RAND () * 100) + 1;
		SET @ColInt = CONVERT (INT, RAND () * 850) + 1
		SET @ColVarchar = CONVERT (INT, RAND () * 1300) + 1


		INSERT INTO [dbo].[InMemOLTP_Inserts] (
			[Name], [Type], [c4], [c5], [c6], [c7], [c8], [c9],	[c10], [c11]
			)
		VALUES (@Name, @Type, @ColInt, @ColInt + (CONVERT (INT, RAND () * 20) + 1), 
		@ColInt + (CONVERT (INT, RAND () * 30) + 1), @ColInt + (CONVERT (INT, RAND () * 40) + 1),
		@ColVarchar, @ColVarchar + (CONVERT (INT, RAND () * 20) + 1), @ColVarchar + (CONVERT (INT, RAND () * 30) + 1),
		@ColVarchar + (CONVERT (INT, RAND () * 40) + 1))
		
		SELECT @RowLoop = @RowLoop + 1
	END
GO
/*
	Create InMem table and natively compiled SP
*/
DROP TABLE IF EXISTS [InMemOLTP];  
GO

CREATE TABLE [dbo].[InMemOLTP] (
	[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=1000000), 
	[Name] VARCHAR (100) NOT NULL, [Type] INT NOT NULL,
	[c4] INT NULL, [c5] INT NULL, [c6] INT NULL, [c7] INT NULL, 
	[c8] VARCHAR(255) NULL, [c9] VARCHAR(255) NULL,	[c10] VARCHAR(255) NULL, [c11] VARCHAR(255) NULL)
WITH (MEMORY_OPTIMIZED=ON, DURABILITY = SCHEMA_AND_DATA);
GO

DROP PROCEDURE IF EXISTS [InMemOLTP_All];  
GO

CREATE PROCEDURE [InMemOLTP_All]
	@NumRows INT
	WITH
		NATIVE_COMPILATION,
		SCHEMABINDING
AS
BEGIN ATOMIC
	WITH
		(TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')


DECLARE @Name INT;
DECLARE @Type INT;
DECLARE @ColInt INT;
DECLARE @ColVarchar VARCHAR(255)
DECLARE @RowLoop INT = 1;

WHILE (@RowLoop < @NumRows)
	BEGIN

		SET @Name = CONVERT (INT, RAND () * 1000) + 1;
		SET @Type = CONVERT (INT, RAND () * 100) + 1;
		SET @ColInt = CONVERT (INT, RAND () * 850) + 1
		SET @ColVarchar = CONVERT (INT, RAND () * 1300) + 1


		INSERT INTO [dbo].[InMemOLTP] (
			[Name], [Type], [c4], [c5], [c6], [c7], [c8], [c9],	[c10], [c11]
			)
		VALUES (@Name, @Type, @ColInt, @ColInt + (CONVERT (INT, RAND () * 20) + 1), 
		@ColInt + (CONVERT (INT, RAND () * 30) + 1), @ColInt + (CONVERT (INT, RAND () * 40) + 1),
		@ColVarchar, @ColVarchar + (CONVERT (INT, RAND () * 20) + 1), @ColVarchar + (CONVERT (INT, RAND () * 30) + 1),
		@ColVarchar + (CONVERT (INT, RAND () * 40) + 1))
		
		SELECT @RowLoop = @RowLoop + 1
	END
END
GO


/*
	enable Query Store
*/
USE [master];
GO
ALTER DATABASE [InMemTesting] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE,
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),  
	DATA_FLUSH_INTERVAL_SECONDS = 60,
	INTERVAL_LENGTH_MINUTES = 5, 
	MAX_STORAGE_SIZE_MB = 512,
	QUERY_CAPTURE_MODE = ALL,
	SIZE_BASED_CLEANUP_MODE = AUTO,
	MAX_PLANS_PER_QUERY = 200);
GO


/*
	Must execute SP before can enable query exec stats
*/
USE [InMemTesting];
GO

EXEC [dbo].[InMemOLTP_All] 100;
GO

/*
	Enable query exec stats
	(instance level, or for SP)
*/
EXEC [sys].[sp_xtp_control_proc_exec_stats] @new_collection_value = 1;
GO

DECLARE @DB_ID INT = DB_ID()  
DECLARE @SP_ID INT = OBJECT_ID('dbo.InMemOLTP_All');  
DECLARE @collection_enabled BIT;  

EXEC [sys].[sp_xtp_control_query_exec_stats] 
	@new_collection_value = 1,   
    @database_id = @DB_ID, 
	@xtp_object_id = @SP_ID;  

/*
	Check the state of the collection flag 
*/
EXEC [sys].[sp_xtp_control_query_exec_stats] @database_id = @db_id,   
    @xtp_object_id = @SP_ID,   
    @old_collection_value= @collection_enabled output;  
SELECT @collection_enabled AS 'collection status';  
GO

/*
	clear data from Query Store
*/
ALTER DATABASE [InMemTesting] SET QUERY_STORE CLEAR;
GO