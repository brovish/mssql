
-- Chapter 7

-- the following statement shows the first scenario:
CREATE DATABASE Test
ON PRIMARY (NAME = Test_data,
FILENAME = 'C:\DATA\Test_data.mdf', SIZE=500MB),
FILEGROUP Test_fg CONTAINS MEMORY_OPTIMIZED_DATA
(NAME = Test_fg, FILENAME = 'C:\DATA\Test_fg')
LOG ON (NAME = Test_log, Filename='C:\DATA\Test_log.ldf', SIZE=500MB)
COLLATE Latin1_General_100_BIN2

-- the following code shows how you can add a memory-optimized data filegroup to an existing database:
CREATE DATABASE Test
ON PRIMARY (NAME = Test_data,
FILENAME = 'C:\DATA\Test_data.mdf', SIZE=500MB)
LOG ON (NAME = Test_log, Filename='C:\DATA\Test_log.ldf', SIZE=500MB)
COLLATE Latin1_General_100_BIN2
GO
ALTER DATABASE Test ADD FILEGROUP Test_fg CONTAINS MEMORY_OPTIMIZED_DATA
GO
ALTER DATABASE Test ADD FILE (NAME = Test_fg, FILENAME = N'C:\DATA\Test_fg')
TO FILEGROUP Test_fg
GO

-- you can try to create a table defining only MEMORY_OPTIMIZED, as shown next:
CREATE TABLE TransactionHistoryArchive (
TransactionID int NOT NULL,
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL,
TransactionDate datetime NOT NULL,
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL
) WITH (MEMORY_OPTIMIZED = ON)

-- first let’s drop the new table by using DROP TABLE in exactly the same way as with a disk-based table:
DROP TABLE TransactionHistoryArchive

-- then we can create the table:
CREATE TABLE TransactionHistoryArchive (
TransactionID int NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH
(BUCKET_COUNT = 100000),
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL,
TransactionDate datetime NOT NULL,
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL
) WITH (MEMORY_OPTIMIZED = ON)

-- we can have both hash and range indexes on the same table, as shown in the following example
CREATE TABLE TransactionHistoryArchive (
TransactionID int NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH
(BUCKET_COUNT = 100000),
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL,
TransactionDate datetime NOT NULL,
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL,
INDEX IX_ProductID NONCLUSTERED (ProductID)
) WITH (MEMORY_OPTIMIZED = ON)

-- however, the following will not work:
INSERT INTO TransactionHistoryArchive
SELECT * FROM AdventureWorks2012.Production.TransactionHistoryArchive

-- for the same reason, the following code joining two tables from two user databases will not work either:
SELECT * FROM TransactionHistoryArchive tha
JOIN AdventureWorks2012.Production.TransactionHistory ta
ON tha.TransactionID = ta.TransactionID

-- but you can copy this data in some other ways
SELECT * INTO #temp
FROM AdventureWorks2012.Production.TransactionHistoryArchive
GO
INSERT INTO TransactionHistoryArchive
SELECT * FROM #temp

-- the following example will create a disk-based table and join both a memory-optimized and a disk-based table:
CREATE TABLE TransactionHistory (
TransactionID int,
ProductID int)
GO
SELECT * FROM TransactionHistoryArchive tha
JOIN TransactionHistory ta ON tha.TransactionID = ta.TransactionID

-- you can get a list of the supported collations using code page 1252 by running the following query:
SELECT * FROM sys.fn_helpcollations()
WHERE COLLATIONPROPERTY(name, 'codepage') = 1252

-- you can get a list of such collations by running the following query:
SELECT * FROM sys.fn_helpcollations() WHERE name like '%BIN2'

-- drop the existing TransactionHistoryArchive table:
DROP TABLE TransactionHistoryArchive

-- now create the table again with a BUCKET_COUNT of 100,000:
CREATE TABLE TransactionHistoryArchive (
TransactionID int NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH
(BUCKET_COUNT = 100000),
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL,
TransactionDate datetime NOT NULL,
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL
) WITH (MEMORY_OPTIMIZED = ON)

-- you can use the sys.dm_db_xtp_hash_index_stats DMV to show statistics about hash indexes
SELECT * FROM sys.dm_db_xtp_hash_index_stats

-- insert the same data again by running the following statements:
DROP TABLE #temp
GO
SELECT * INTO #temp
FROM AdventureWorks2012.Production.TransactionHistoryArchive
GO
INSERT INTO TransactionHistoryArchive
SELECT * FROM #temp

-- change the previous code to create 65,536 buckets
DROP TABLE #temp
GO
SELECT TOP 65536 * INTO #temp
FROM AdventureWorks2012.Production.TransactionHistoryArchive
GO
INSERT INTO TransactionHistoryArchive
SELECT * FROM #temp

-- the examples in this section use the following table with both a hash and a range index
CREATE TABLE TransactionHistoryArchive (
TransactionID int NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH
(BUCKET_COUNT = 100000),
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL,
TransactionDate datetime NOT NULL,
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL,
INDEX IX_ProductID NONCLUSTERED (ProductID)
) WITH (MEMORY_OPTIMIZED = ON)

-- first, run the following query:
SELECT * FROM TransactionHistoryArchive
WHERE TransactionID = 8209

-- if you change the previous query to use an inequality predicate, as shown next
SELECT * FROM TransactionHistoryArchive
WHERE TransactionID > 8209

-- now let’s try a different query:
SELECT * FROM TransactionHistoryArchive
WHERE ProductID = 780

-- now let’s try an inequality operation on the same column.
SELECT * FROM TransactionHistoryArchive
WHERE ProductID < 780

-- the following query will use a Sort operation to sort the requested data, as shown in Figure 7-9.
SELECT * FROM TransactionHistoryArchive
ORDER BY TransactionID

-- running the following query will simply scan the range index without the need to additionally sort its data
SELECT * FROM TransactionHistoryArchive
ORDER BY ProductID

-- finally, let’s look at an example of a hash index with two columns
CREATE TABLE TransactionHistoryArchive (
TransactionID int NOT NULL,
ProductID int NOT NULL,
ReferenceOrderID int NOT NULL,
ReferenceOrderLineID int NOT NULL,
TransactionDate datetime NOT NULL,
TransactionType nchar(1) NOT NULL,
Quantity int NOT NULL,
ActualCost money NOT NULL,
ModifiedDate datetime NOT NULL,
CONSTRAINT PK_TransactionID_ProductID PRIMARY KEY NONCLUSTERED
HASH (TransactionID, ProductID) WITH (BUCKET_COUNT = 100000)
) WITH (MEMORY_OPTIMIZED = ON)

-- SQL Server will be able to use an Index Seek on PK_TransactionID_ProductID
SELECT * FROM TransactionHistoryArchive
WHERE TransactionID = 7173 AND ProductID = 398

-- but not in the following query, which will resort to an Index Scan:
SELECT * FROM TransactionHistoryArchive
WHERE TransactionID = 7173

-- let’s now create a natively compiled stored procedure
CREATE PROCEDURE test
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
LANGUAGE = 'us_english')
SELECT TransactionID, ProductID, ReferenceOrderID
FROM dbo.TransactionHistoryArchive
WHERE ProductID = 780
END

-- after creating the procedure, you can executing it by using this:
EXEC test

-- for example, running the following statement after the TransactionHistoryArchive is
-- created will get the output shown in Figure 7-13:
DBCC SHOW_STATISTICS(TransactionHistoryArchive, PK_TransactionID_ProductID)

-- to update the statistics, run the following UPDATE STATISTICS statement:
UPDATE STATISTICS TransactionHistoryArchive WITH FULLSCAN, NORECOMPUTE

-- it is interesting to note that the generated DLLs are not kept in the database but in the file system
SELECT name, description FROM sys.dm_os_loaded_modules
where description = 'XTP Native DLL'

-- run the following to test it:
DROP PROCEDURE test
DROP TABLE TransactionHistoryArchive

-- in this case, we are testing the following stored procedures on a copy of AdventureWorks2012:
CREATE PROCEDURE test1
AS
SELECT * FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE ProductID = 870
GO
CREATE PROCEDURE test2
AS
SELECT ProductID, SalesOrderID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID, SalesOrderID

-- execute the procedures multiple times:
EXEC test1
GO
EXEC test2
GO

