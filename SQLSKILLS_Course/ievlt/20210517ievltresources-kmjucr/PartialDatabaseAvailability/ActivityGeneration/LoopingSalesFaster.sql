:ON ERROR IGNORE
go

USE SalesDB
go

SET NOCOUNT ON
go

WHILE 1=1
BEGIN
	:r AddNewSale.sql  
	WAITFOR DELAY '00:00:00.010'
END
go