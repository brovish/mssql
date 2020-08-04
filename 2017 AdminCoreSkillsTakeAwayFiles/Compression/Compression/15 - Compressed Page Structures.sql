USE Compression;
GO

CREATE TABLE dbo.SalesOrderDetail
(
        SalesOrderID int NOT NULL,
        SalesOrderDetailID int NOT NULL,
        CarrierTrackingNumber nvarchar(25) NULL,
        OrderQty smallint NOT NULL,
        ProductID int NOT NULL,
        SpecialOfferID int NOT NULL,
        UnitPrice money NOT NULL,
        UnitPriceDiscount money NOT NULL,
    CONSTRAINT PK_dbo_SalesOrderDetail
        PRIMARY KEY (SalesOrderID, SalesOrderDetailID)
);
GO

INSERT dbo.SalesOrderDetail
    (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
     OrderQty, ProductID, SpecialOfferID, UnitPrice,
     UnitPriceDiscount)
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
       OrderQty, ProductID, SpecialOfferID, UnitPrice,
       UnitPriceDiscount
FROM AdventureWorks.Sales.SalesOrderDetail;
GO

-- Let's the check the existing space for this table
EXEC sp_spaceused N'dbo.SalesOrderDetail';
GO

-- Let's select the first 3 rows in the table (it does have a clustered index)
SELECT TOP(3) *
FROM dbo.SalesOrderDetail
ORDER BY SalesOrderID, SalesOrderDetailID;
GO

-- So time to look at what's on the data page
DBCC TRACEON (3604);

DECLARE @DatabaseID int = DB_ID();
DECLARE @PageToDisplay int =
    (SELECT TOP(1) allocated_page_page_id
     FROM sys.dm_db_database_page_allocations
         (@DatabaseID, OBJECT_ID(N'dbo.SalesOrderDetail'), 1, NULL, 'DETAILED')
     WHERE page_type_desc = N'DATA_PAGE'
     AND previous_page_page_id IS NULL);

DBCC PAGE (@DatabaseID, 1, @PageToDisplay, 1);
GO

-- 3 core sections. First is header
-- Of interest: m_type = 1 says this is a data page
--              m_level = 0 is the index level and in this case the leaf level
--              pminlen = 38 is the number of fixed bytes per row
--              m-slotCnt = 114 shows the number of rows (slots) per page
--              m_freeCnt = 2 indicates that there are only 2 free slots on the page

-- Last section is the slot array (stored in reverse order) - says where the rows are

-- Middle section is the data
-- Each byte is 2 hex digits with LSB first. 
-- First row of first slot (ie slot 0) has 69 bytes
-- Note same starting marker in each row
-- First 38 bytes are the fixed data region

-- If we convert the SalesOrderID and the ProductID to hex:

SELECT sys.fn_varbintohexstr(43659), sys.fn_varbintohexstr(776);
GO

-- Values are 0x0000aa8b and 0x00000308

-- You can see them in the first slot:

DBCC TRACEON (3604);

DECLARE @DatabaseID int = DB_ID();
DECLARE @PageToDisplay int =
    (SELECT TOP(1) allocated_page_page_id
     FROM sys.dm_db_database_page_allocations
         (@DatabaseID, OBJECT_ID(N'dbo.SalesOrderDetail'), 1, NULL, 'DETAILED')
     WHERE page_type_desc = N'DATA_PAGE'
     AND previous_page_page_id IS NULL);

DBCC PAGE (@DatabaseID, 1, @PageToDisplay, 1);
GO

-- Also note the way that the nvarchar tracking number 4911-403C-98 is stored

-- Now let's apply row compression
ALTER TABLE dbo.SalesOrderDetail
    REBUILD WITH (DATA_COMPRESSION = ROW);
GO

EXEC sp_spaceused N'dbo.SalesOrderDetail';
GO

-- Table is now 54% of original size

-- Check page contents again
DECLARE @DatabaseID int = DB_ID();
DECLARE @PageToDisplay int =
    (SELECT TOP(1) allocated_page_page_id
     FROM sys.dm_db_database_page_allocations
         (@DatabaseID, OBJECT_ID(N'dbo.SalesOrderDetail'), 1, NULL, 'DETAILED')
     WHERE page_type_desc = N'DATA_PAGE'
     AND previous_page_page_id IS NULL);

DBCC PAGE (@DatabaseID, 1, @PageToDisplay, 1);
GO

-- Header is similar except:
-- pminlen is now 6 (number of fixed data bytes)
-- m_slotCnt is now 214 (rows per page)
-- m_freeCnt is now 26 (free slots per page)

-- Slot array at the end is similar but more entries

-- But data has changed significantly
-- Now a series of compressed data array entries as values stored in shorter locations
-- Also note change in how string is stored
-- Very little page change but way more rows

-- So now page compression
ALTER TABLE dbo.SalesOrderDetail
    REBUILD WITH (DATA_COMPRESSION = PAGE);
GO

EXEC sp_spaceused N'dbo.SalesOrderDetail';
GO

-- Now 31% of original size (ie: 69% reduction in space usage)

-- And note page contents:
DECLARE @DatabaseID int = DB_ID();
DECLARE @PageToDisplay int = 
    (SELECT TOP(1) allocated_page_page_id 
     FROM sys.dm_db_database_page_allocations
          (@DatabaseID, OBJECT_ID(N'dbo.SalesOrderDetail'), 1, NULL, 'DETAILED')
     WHERE page_type_desc = N'DATA_PAGE'
     AND previous_page_page_id IS NULL);

DBCC PAGE (@DatabaseID, 1, @PageToDisplay, 1);
GO

-- Again page header and slot array are similar except:
-- m_slotCnt is now 479 (slots per page)
-- m_freeCnt = 13 (free slots per page)

-- But scroll down and note the format of the data in slot 0
-- Way smaller and replaced in many cases by a set of symbols

-- Example: column 3 value (carrier tracking string) is now a single one byte page symbol
-- Can be found in the dictionary structure (search for 4911)

USE tempdb;
GO

