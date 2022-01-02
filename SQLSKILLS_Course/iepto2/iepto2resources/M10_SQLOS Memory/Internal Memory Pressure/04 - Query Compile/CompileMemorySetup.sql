USE [master];
GO
IF DB_ID('CompileMemory') IS NOT NULL
BEGIN
	ALTER DATABASE CompileMemory SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CompileMemory;
END
GO
CREATE DATABASE CompileMemory;
GO
USE CompileMemory;
GO
CREATE TABLE Test(RowID INT IDENTITY PRIMARY KEY, ParentID INT, CurrentValue NVARCHAR(100));

DECLARE @loop INT = 1
WHILE @loop < 10
BEGIN
DECLARE @sqlcmd VARCHAR(MAX) = 
'CREATE TABLE Test'+CAST(@loop AS VARCHAR)+'(RowID INT IDENTITY PRIMARY KEY, ParentID INT, CurrentValue NVARCHAR(100));
INSERT INTO Test'+CAST(@loop AS VARCHAR)+' (ParentID, CurrentValue)
SELECT TOP 100000 
	CASE WHEN (t1.number%'+CAST(@loop AS VARCHAR)+')%3 = 0 THEN t1.number-t1.number%6 ELSE t1.number END, 
	''Test''+CAST(t1.number%'+CAST(@loop AS VARCHAR)+' AS VARCHAR)
FROM master.dbo.spt_values AS t1
CROSS JOIN master.dbo.spt_values AS t2
WHERE t1.type = ''P''
AND t2.number < 1';
EXECUTE(@sqlcmd);
SET @loop = @loop+1;
END