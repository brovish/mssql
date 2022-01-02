USE [DeadlockDemo];
GO

-- Run in connection 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET NOCOUNT ON;
WHILE   1 = 1
BEGIN
        UPDATE  dbo.Child1
        SET     parent_id = 0 - parent_id;
END;
GO
