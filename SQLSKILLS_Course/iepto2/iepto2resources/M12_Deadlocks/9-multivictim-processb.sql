USE [DeadlockDemo];
GO

BEGIN TRANSACTION

-- Lock TableB
UPDATE [TableB]
SET [col2] = '123';

-- Run two select processes

-- Now trigger deadlock
UPDATE [TableA]
SET [col2] = [col2]+4;


ROLLBACK