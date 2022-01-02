/*============================================================================
  File:     2b_tempdb_setup.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Jonathan Kehayias, SQLskills.com
	Modified by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*
	Create problematic SPs
*/
USE [AdventureWorks2017]
GO

IF OBJECT_ID(N'Person.USR_GetTopDuplicateCustomer') IS NOT NULL
BEGIN
	DROP FUNCTION [Person].[USR_GetTopDuplicateCustomer];
END
GO
CREATE FUNCTION [Person].[USR_GetTopDuplicateCustomer]  (@base  int)  
RETURNS @retval TABLE  
(   
      AddressLine1		NCHAR(600)		NOT NULL,   
      AddressLine2		NCHAR(600)		NULL,   
      City				NVARCHAR(30)	NOT NULL,   
      StateProvinceID	INT				NOT NULL,   
      CT				INT				NOT NULL,
	  PADDING			NCHAR(2800)		NOT NULL 
)  
AS  
BEGIN   
 
      INSERT INTO @retval   
      SELECT AddressLine1, AddressLine2, City, StateProvinceID, ct = COUNT(*), ''
      FROM [Person].[Address]   
      WHERE AddressID >= @base   
      GROUP BY AddressLine1, AddressLine2, StateProvinceID, City   
      HAVING COUNT(*) > 1   
 
      RETURN  
END
GO

IF OBJECT_ID(N'Person.USR_IsInTop100Customers') IS NOT NULL
BEGIN
	DROP FUNCTION [Person].[USR_IsInTop100Customers];
END
GO
CREATE FUNCTION  [Person].[USR_IsInTop100Customers](@base int)
RETURNS @retval TABLE
(
	AddressID INT
)
AS
BEGIN

	INSERT INTO @retval
	SELECT TOP 100 AddressID 
	FROM [Person].[Address] 
	WHERE AddressID >= @base
	ORDER BY AddressID;

	RETURN
END
GO

IF OBJECT_ID(N'Person.GetNextDuplicateCustomerSet') IS NOT NULL
BEGIN
	DROP PROCEDURE Person.GetNextDuplicateCustomerSet;
END
GO
CREATE PROCEDURE [Person].[GetNextDuplicateCustomerSet] (@base INT)
AS
BEGIN
	SELECT DISTINCT 
		  (SELECT TOP 1 AddressLine1 
				FROM [Person].[USR_GetTopDuplicateCustomer](AddressID)) AS AddressLine1,   
		  (SELECT TOP 1 ISNULL(AddressLine2, '') 
				FROM [Person].[USR_GetTopDuplicateCustomer](AddressID)) AS AddressLine2,   
		  (SELECT TOP 1 City 
				FROM [Person].[USR_GetTopDuplicateCustomer](AddressID)) AS City,   
		  (SELECT TOP 1 StateProvinceID 
				FROM [Person].[USR_GetTopDuplicateCustomer](AddressID)) AS StateProvinceID,   
		  (SELECT TOP 1 CT 
				FROM [Person].[USR_GetTopDuplicateCustomer](AddressID)) AS ct  
	FROM [Person].[Address] AS a 
	WHERE AddressID IN 
		  (SELECT AddressID 
		   FROM [Person].[USR_IsInTop100Customers](@base));
END
GO

/*  Run Tests from here  */

