USE [Credit];
GO

-- What is the I/O overhead?
SET STATISTICS IO ON;
SET NOCOUNT ON;
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

/*
Table 'charge_demo'. Scan count 0, logical reads 871530, physical reads 0, read-ahead reads 1827, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'charge'. Scan count 1, logical reads 1763, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'charge_demo'. Scan count 5, logical reads 902296, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

-- Now let's drop the trigger and replace with a constraint
DROP TRIGGER [dbo].[trg_i_charge_demo];
GO

ALTER TABLE [dbo].[charge_demo]
ADD CONSTRAINT [def_insert_dt]
DEFAULT (GETDATE())
FOR [insert_dt];
GO

SET STATISTICS IO ON;
SET NOCOUNT ON;
GO

-- Clear table
TRUNCATE TABLE [dbo].[charge_demo];
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

/*
Table 'charge_demo'. Scan count 0, logical reads 820862, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'charge'. Scan count 1, logical reads 1763, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

SELECT  TOP 10 insert_dt
FROM    [dbo].[charge_demo]

DROP TABLE [dbo].[charge_demo];
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
SET NOCOUNT ON;
GO
