USE [Credit];
GO

SET STATISTICS IO ON;
GO

INSERT  [dbo].[charge_demo]
        (charge_no,
         member_no,
         provider_no,
         category_no,
         charge_dt,
         charge_amt,
         statement_no,
         charge_code)
        SELECT TOP 300000
                charge_no,
                member_no,
                provider_no,
                category_no,
                charge_dt,
                charge_amt,
                statement_no,
                charge_code
        FROM    [dbo].[charge]
        ORDER BY charge_no;
GO

SET STATISTICS IO OFF;
GO

TRUNCATE TABLE [dbo].[charge_demo];
GO
