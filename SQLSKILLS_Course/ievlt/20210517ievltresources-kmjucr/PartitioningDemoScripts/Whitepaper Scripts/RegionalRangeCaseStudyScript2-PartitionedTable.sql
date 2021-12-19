/*============================================================================
  File:     RegionalRangeCaseStudyPartitionedTable.sql

  MSDN Whitepaper: Partitioned Tables and Indexes in SQL Server 2005
  http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnsql90/html/sql2k5partition.asp

  Summary:  This script creates the partitioned table. This script was 
			originally included with the Partitioned Tables and Indexes 
			Whitepaper released on MSDN and written by Kimberly
			L. Tripp. To get more details about this whitepaper please 
			access the whitepaper on MSDN.

  IMPORTANT: For this script to succeed you must have the Northwind database 
			on your server. This is required in order to copy over a regionally 
			based set of sample data. If you do not already have the Northwind
			database on you can download this from here:
            http://www.sqlskills.com/resources/Northwind.zip
			
  SQL Server Version: SQL Server 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com
  All rights reserved.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills.com  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [PartitionedSalesDB];
go

-------------------------------------------------------
-- Create the partition function
-------------------------------------------------------
CREATE PARTITION FUNCTION [CustomersCountryPFN](char(7))
AS 
RANGE LEFT FOR VALUES ('France', 'Germany', 'Italy', 'Spain' );
GO

-- OR with RIGHT
--CREATE PARTITION FUNCTION [CustomersCountryPFN](char(7))
--AS 
--RANGE RIGHT FOR VALUES ('Germany', 'Italy', 'Spain', 'UK');
--GO

-- What if you just "List" them without ALPHABETIZING THEM?
-- First, would you know which one NOT to list?
-- And, what if you listed them all (then n+1 paritions)
--CREATE PARTITION FUNCTION [CustomersCountryPFN](char(7))
--AS 
--RANGE RIGHT FOR VALUES ('Italy', 'Germany', 'UK', 'Spain');
--GO

-- MOST IMPORTANTLY - what if you listed them the SAME
-- WAY for the SCHEME???
-- The FUNCTION always has to be alphabetical (even if you
-- don't specify them in order) so now everything is mis-
-- matched! YIKES!!!

-------------------------------------------------------
-- Create the partition scheme (with the LEFT function)
-------------------------------------------------------
CREATE PARTITION SCHEME [CustomersCountryPScheme]
AS 
PARTITION [CustomersCountryPFN] TO ([France], [Germany], [Italy], [Spain], [UK]);
GO

-------------------------------------------------------
-- Create the Customers table on the partition scheme
-------------------------------------------------------
CREATE TABLE [dbo].[Customers](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [char](7) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL
) ON [CustomersCountryPScheme] (Country);
GO

-------------------------------------------------------
-- Add data
-------------------------------------------------------
INSERT Customers
	SELECT * 
		FROM northwind.dbo.customers 
		WHERE Country IN ('France', 'Germany', 'Italy', 'Spain', 'UK' )
GO

-------------------------------------------------------
-- Verify Partition Ranges
-------------------------------------------------------

SELECT $partition.CustomersCountryPFN(Country) 
			AS 'Partition Number'
	, count(*) AS 'Rows In Partition'
FROM Customers
GROUP BY $partition.CustomersCountryPFN(Country)
ORDER BY 'Partition Number'
GO

-------------------------------------------------------
-- To see the partition information row by row
-------------------------------------------------------
SELECT CompanyName, Country, 
	$partition.CustomersCountryPFN(Country) 
		AS 'Partition Number'
FROM Customers
GO