USE Credit;
GO

SET NOCOUNT ON;
GO

WHILE 1 = 1 
    BEGIN

        UPDATE  [dbo].[charge]
        SET     [charge].[charge_dt] = GETDATE();

    END 
GO