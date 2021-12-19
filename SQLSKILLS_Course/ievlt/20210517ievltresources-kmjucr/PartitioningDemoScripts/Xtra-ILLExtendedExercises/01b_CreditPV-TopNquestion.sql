-- This scenario was added for a question during our open Q&A

USE Credit;
go

SET STATISTICS IO ON
go

-- This was related to whether or not TOP would do elimination or not
-- It will only do elimination with a WHERE clause but it will also
-- only get the TOP n rows from each "partition" so it's not quite
-- as bad. But, depending on the order by, etc. It still might
-- do a lot of processing. Much better if you add a WHERE clause
-- even if it's kind of a "dummy" or contrived one that just
-- focuses on the most "recent" data (given the Order By DESC)

-- First scenario without a WHERE clause
SELECT TOP 100 [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
ORDER BY Charge_dt DESC
GO

-- Any WHERE clause will reduce the number of tables
-- accessed.
SELECT TOP 100 [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE charge_dt > '20170701' 
ORDER BY Charge_dt DESC
GO

-- Better if you can limit it to the "most recent" day
-- or month... this one is hard-coded
SELECT TOP 100 [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE charge_dt > '20170901' 
ORDER BY Charge_dt DESC
GO

-- But programmatically limiting it will work too
-- and be more flexible moving forward:
SELECT TOP 100 [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE charge_dt > dateadd(m, -1, '20171001')
ORDER BY Charge_dt DESC
GO


