-- AD212 Lab Solution

-- Exercise 7

-- =========================================
-- Create FileTable template
-- =========================================
USE WarehouseManagement
GO

IF OBJECT_ID('Warehouse.ProductImages', 'U') IS NOT NULL
  DROP TABLE Warehouse.ProductImages;
GO

CREATE TABLE Warehouse.ProductImages AS FILETABLE
  WITH
  (
    FILETABLE_DIRECTORY = 'ProductImageData',
    FILETABLE_COLLATE_FILENAME = DATABASE_DEFAULT
  )
GO

