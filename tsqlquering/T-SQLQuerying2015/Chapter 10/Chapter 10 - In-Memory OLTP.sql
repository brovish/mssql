---------------------------------------------------------------------
-- T-SQL Querying (Microsoft Press, 2015)
-- Chapter 10 - In-Memory OLTP
-- © Kevin Farlee
---------------------------------------------------------------------

SET NOCOUNT ON;

---------------------------------------------------------------------
-- In-Memory OLTP
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Creating Memory optimized tables and indexes
---------------------------------------------------------------------

-- LISTING 10-1 Creating a MEMORY_OPTIMIZED_DATA filegroup and container

ALTER DATABASE AdventureWorks2014 
ADD FILEGROUP AdventureWorks2014_mod CONTAINS MEMORY_OPTIMIZED_DATA;
GO
-- Note that you can create multiple containers by simply adding more files here.
ALTER DATABASE AdventureWorks2014 ADD FILE 
(NAME='AdventureWorks2014_mod',
 FILENAME='Q:\MOD_DATA\AdventureWorks2014_mod') 
 TO FILEGROUP AdventureWorks2014_mod;               

-- LISTING 10-2 Creating a memory-optimized table

USE AdventureWorks2014;
GO

CREATE TABLE Sales.ShoppingCartItem_inmem
(
  ShoppingCartItemID int IDENTITY(1,1) NOT NULL,
  ShoppingCartID nvarchar(50) NOT NULL,
  Quantity int NOT NULL CONSTRAINT IMDF_ShoppingCartItem_Quantity  DEFAULT ((1)),
  ProductID int NOT NULL,
  DateCreated datetime2(7) NOT NULL
    CONSTRAINT IMDF_ShoppingCartItem_DateCreated  DEFAULT (sysdatetime()),
  ModifiedDate datetime2(7) NOT NULL
    CONSTRAINT IMDF_ShoppingCartItem_ModifiedDate  DEFAULT (sysdatetime()),
  CONSTRAINT IMPK_ShoppingCartItem_ShoppingCartItemID PRIMARY KEY NONCLUSTERED
    HASH (ShoppingCartItemID) WITH ( BUCKET_COUNT = 1048576),
  INDEX IX_CartDate NONCLUSTERED (DateCreated ASC),
  INDEX IX_ProductID NONCLUSTERED HASH (ProductID) WITH ( BUCKET_COUNT = 1048576)
) WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY );

GO

-- Insert the data from the original Sales.ShoppingCartItem table
-- to the new memory-optimized table

SET IDENTITY_INSERT Sales.ShoppingCartItem_inmem ON;

INSERT INTO Sales.ShoppingCartItem_inmem
    (ShoppingCartItemID, ShoppingCartID, Quantity, ProductID, DateCreated, ModifiedDate)
  SELECT ShoppingCartItemID, ShoppingCartID, Quantity, ProductID, DateCreated, ModifiedDate
  FROM Sales.ShoppingCartItem;

SET IDENTITY_INSERT Sales.ShoppingCartItem_inmem OFF;

---------------------------------------------------------------------
-- Nonclustered index behavior
---------------------------------------------------------------------

-- Index specification fragment

INDEX IX_CartDate NONCLUSTERED (DateCreated ASC)

-- Query with range predicate and ORDER_BY that matches the order of the index:

SELECT DateCreated 
FROM Sales.ShoppingCartItem_inmem 
WHERE DateCreated BETWEEN '20131101' AND '20131201' 
ORDER BY DateCreated ASC;

-- Query with opposite sort order causes extra sort operator in the plan

SELECT DateCreated 
FROM Sales.ShoppingCartItem_inmem 
WHERE DateCreated BETWEEN '20131101' AND '20131201' 
ORDER BY DateCreated DESC;

---------------------------------------------------------------------
-- Hash index behavior
---------------------------------------------------------------------

-- Querying a disk-based table doesn't require separate sort operator

SELECT ProductID, Name FROM Production.Product ORDER BY ProductID;

-- Querying a Memory-Optimized table with only a Hash index adds a sort operator

SELECT ProductID, Name FROM Production.Product_inmem ORDER BY ProductID;

-- LISTING 10-3 Tables with different bucket counts

-- The first table has a bucket count of 8

CREATE TABLE dbo.tTable
(
     c INT NOT NULL,
     PRIMARY KEY NONCLUSTERED HASH (c) WITH ( BUCKET_COUNT = 8)
)
WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY ); 

-- The second table is identical except it has a bucket count of 2,000,000

CREATE TABLE dbo.tTable2
(
     c int NOT NULL,
     PRIMARY KEY NONCLUSTERED HASH (c) WITH ( BUCKET_COUNT = 2000000)
)
WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY ); 
GO

SET NOCOUNT ON
SET STATISTICS TIME ON
GO

CREATE PROCEDURE Fill_tTable
@iterations INT
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH
  (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
   LANGUAGE = N'us_english');
DECLARE @i INT = 0;
WHILE (@i < @iterations)
BEGIN
  INSERT INTO dbo.tTable (C) VALUES (@i);
  SET @i += 1;
END;
END;
GO


CREATE PROCEDURE Fill_tTable2
@iterations INT
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER AS
BEGIN ATOMIC WITH
  (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
   LANGUAGE = N'us_english')
  DECLARE @i INT = 0;
  WHILE (@i < @iterations)
  BEGIN
    INSERT INTO dbo.tTable2 (C) VALUES (@i);
    SET @i += 1;
  END;
END;
GO

EXEC Fill_tTable 100000;

EXEC Fill_tTable2 100000;
GO

SET STATISTICS TIME OFF
GO

-- Querying the health of a hash index

SELECT 
   object_name(hs.object_id) AS [object name], 
   hs.total_bucket_count,
   hs.empty_bucket_count,
   floor((cast(empty_bucket_count as float)/total_bucket_count) * 100) AS[empty_bucket_percent],
   hs.avg_chain_length, 
   hs.max_chain_length
FROM sys.dm_db_xtp_hash_index_stats AS hs 
   JOIN sys.indexes AS i 
   ON hs.object_id=i.object_id AND hs.index_id=i.index_id;

-- LISTING 10-4 Illustration of the results of queries that specify only leading columns

CREATE TABLE dbo.IndexExample (
ID  INT NOT NULL IDENTITY(1,1) PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=1024),
C1 INT NOT NULL,
C2 INT NOT NULL,
C3 INT NOT NULL,
C4 INT NOT NULL,

-- Nonclustered HASH index for columns C1 & C2
INDEX IX_HashExample NONCLUSTERED HASH 
(
    C1, C2
)WITH ( BUCKET_COUNT = 1048576),

--Nonclustered (BW-Tree) index for columns C3 & C4
INDEX IX_NonClusteredExample NONCLUSTERED 
(
    C3, C4
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA );

GO
INSERT INTO dbo.IndexExample (C1, C2, C3, C4) VALUES (1,1,1,1);
INSERT INTO dbo.IndexExample (C1, C2, C3, C4) VALUES (2,2,2,2);

--The first query uses the leading column of the hash index
SELECT C1, C2 FROM dbo.IndexExample WHERE C1 = 1;

--The second query uses the leading column of the BW-Tree index
SELECT C1, C2 FROM dbo.IndexExample WHERE c3 = 1;

-- LISTING 10-5 Example of the optimizer choosing between indexes based on query attributes

CREATE TABLE dbo.tTable3
(
      C1 int NOT NULL,
      C2 int NOT NULL,
      C3 int NOT NULL,
      C4 int NOT NULL,
      PRIMARY KEY NONCLUSTERED HASH (C4)
         WITH ( BUCKET_COUNT = 2097152),
      INDEX HASH_IDX NONCLUSTERED HASH (C1, C2, C3)
         WITH ( BUCKET_COUNT = 2097152),
      INDEX NC_IDX NONCLUSTERED (C1, C2, C3)
) WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA );

GO

INSERT INTO dbo.tTable3 VALUES(1,1,1,1),(1,1,1,2),(1,1,1,3);
GO


-- Exact key lookup, will be satisfied by the hash index
SELECT C1, C2, C3, C4 FROM dbo.tTable3 WHERE C1 = 1 AND C2=1 AND C3=1;

-- Query with a range predicate will be satisfied by the BW-Tree index
SELECT C1, C2, C3, C4 FROM dbo.tTable3 WHERE C1 = 1 AND C2=1 AND C3 BETWEEN 0 AND 2;

-- Query on leading columns, will be satisfied by the BW-Tree index.
SELECT C1, C2, C3, C4 FROM dbo.tTable3 WHERE C1 = 1 AND C2=1;

---------------------------------------------------------------------
-- Deadlocks and Blocking
---------------------------------------------------------------------

-- TABLE 10-2 Example of a deadlock with traditional tables

--Setup the table
USE AdventureWorks2014;
GO
IF (OBJECT_ID('dbo.T1') IS NOT NULL)
  DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  C1 INT NOT NULL PRIMARY KEY,
  C2 INT NOT NULL
); 

GO
INSERT INTO dbo.T1(C1,C2) VALUES (1,1),(2,1);
GO

-- Transaction 1

--Step 1
BEGIN TRANSACTION;

--Step 3
UPDATE dbo.T1 SET C2 = 2
WHERE C1 = 2;

--Step 5
SELECT C2 FROM dbo.T1
WHERE C1 = 1;

--Step 7
COMMIT;

--Transaction 2

--Step 2
BEGIN TRANSACTION;

--Step 4
UPDATE T1 SET C2 = 3 
WHERE C1 = 1;

--Step 6
SELECT C2 FROM T1
WHERE C1 = 2;

--Step 8
COMMIT;

-- TABLE 10-3 Example of a deadlock with memory-optimized tables

--Setup the table
USE AdventureWorks2014;
GO

IF (OBJECT_ID(N'dbo.T1') IS NOT NULL)
  DROP TABLE dbo.T1;


CREATE TABLE dbo.T1
(
  C1 INT NOT NULL 
    PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1024),
  C2 INT NOT NULL
) 
WITH (MEMORY_OPTIMIZED = ON);

GO
INSERT INTO dbo.T1(C1,C2) VALUES (1,1),(2,1);
GO

-- Transaction 1

--Step 1
BEGIN TRANSACTION;

--Step 3
UPDATE dbo.T1 WITH (SNAPSHOT)
  SET C2 = 2 
WHERE C1 = 2;

--Step 5
SELECT C2 FROM dbo.T1 WITH (SNAPSHOT) 
WHERE C1 = 1;

--Step 7
COMMIT;

-- Transaction 2

--Step 2
BEGIN TRANSACTION;

--Step 4
UPDATE dbo.T1 WITH (SNAPSHOT)
  SET C2 = 3 
WHERE C1 = 1;

--Step 6
SELECT C2 FROM dbo.T1 WITH (SNAPSHOT) 
WHERE C1 = 2;

--Step 8
COMMIT;


---------------------------------------------------------------------
-- Commit Validation Errors
---------------------------------------------------------------------

-- TABLE 10-4 Example of blocking vs. commit error in a memory-optimized table

--Setup the table
USE AdventureWorks2014;
GO
IF (OBJECT_ID('dbo.T1') IS NOT NULL)
  DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  C1 INT NOT NULL 
    PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1024),
  C2 INT NOT NULL
) 
WITH (MEMORY_OPTIMIZED = ON);

GO
INSERT INTO dbo.T1(C1,C2) VALUES (1,1);
GO

-- Transaction 1

--Step 1
BEGIN TRANSACTION 

--Step 3
UPDATE dbo.T1 WITH (SNAPSHOT)
  SET C2 = 2 
WHERE C1 = 1;

--Step 5
COMMIT;

--Transaction 2

--Step 2
BEGIN TRANSACTION;

--step 4
UPDATE dbo.T1 WITH (SNAPSHOT)
  SET C2 = 3 
WHERE C1 = 1;

--Step 6
COMMIT;


-- TABLE 10-5 Example of blocking vs. commit error in a traditional table

--Setup the table
USE AdventureWorks2014;
GO

IF (OBJECT_ID('dbo.T1') IS NOT NULL)
  DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  C1 INT NOT NULL PRIMARY KEY,
  C2 INT NOT NULL
); 

GO
INSERT INTO dbo.T1(C1,C2) VALUES (1,1);
GO

--Transaction 1

--Step 1
BEGIN TRANSACTION; 

--Step 3
UPDATE dbo.T1
  SET C2 = 2 
WHERE C1 = 1;

--Step 5
COMMIT;

--Transaction 2

--Step 2
BEGIN TRANSACTION;

--Step 4
UPDATE dbo.T1
  SET C2 = 3 
WHERE C1 = 1;

--Step 6
COMMIT;

---------------------------------------------------------------------
-- Retry logic for validation failures
---------------------------------------------------------------------

-- LISTING 10-6 Retry logic for validation failures

-- number of retries – tune based on the workload
  DECLARE @retry INT = 10;

  WHILE (@retry > 0)
  BEGIN
    BEGIN TRY

      -- exec usp_my_native_proc @param1, @param2, ...

      --       or

      -- BEGIN TRANSACTION
      --   ...
      -- COMMIT TRANSACTION

      SET @retry = 0;
    END TRY
    BEGIN CATCH
      SET @retry -= 1;
  
      IF (@retry > 0 AND error_number() in (41302, 41305, 41325, 41301, 1205))
      BEGIN
        -- These errors cannot be recovered and continued from.  The transaction must
        -- be rolled back and completely retried. 
        -- The native proc will simply rollback when an error is thrown, so skip the
        -- rollback in that case.

        IF XACT_STATE() = -1
          ROLLBACK TRANSACTION;

        -- use a delay if there is a high rate of write conflicts (41302)
        -- length of delay should depend on the typical duration of conflicting 
        -- transactions
        -- WAITFOR DELAY '00:00:00.001';
      END
      ELSE
      BEGIN
        -- insert custom error handling for other error conditions here

        -- throw if this is not a qualifying error condition
        THROW;
      END;
    END CATCH;
  END;

---------------------------------------------------------------------
-- Table Valued Parameters
---------------------------------------------------------------------

-- LISTING 10-7 Memory-optimized table type

CREATE TYPE Sales.SalesOrderDetailType_inmem AS TABLE(
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    LocalID INT NOT NULL,
    INDEX IX_ProductID NONCLUSTERED HASH 
(
    ProductID
) WITH ( BUCKET_COUNT = 8),
    INDEX [IX_SpecialOfferID] NONCLUSTERED HASH 
(
    SpecialOfferID
) WITH ( BUCKET_COUNT = 8)
)
WITH ( MEMORY_OPTIMIZED = ON );

-- LISTING 10-8 Using a table-valued parameter with a native procedure

---------------------------------------------------------------------
-- Table Valued Parameters
---------------------------------------------------------------------
-- Delete the old objects if they exist

IF (OBJECT_ID('Sales.usp_InsertSalesOrder_inmem') IS NOT NULL)
  DROP PROCEDURE Sales.usp_InsertSalesOrder_inmem;

IF (TYPE_ID('Sales.SalesOrderDetailType_inmem') IS NOT NULL)
  DROP TYPE Sales.SalesOrderDetailType_inmem;

-- Memory Optimized Table Type
CREATE TYPE Sales.SalesOrderDetailType_inmem AS TABLE(
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    LocalID INT NOT NULL,
    INDEX IX_ProductID NONCLUSTERED HASH 
(
    ProductID
) WITH ( BUCKET_COUNT = 8),
    INDEX [IX_SpecialOfferID] NONCLUSTERED HASH 
(
    SpecialOfferID
) WITH ( BUCKET_COUNT = 8)
)
WITH ( MEMORY_OPTIMIZED = ON );

GO

--Using a table valued parameter with a native proc

CREATE PROCEDURE Sales.usp_InsertSalesOrder_inmem
  @SalesOrderID INT OUTPUT,
  @DueDate DATETIME2(7) NOT NULL,
  @CustomerID INT NOT NULL,
  @BillToAddressID INT NOT NULL,
  @ShipToAddressID INT NOT NULL,
  @ShipMethodID INT NOT NULL,
  @SalesOrderDetails Sales.SalesOrderDetailType_inmem READONLY,
  @Status TINYINT NOT NULL = 1,
  @OnlineOrderFlag BIT NOT NULL = 1,
  @PurchaseOrderNumber NVARCHAR(25) = NULL,
  @AccountNumber NVARCHAR(15) = NULL,
  @SalesPersonID INT NOT NULL = -1,
  @TerritoryID INT = NULL,
  @CreditCardID INT = NULL,
  @CreditCardApprovalCode VARCHAR(15) = NULL,
  @CurrencyRateID INT = NULL,
  @Comment NVARCHAR(128) = NULL
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH
  (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
  LANGUAGE = N'us_english')
    DECLARE @OrderDate DATETIME2 NOT NULL = sysdatetime();
    DECLARE @SubTotal MONEY NOT NULL = 0;
    SELECT @SubTotal = ISNULL(SUM(p.ListPrice * (1 - so.DiscountPct)),0)
    FROM @SalesOrderDetails od
      JOIN Sales.SpecialOffer_inmem so ON od.SpecialOfferID=so.SpecialOfferID
      JOIN Production.Product_inmem p ON od.ProductID=p.ProductID;

    INSERT INTO Sales.SalesOrderHeader_inmem
    ( DueDate,
      Status,
      OnlineOrderFlag,
      PurchaseOrderNumber,
      AccountNumber,
      CustomerID,
      SalesPersonID,
      TerritoryID,
      BillToAddressID,
      ShipToAddressID,
      ShipMethodID,
      CreditCardID,
      CreditCardApprovalCode,
      CurrencyRateID,
      Comment,
      OrderDate,
      SubTotal,
      ModifiedDate)
    VALUES
    (    
      @DueDate,
      @Status,
      @OnlineOrderFlag,
      @PurchaseOrderNumber,
      @AccountNumber,
      @CustomerID,
      @SalesPersonID,
      @TerritoryID,
      @BillToAddressID,
      @ShipToAddressID,
      @ShipMethodID,
      @CreditCardID,
      @CreditCardApprovalCode,
      @CurrencyRateID,
      @Comment,
      @OrderDate,
      @SubTotal,
      @OrderDate
    );

    SET @SalesOrderID = SCOPE_IDENTITY();

    INSERT INTO Sales.SalesOrderDetail_inmem
    (
      SalesOrderID,
      OrderQty,
      ProductID,
      SpecialOfferID,
      UnitPrice,
      UnitPriceDiscount,
      ModifiedDate
    )
    SELECT 
      @SalesOrderID,
      od.OrderQty,
      od.ProductID,
      od.SpecialOfferID,
      p.ListPrice,
      p.ListPrice * so.DiscountPct,
      @OrderDate
    FROM @SalesOrderDetails od 
    JOIN Sales.SpecialOffer_inmem so 
    ON od.SpecialOfferID=so.SpecialOfferID
    JOIN Production.Product_inmem p ON od.ProductID=p.ProductID;

END;
GO
