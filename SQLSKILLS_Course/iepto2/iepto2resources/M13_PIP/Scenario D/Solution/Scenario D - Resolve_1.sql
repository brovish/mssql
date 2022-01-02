USE [Credit];
GO

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET NOCOUNT ON

WHILE 1 = 1 
    BEGIN

        BEGIN TRAN

		UPDATE  [dbo].[member]
        SET     [member].[lastname] = 'Zuckerton'
        WHERE   [member].[member_no] = 104;

        UPDATE  [dbo].[payment]
        SET     [payment].[payment_amt] = 4193.00
        WHERE   [payment].[member_no] = 104;

        COMMIT TRAN

    END
GO    