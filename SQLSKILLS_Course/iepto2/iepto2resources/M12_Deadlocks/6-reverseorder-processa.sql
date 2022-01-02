USE [DeadlockDemo];
GO

BEGIN TRANSACTION

UPDATE [TableA]
SET [col2] = [col2]+4;

-- Run other window

-- Trigger deadlock
UPDATE [TableB]
SET [col2] = '123';


ROLLBACK

