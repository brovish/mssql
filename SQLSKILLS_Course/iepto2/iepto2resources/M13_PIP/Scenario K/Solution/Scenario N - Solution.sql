USE [Credit];
GO

SET NOCOUNT ON;
GO



ALTER TABLE [dbo].[charge_jan]
ADD CONSTRAINT charge_jan_chk CHECK
(charge_dt >= '1/1/2013' AND charge_dt < '2/1/2013');
GO

ALTER TABLE [dbo].[charge_feb]
ADD CONSTRAINT charge_feb_chk CHECK
(charge_dt >= '2/1/2013' AND charge_dt < '3/1/2013');
GO

ALTER PROCEDURE [dbo].[charge_by_date]
@charge_dt datetime
AS

SELECT charge_no
FROM dbo.charge_view
WHERE charge_dt = @charge_dt
OPTION (RECOMPILE);

GO


-- Show Execution Plans
DBCC FREEPROCCACHE;
GO


SET STATISTICS IO ON;
GO

EXEC [dbo].[charge_by_date] '1/31/2013';
GO


EXEC [dbo].[charge_by_date] '2/28/2013';
GO
