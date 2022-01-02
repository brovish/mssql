-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Written by Kimberly L. Tripp
-- 
-- For more scripts and sample code, check out 
-- 	http://www.SQLSkills.com
--
-- Disclaimer - Thoroughly test this script, execute at your own risk.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- These three procedures demonstrate how dynamic string execution can be used
-- securely...and how - if not prepared - users can creatively delete/destroy data.

-- This example came up from a newsgroup...someone wanted to use create database
-- from a client application and was concerned about parsing the string properly to
-- support all database names (even somewhat illogical ones :). The answer to the 
-- question (which is to use the function QUOTENAME()) led to quite a security 
-- discussion. The answer provides not only the ability to create a database with 
-- any name but to also do so securely - even with dynamic string execution!

CREATE PROCEDURE dbo.CreateDBProc
(
	@DBName	sysname
)
AS
DECLARE @ExecStr	nvarchar(2000)
SELECT @DBName = QUOTENAME(@DBName, ']')
SELECT @ExecStr = 'CREATE DATABASE ' + @DBName -- + all of the other stuff to place the files, etc...
SELECT @ExecStr
--EXEC(@ExecStr)
go
EXEC dbo.CreateDBProc 'This is the most stupid :) name I can think of with [brackets] and all sorts of junk! in the name'
go

-- So what is the problem with the following:

CREATE PROCEDURE dbo.CreateDBProc2
(
	@DBName	sysname
)
AS
DECLARE @ExecStr	nvarchar(2000)
SELECT @ExecStr = 'CREATE DATABASE ' + @DBName -- + all of the other stuff to place the files, etc...
SELECT @ExecStr
--EXEC(@ExecStr)
go
EXEC dbo.CreateDBProc2 'this is my test database name'
EXEC dbo.CreateDBProc2 '[fakedbname] DROP DATABASE foo --'
EXEC dbo.CreateDBProc2 '[fakedbname] EXEC(''CREATE PROC Test AS SELECT * FROM pubs.dbo.authors'') DROP DATABASE foo --'
go

CREATE PROCEDURE dbo.CreateDBProc3
(
	@DBName	sysname
)
AS
DECLARE @ExecStr	nvarchar(2000)
SELECT @ExecStr = 'CREATE DATABASE [' + @DBName + ']' -- + all of the other stuff to place the files, etc...
SELECT @ExecStr
go
EXEC dbo.CreateDBProc3 'fakedbname] DROP DATABASE foo--'
Go

-- The batch separator "go" is not supported within EXEC...but if a creative
-- user adds dynamic string execution within the string... they can even submit
-- more than one batch!

-- CREATE DATABASE foo
-- DROP DATABASE fakedbname
-- DROP PROCEDURE test
