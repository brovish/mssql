USE [Credit];
GO
IF OBJECT_ID('dbo.add_day_udf') > 0
BEGIN
DROP FUNCTION dbo.add_day_udf;
END
GO

CREATE FUNCTION dbo.add_day_udf(@charge_dt datetime)
RETURNS int
AS
BEGIN
     DECLARE @charge_dt_day int = DAY(@charge_dt)+1;

     RETURN(@charge_dt_day)
END
GO

USE master;
GO

--- Create a workload group forreport users
ALTER WORKLOAD GROUP [default]
WITH
(
     MAX_DOP = 1
) USING [default]
GO


ALTER RESOURCE GOVERNOR RECONFIGURE;
GO


