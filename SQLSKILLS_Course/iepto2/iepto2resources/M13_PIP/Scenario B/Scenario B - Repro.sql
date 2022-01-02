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

-- Run in three separate query windows
WHILE 1 = 1 
    BEGIN
        SELECT  member.member_no,
                member.lastname,
                member.firstname,
                region.region_no,
                region.region_name,
                provider.provider_name,
                category.category_desc,
                charge.charge_no,
                charge.provider_no,
                charge.category_no,
                charge.charge_dt,
                charge.charge_amt,
                charge.charge_code
        FROM    provider,
                member,
                region,
                category,
                charge
        WHERE   member.member_no = charge.member_no AND
                region.region_no = member.region_no AND
                provider.provider_no = charge.provider_no AND
                category.category_no = charge.category_no
        OPTION  (HASH JOIN, MAXDOP 1);
    END
  GO  
