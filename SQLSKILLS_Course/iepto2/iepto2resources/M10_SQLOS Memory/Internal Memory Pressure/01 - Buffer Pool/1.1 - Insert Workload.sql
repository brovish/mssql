USE [LazyWrites]
GO
SET NOCOUNT ON
WHILE 1=1
BEGIN
	BEGIN TRANSACTION
	DECLARE @Loop INT = 0
	WHILE @Loop < 1000
	BEGIN
	INSERT INTO dbo.InsertTable DEFAULT VALUES;
	SET @Loop = @Loop + 1;
	END
	COMMIT
END
