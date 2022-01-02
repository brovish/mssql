USE [Credit];
GO

SET NOCOUNT ON;
GO

SET STATISTICS IO ON;
GO

-- Show Execution Plans
DBCC FREEPROCCACHE;
GO

EXEC [dbo].[charge_by_date] '1/31/2013';
GO


EXEC [dbo].[charge_by_date] '2/28/2013';
GO
