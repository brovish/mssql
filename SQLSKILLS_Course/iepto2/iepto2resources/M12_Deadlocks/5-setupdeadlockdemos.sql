USE [master];
GO
-- Remove the database if it exists
IF DB_ID(N'DeadlockDemo') IS NOT NULL
BEGIN
	ALTER DATABASE [DeadlockDemo] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
	DROP DATABASE [DeadlockDemo];
END
GO

-- Create the database
CREATE DATABASE [DeadlockDemo];
GO
USE [DeadlockDemo];
GO
SET NOCOUNT ON
GO
-- Create the table for testing
CREATE TABLE [TableA] 
(	
	[col1] INT,
	[col2] INT, 
	[col3] INT, 
	[col4] CHAR(100) DEFAULT('abc') NOT NULL
);
GO

DECLARE @int INT;
SET @int = 1;

-- Load data into the table
WHILE (@int <= 1000) 
BEGIN
    INSERT INTO [TableA] 
		([col1], [col2], [col3], [col4])
	VALUES (@int*2, @int*2, @int*2, @int*2);
    SET @int = @int + 1;
END
GO

CREATE CLUSTERED INDEX [cidx_TableA] 
ON [TableA] ([col1]);

-- Delete row 105 and 106
DELETE [TableA] WHERE [col1] = 105;
DELETE [TableA] WHERE [col1] = 106;
GO

-- Create the table for testing
CREATE TABLE [TableB] 
(	
	[col1] INT IDENTITY PRIMARY KEY,
	[col2] CHAR(100) DEFAULT('abc') NOT NULL
);
GO

INSERT INTO [TableB] DEFAULT VALUES;
GO

-- Create a non-clustered index
CREATE NONCLUSTERED INDEX [idx_TableA_col2] 
ON [TableA] ([col2]);
GO

-- Create a select stored procedure
CREATE PROCEDURE [BookmarkLookupSelect]
( @col2 INT )
AS 
BEGIN
	-- Declare variables to prevent outputing rowsets
	DECLARE @out1 INT, @out2 INT;

    SELECT @out1 = [col2], @out2 = [col3] 
	FROM [TableA] 
	WHERE [col2] BETWEEN @col2 AND @col2+1;
END
GO

-- Create a update stored procedure
CREATE PROCEDURE [BookmarkLookupUpdate]
( @col1 INT )
AS
BEGIN
    UPDATE [TableA] 
	SET [col2] = [col2]+1 
	WHERE [col1] = @col1;

    UPDATE [TableA] 
	SET [col2] = [col2]-1 
	WHERE [col1] = @col1;
END
GO
