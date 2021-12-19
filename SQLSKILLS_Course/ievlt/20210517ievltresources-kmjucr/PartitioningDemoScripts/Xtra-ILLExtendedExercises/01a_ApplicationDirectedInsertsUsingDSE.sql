-- For more information on preventing SQL injection
-- check out: http://www.sqlskills.com/blogs/kimberly/little-bobby-tables-sql-injection-and-execute-as/

-- For inserts, I recommend dynamic string execution
USE [prod_database]
GO

CREATE USER User_table_add_row WITHOUT LOGIN
go

-- Grant permissions to the partitions you want the procedure to be able to insert into
...
GRANT INSERT ON table_201910 to User_table_add_row
GRANT INSERT ON table_201911 to User_table_add_row
GRANT INSERT ON table_201912 to User_table_add_row
...
go

-- Set the appropriate session settings
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create the procedure to be dynamic (based on date)
CREATE PROCEDURE [dbo].[table_add_row]
(
    @Parameters
)
WITH EXECUTE AS 'User_table_add_row'
AS

DECLARE @TableName	nvarchar(128),
	@ExecStr	nvarchar(max);

SELECT @Tablename = N'table_' 
	+ convert(nchar(4), YEAR(GETDATE())) 
	+ RIGHT('00' + convert(nvarchar(2), MONTH(GETDATE())), 2);
--SELECT @Tablename 

SELECT @ExecStr = 
N'INSERT INTO ' + QUOTENAME(@TableName, ']') + N'  
(

    ... COLUMN LIST ...

) VALUES 
(
    ' +  
	... VALUES LIST ...
      + 
')';

--SELECT @ExecStr
EXEC (@ExecStr)
go