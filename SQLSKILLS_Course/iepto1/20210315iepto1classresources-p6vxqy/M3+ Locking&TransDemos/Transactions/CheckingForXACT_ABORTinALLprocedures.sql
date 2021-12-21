-- This was just a quick check to see if any procedures do NOT
-- have the setting for XACT_ABORT on

-- In credit (by default) NONE of them have it set... let's
-- create one that does:

USE [credit];
go

CREATE PROCEDURE [testxact]
AS
SET XACT_ABORT ON;
SET NOCOUNT ON;
SELECT * FROM [dbo].[member];
go

SELECT count(*)
FROM sys.objects as so
WHERE so.type = 'P'; -- 23 objects
go

SELECT * 
FROM [sys].[objects] AS [so]
WHERE [so].[type] = 'P'
	AND NOT EXISTS 
	(SELECT * 
	FROM [sys].[sql_modules] AS [sm]
	WHERE [sm].[object_id] = [so].[object_id]
		AND [sm].[definition] LIKE '%XACT_ABORT ON%');
go

-- or - find all of them that do

SELECT * 
FROM [sys].[objects] AS [so]
WHERE [so].[type] = 'P'
	AND EXISTS 
	(SELECT * 
	FROM [sys].[sql_modules] AS [sm]
	WHERE [sm].[object_id] = [so].[object_id]
		AND [sm].[definition] LIKE '%XACT_ABORT ON%');
go