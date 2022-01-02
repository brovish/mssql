USE Credit;
GO

-- Doing this to bring down the available memory grant 
-- EstimatedAvailableMemoryGrant

EXEC [master].[sys].[sp_configure] 'show advanced options', 1;
RECONFIGURE;
GO

EXEC [master].[sys].[sp_configure] 'max server memory', 500;
RECONFIGURE;
GO

EXEC [master].[sys].[sp_configure] 'show advanced options', 0;
RECONFIGURE;
GO

DBCC FREEPROCCACHE;
GO

-- Skewed statistics can often cause spills
-- We'll build in an under-estimate
-- DON'T DO THIS IN PRODUCTION - just for demonstrating CE issues!
UPDATE STATISTICS dbo.charge
WITH ROWCOUNT = 100000000000000, PAGECOUNT = 10000000000000;
