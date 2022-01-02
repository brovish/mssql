-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Written by Kimberly L. Tripp
-- 
-- For more scripts and sample code, check out 
-- 	http://www.SQLskills.com
--
-- Disclaimer - Thoroughly test this script, execute at your own risk.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- This is what we want parameterized
SELECT * FROM @DBName.dbo.@TableName

-- How do we get to this?
EXEC(N'SELECT * FROM ' + @DBName + N'.dbo.' + @TableName)

-- (1) Enter the string as if parameters were supported...
	SELECT * FROM @DBName.dbo.@TableName
-- (2) Add EXEC at the beginning and then a paren at both ends
	EXEC(SELECT * FROM @DBName.dbo.@TableName)
-- (3) Starting at the first paren add single quotes - right up to each variable!
	EXEC('SELECT * FROM '@DBName'.dbo.'@TableName)
-- (4) Make sure to add the + for concatenation
	EXEC('SELECT * FROM ' + @DBName + '.dbo.' + @TableName)
-- (5) Is it unicode? Preceed all strings with N
	EXEC(N'SELECT * FROM ' + @DBName + N'.dbo.' + @TableName)

-- How about a Proc?
CREATE PROC GetData
(
                @DBName            sysname,    
                @TableName        sysname
)
AS
DECLARE @ExecStr              nvarchar(4000)
SELECT @ExecStr = N'SELECT * FROM ' + @DBName + N'.dbo.' + @TableName
-- For Testing use the SELECT @ExecStr
--SELECT @ExecStr 
-- Once Tested use EXEC(@ExecStr) for execution
EXEC(@ExecStr)
go
EXEC GetData N'Northwind', N'Orders'
EXEC GetData N'pubs', N'authors'
EXEC GetData N'pubs', N'titles'
go

DECLARE @DBName     sysname,    --nvarchar(128)
		@TableName  sysname,
		@ExecStr    nvarchar(4000),
		@lname      varchar(30)
SELECT @DBName = N'pubs',
                @TableName = N'authors',
                @lname = QUOTENAME('O''leary', '''')
-- EXEC(N'SELECT * FROM ' + @DBName 
--             + N'..' + @TableName)
-- select * from authors
SELECT @ExecStr = N'SELECT * FROM ' + @DBName 
                                + N'.dbo.' + @TableName
                                + N' where au_lname = ' + @lname 
SELECT @ExecStr
EXEC(@ExecStr)
go
