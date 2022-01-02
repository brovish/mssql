-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Written by Kimberly L. Tripp - all rights reserved.
-- 
-- For more scripts and sample code, check out 
-- 	http://www.SQLSkills.com
--
-- Disclaimer - Thoroughly test this script, execute at your own risk.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SET STATISTICS IO ON
-- Turn Graphical Showplan ON (Ctrl+K)

-- sp_executesql using multiple parameters
DECLARE @ExecStr    nvarchar(4000)
SELECT @ExecStr = 'SELECT * FROM dbo.titles WHERE price > @price AND type = @type'
EXEC sp_executesql @ExecStr,	-- string should have place holders with @ for variablename
                                    N'@price money, @type char(12)',		-- each one should be typed
                                    10.00, 'business'					-- list the values in the order in which they are within the query...
go

-- Sp_executesql within a dynamic string
DECLARE @tablename	sysname
SELECT @tablename = 'dbo.titles'
EXEC('DECLARE @ExecStr    nvarchar(4000)
SELECT @ExecStr = ''SELECT * FROM ' + @tablename + ' WHERE price = @price''
EXEC sp_executesql @ExecStr,
                                    N''@price money'',
                                    19.99')
go

-- Example using Output
DECLARE @tname	sysname,
		@DBUse		nvarchar(200),
		@StrResult	int,
		@ExecStr	nvarchar(2000)
SELECT @tname = 'authors'
SELECT @DBUse = 'USE pubs '
SELECT @ExecStr = (@DBUse + ' SELECT @StrResult=OBJECTPROPERTY(object_id(''' + QUOTENAME(@tname, ']') + '''),''IsTable'')')
--SELECT @ExecStr		-- USE SELECT to show the string before execution (check for typos, etc.)
EXECUTE sp_executesql @ExecStr
				, N'@StrResult int OUTPUT' 	-- declared at OUTPUT
				, @StrResult OUTPUT		-- used with OUTPUT
SELECT @StrResult
SELECT @ExecStr = (@DBUse + ' SELECT @StrResult=object_id(''' + QUOTENAME(@tname, ']') + ''')')
--SELECT @ExecStr		-- USE SELECT to show the string before execution (check for typos, etc.)
EXECUTE sp_executesql @ExecStr
				, N'@StrResult int OUTPUT'
				, @StrResult OUTPUT
SELECT @StrResult
go