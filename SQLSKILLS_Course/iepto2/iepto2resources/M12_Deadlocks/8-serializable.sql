USE [DeadlockDemo];
GO
SET NOCOUNT ON

-- Change to serializable isolation
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
WHILE 1=1
BEGIN
-- Begin a transaction
BEGIN TRANSACTION

-- Perform existence check to acquire shared range shared locks
IF NOT EXISTS ( SELECT *
				FROM [TableA]
				WHERE [col1] = 105)
BEGIN
	--WAITFOR DELAY '00:00:00.050';
	INSERT INTO [TableA] ([col1], [col2], [col3], [col4])
	VALUES (105, 0, 0, '123');
END

ROLLBACK
END