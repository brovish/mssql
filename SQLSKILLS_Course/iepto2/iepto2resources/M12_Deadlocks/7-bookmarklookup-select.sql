USE [DeadlockDemo];
GO
SET NOCOUNT ON
WHILE (1=1) 
BEGIN
    EXEC [BookmarkLookupSelect] 4;
END
GO