USE [Credit]
GO

SET NOCOUNT ON;
GO

IF OBJECT_ID('charge_jan')> 0
BEGIN
DROP TABLE charge_jan;
END
GO

IF OBJECT_ID('charge_feb')> 0
BEGIN
DROP TABLE charge_feb;
END
GO


SELECT *
INTO [charge_jan]
FROM [dbo].[charge];
GO

SELECT *
INTO [charge_feb]
FROM [dbo].[charge];
GO

UPDATE [charge_jan]
SET charge_dt = '1/31/2013';
GO


UPDATE [charge_feb]
SET charge_dt = '2/28/2013';
GO


IF OBJECT_ID('charge_view')> 0
BEGIN
DROP VIEW charge_view;
END
GO

CREATE VIEW charge_view
AS

SELECT *
FROM [charge_jan]
UNION ALL
SELECT *
FROM [charge_feb]
GO



IF OBJECT_ID('charge_by_date')> 0
BEGIN
DROP PROCEDURE charge_by_date;
END
GO

CREATE PROCEDURE charge_by_date
@charge_dt datetime
AS

SELECT charge_no
FROM dbo.charge_view
WHERE charge_dt = @charge_dt
GO
