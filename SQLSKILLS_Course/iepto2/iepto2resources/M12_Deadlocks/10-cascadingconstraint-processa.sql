USE [DeadlockDemo];
GO

-- Run in connection 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET NOCOUNT ON;
WHILE   1 = 1
BEGIN
        UPDATE  dbo.Parent
        SET     parent_id = 0 - parent_id;
END;
GO
