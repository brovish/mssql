USE [Credit]
GO

IF OBJECT_ID('charge_demo')>0
BEGIN
	DROP TABLE [dbo].[charge_demo]
END;
GO

-- Create our demo
CREATE TABLE [dbo].[charge_demo]
(
 [charge_no] [dbo].[numeric_id] NOT NULL
                                PRIMARY KEY CLUSTERED,
 [member_no] [dbo].[numeric_id] NOT NULL,
 [provider_no] [dbo].[numeric_id] NOT NULL,
 [category_no] [dbo].[numeric_id] NOT NULL,
 [charge_dt] [datetime] NOT NULL,
 [charge_amt] [money] NOT NULL,
 [statement_no] [dbo].[numeric_id] NOT NULL,
 [charge_code] [dbo].[status_code] NOT NULL,
 [insert_dt] [datetime] NULL
);
GO

-- Create our trigger to modify insert_dt
CREATE TRIGGER [trg_i_charge_demo] ON [dbo].[charge_demo]
    AFTER INSERT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    SET NOCOUNT ON;

    UPDATE  [dbo].[charge_demo]
    SET     [insert_dt] = GETDATE()
    FROM    [dbo].[charge_demo] AS [c]
    INNER JOIN inserted AS [i]
            ON [c].[charge_no] = [i].[charge_no];

END
GO
