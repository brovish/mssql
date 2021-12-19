/*============================================================================
  File:     SalesDBCreateScripts.sql

  Summary:  Sample DB for Always On demos.
  
  SQL Server Versions: 2005 onwards

  NOTE: You do NOT need to run this but this is what was used to create the
        first version of SalesDB. So, if you want to change/tweak things in
        the actual data, you might want to tweak this script. Note: it uses
        some VERY old databases. ;-) 
------------------------------------------------------------------------------
  Written by SQLskills.com

  (c) SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE SalesDB
go

IF OBJECTPROPERTY(object_id('Sales'), 'IsUserTable') = 1
	DROP TABLE Sales
go
CREATE TABLE Sales
(
	SalesID			int		identity,
	SalesPersonID	int		not null,
	CustomerID		int		not null,
	ProductID		int		not null,
	Quantity		int		not null
)
go

IF OBJECTPROPERTY(object_id('Products'), 'IsUserTable') = 1
	DROP TABLE Products
go
CREATE TABLE Products
(
	ProductID	int		identity,
	[Name]		nvarchar(50)	not null,
	Price		money	null
)
go
ALTER TABLE Products
ADD CONSTRAINT ProductsPK
	PRIMARY KEY CLUSTERED (ProductID)
go

IF OBJECTPROPERTY(object_id('Customers'), 'IsUserTable') = 1
	DROP TABLE Customers
go
CREATE TABLE Customers
(
	CustomerID	int		identity,
	FirstName		nvarchar(40)	not null,
	MiddleImitial	nvarchar(40)	null,
	LastName		nvarchar(40)	not null
)
go
ALTER TABLE Customers
ADD CONSTRAINT CustomerPK
	PRIMARY KEY CLUSTERED (CustomerID)
go

IF OBJECTPROPERTY(object_id('Employees'), 'IsUserTable') = 1
	DROP TABLE Employees
go
CREATE TABLE Employees
(
	EmployeeID		int		identity,
	FirstName		nvarchar(40)	not null,
	MiddleImitial	nvarchar(40)	null,
	LastName		nvarchar(40)	not null	
)
go
ALTER TABLE Employees
ADD CONSTRAINT EmployeePK
	PRIMARY KEY CLUSTERED (EmployeeID)
go

ALTER TABLE Sales
ADD CONSTRAINT SalesPK
	PRIMARY KEY CLUSTERED (SalesID)
go

ALTER TABLE Sales
ADD CONSTRAINT SalesCustomersFK
	FOREIGN KEY (CustomerID)
		REFERENCES Customers(CustomerID)
			ON UPDATE CASCADE
go

ALTER TABLE Sales
ADD CONSTRAINT SalesProductsFK
	FOREIGN KEY (ProductID)
		REFERENCES Products(ProductID)
			ON UPDATE CASCADE
go

ALTER TABLE Sales
ADD CONSTRAINT SalesEmployeesFK
	FOREIGN KEY (SalesPersonID)
		REFERENCES Employees(EmployeeID)
			ON UPDATE CASCADE
go

INSERT Products
	SELECT [Name], ISNULL(NULLIF(ListPrice,0), (convert(money, substring(ProductNumber, 6, 1))*ProductID)/5)
	FROM AdventureWorks.Production.Product
go

INSERT Employees
SELECT au_fname, substring(au_lname, 2, 1), au_lname
FROM pubs.dbo.authors
go

INSERT Customers
SELECT DISTINCT
	AWC.FirstName AS FN, Substring(AWC.MiddleName, 1, 1) AS MI, AWC.LastName AS LN
FROM adventureworks.person.contact AS AWC
WHERE AWC.Firstname NOT LIKE '%.%'
go

SELECT count(*) FROM Customers -- 19759
SELECT count(*) FROM Products -- 504
SELECT count(*) FROM Employees -- 23

SET NOCOUNT ON
go
DECLARE @StartTime	datetime,
		@RunCounter	tinyint
SELECT  @RunCounter = 1
WHILE @RunCounter < 19760
BEGIN
	SELECT @StartTime = getdate()
	WHILE getdate() < dateadd(ss, 3, @StartTime)
	BEGIN
	INSERT Sales
		SELECT
			(SELECT EmployeeID 
				FROM Employees 
				WHERE ISNULL(NULLIF((datepart(ms, (getdate())) + @RunCounter) %24, 0), @RunCounter%23+1) = EmployeeID),
			(@RunCounter),
--			(SELECT CustomerID 
--				FROM Customers 
--				WHERE ISNULL(NULLIF((datepart(ms, (getdate())) + @RunCounter) *10000 %19760, 0), @RunCounter) = CustomerID),
			(SELECT ProductID 
				FROM Products 
				WHERE ISNULL(NULLIF((datepart(ms, (getdate())) + @RunCounter) %505, 0), @RunCounter) = ProductID),
			ISNULL(NULLIF((datepart(ms, getdate()) + @RunCounter), 0), @RunCounter)
		WAITFOR DELAY '00:00:00.001'
	END
	SELECT @RunCounter = @RunCounter + 1
END
go

-- Check the data

SET NOCOUNT OFF
go

SELECT COUNT(*) AS TotalSales 
FROM Sales
go
SELECT SalesPersonID, sum(quantity) FROM Sales
GROUP BY SalesPersonID
ORDER BY 2 desc
go

SELECT ProductID, sum(quantity) FROM Sales
GROUP BY ProductID
ORDER BY 2 desc
go

SELECT CustomerID, max(quantity) FROM Sales
GROUP BY CustomerID
ORDER BY 2 desc
go

SELECT * FROM sys.dm_db_index_physical_stats(db_id(), object_id('Sales'), NULL, NULL, NULL)
SELECT * FROM sys.dm_db_index_physical_stats(db_id(), object_id('Customers'), NULL, NULL, NULL)
SELECT * FROM sys.dm_db_index_physical_stats(db_id(), object_id('Products'), NULL, NULL, NULL)
SELECT * FROM sys.dm_db_index_physical_stats(db_id(), object_id('Employees'), NULL, NULL, NULL)
go

-- Backup the database as base set of data

ALTER DATABASE SalesDB
	SET RECOVERY FULL
go

BACKUP DATABASE SalesDB
TO DISK = N'C:\SQLskills\SalesDBOriginal.bak'
WITH INIT
go

SELECT COUNT(*) AS TotalSales  -- 6,715,221 Sales
FROM Sales
go

SELECT COUNT(*) AS TotalCustomers -- 19,759 Customers
FROM Customers
go

SELECT COUNT(*) AS TotalProducts -- 504 Products
FROM Products
go

SELECT COUNT(*) AS TotalEmployees -- 23 Employees
FROM Employees
go

-- Database Setup Complete

-- Add a single row:

WHILE 1=1
BEGIN
INSERT Sales
	SELECT
		(SELECT EmployeeID 
			FROM Employees 
			WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) %24, 0), 1) = EmployeeID),
		(SELECT CustomerID 
			FROM Customers 
			WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) *10000 %19760, 0), 1) = CustomerID),
		(SELECT ProductID 
			FROM Products 
			WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) %505, 0), 1) = ProductID),
		ISNULL(NULLIF((datepart(ms, getdate())), 0), 1)
		SELECT @@IDENTITY
	WAITFOR DELAY '00:00:02'
END
go