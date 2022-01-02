DECLARE @MovingTarget datetime = GETDATE();
DECLARE @PowerItUp bigint;

WHILE DATEADD(second,2000, @MovingTarget)
	>GETDATE()
BEGIN
	SET @PowerItUp=POWER(10,5);
END

 