USE [DeadlockDemo];
GO

BEGIN TRANSACTION

UPDATE [TableB]
SET [col2] = 'xyz';

UPDATE [TableA]
SET [col2] = [col2]+4;

ROLLBACK