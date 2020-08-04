-- AD215 Lab Solution

-- Exercise 1

DBCC CHECKDB ('WarehouseManagement');
GO

DBCC CHECKDB ('WarehouseManagement') WITH EXTENDED_LOGICAL_CHECKS, NO_INFOMSGS;
GO


-- Exercise 2

RESTORE HEADERONLY FROM DISK = 'C:\Labs\AD215\Starter\IntentionallyBadDB.bak';
GO
RESTORE FILELISTONLY FROM DISK = 'C:\Labs\AD215\Starter\IntentionallyBadDB.bak';
GO


RESTORE DATABASE IntentionallyBadDB
FROM DISK = 'C:\Labs\AD215\Starter\IntentionallyBadDB.bak'
WITH MOVE 'IntentionallyBadDB_log' TO 'C:\SQLLogs\IntentionallyBadDB_log.ldf';
GO

DBCC CHECKDB ('IntentionallyBadDB');
GO

ALTER DATABASE IntentionallyBadDB SET SINGLE_USER;
GO

DBCC CHECKDB ('IntentionallyBadDB', REPAIR_ALLOW_DATA_LOSS);
GO

DBCC CHECKDB ('IntentionallyBadDB');
GO

ALTER DATABASE IntentionallyBadDB SET MULTI_USER;
GO
