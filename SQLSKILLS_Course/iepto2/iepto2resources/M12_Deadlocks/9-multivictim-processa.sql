USE [DeadlockDemo];
GO
-- Run this in two separate windows
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION

SELECT * FROM [TableA];
-- Change window and run this again in second window


-- Run this after running the start of ProcessB
SELECT * FROM [TableB];

-- Now run final update in ProcessB to trigger deadlock