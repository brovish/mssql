USE Credit;
GO

-- Run in three separate query windows

SET ROWCOUNT 1;

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
