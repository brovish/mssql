USE [Credit2];
GO


DBCC DROPCLEANBUFFERS;
GO

SELECT  c1.charge_no,
        c1.category_no,
        c1.charge_dt,
        c1.member_no,
        c1.charge_amt
FROM    dbo.charge c1
WHERE   c1.charge_amt > (SELECT AVG(c2.charge_amt)
                         FROM   dbo.charge c2
                         WHERE  c2.charge_dt < c1.charge_dt) AND
        c1.member_no = 9620 AND
        c1.category_no IN (2, 3)
OPTION  (MAXDOP 1, RECOMPILE)
GO 10000000