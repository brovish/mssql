-- https://github.com/microsoft/sqlworkshops-sql2019workshop/blob/master/sql2019workshop/02_IntelligentPerformance.md
-- as table variable does have stats in versions prior to 2019. In 2019, we get deferred compilation for table vars and
--that gives the optimizer the stats for the table var, for e.g., to select a efficient JOIN operator.

-- check the compatibility_level of dbs. wwi is was built against SS2016 and has level 130. SS2019 has compat. level 150
use master;
go  

SELECT compatibility_level, is_query_store_on, *
from sys.databases

use WideWorldImporters;
go

-- Step 1: Create the stored procedure to use a table variable. Pull in pages from Sales.Invoices to make all comparison fair based on a warm buffer pool cache
USE WideWorldImporters
GO

CREATE or ALTER PROCEDURE [Sales].[CustomerProfits]
AS
BEGIN
-- Declare the table variable
DECLARE @ilines TABLE
(	[InvoiceLineID] [int] NOT NULL primary key,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
)

-- Insert all the rows from InvoiceLines into the table variable
INSERT INTO @ilines SELECT * FROM Sales.InvoiceLines

-- Find my total profile by customer
SELECT TOP 1 COUNT(i.CustomerID) as customer_count, SUM(il.LineProfit) as total_profit
FROM Sales.Invoices as i
INNER JOIN @ilines as il
ON i.InvoiceID = il.InvoiceID
GROUP By i.CustomerID
END
GO

set statistics io on
set statistics time on
go

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO

-- Pull these pages into cache to make the comparison fair based on a warm buffer pool cache
--RS: to make comparisons fair, isn't it better to clean the buffer pool and then warm the cache?
--And isn't it better to run the actual query/sp to warm the cache?
SELECT COUNT(*) FROM Sales.Invoices
GO

-- Step 2: Run the stored procedure under dbcompat = 130
USE master
GO
ALTER DATABASE wideworldimporters SET compatibility_level = 130
GO
USE WideWorldImporters
GO
SET NOCOUNT ON
GO
EXEC [Sales].[CustomerProfits]--it took 20 secs
GO 25
SET NOCOUNT OFF
GO

set statistics io on
set statistics time on
go

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO

-- Pull these pages into cache to make the comparison fair based on a warm buffer pool cache
--RS: to make comparisons fair, isn't it better to clean the buffer pool and then warm the cache?
--And isn't it better to run the actual query/sp to warm the cache?
SELECT COUNT(*) FROM Sales.Invoices
GO
-- Step 3: Run the same code under dbcompat = 150
USE master
GO
ALTER DATABASE wideworldimporters SET compatibility_level = 150
GO
USE WideWorldImporters
GO
SET NOCOUNT ON
GO
EXEC [Sales].[CustomerProfits] --it took 8 secs
GO 25
SET NOCOUNT OFF
GO

-- Step 4: Restore dbcompat for WideWorldImporters
USE master
GO
ALTER DATABASE wideworldimporters SET compatibility_level = 130
GO

