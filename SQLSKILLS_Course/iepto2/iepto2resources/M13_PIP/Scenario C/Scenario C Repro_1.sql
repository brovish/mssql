USE Credit;
GO

SET NOCOUNT ON;
GO


WHILE 1 = 1 
    BEGIN

        SELECT  [charge].[charge_no],
                [charge].[charge_dt]
        FROM    [dbo].[charge];

    END 
GO