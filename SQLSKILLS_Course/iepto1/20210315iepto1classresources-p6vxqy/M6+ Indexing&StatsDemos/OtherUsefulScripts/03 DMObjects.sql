/*============================================================================
  File:     DMObjects.sql

  Summary:  This script creates 3 functions and a stored procedure
			used to interrogate the new DM objects. Original queries
			based on examples and scripts from Dan Winn, SQL PM.

  Date:     February 2011

  SQL Server Version: 2005/2008
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and other useful content, go to:
	http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE master
go

SELECT * FROM sys.system_objects 
WHERE name LIKE 'dm[_]%'
ORDER BY name
go
 
-- Find out if the DM object is a DMV or a DMF
IF OBJECTPROPERTY(object_id(N'dbo.DMObjectType'), 'IsScalarFunction') = 1
	DROP FUNCTION dbo.DMObjectType
go

CREATE FUNCTION dbo.DMObjectType
	(@DMObjectName	sysname)
RETURNS char(2)
AS
BEGIN
RETURN
	(SELECT type
	FROM sys.system_objects 
	WHERE name = @DMObjectName)
END
go

-- If it's a function, find it's parameters...
IF OBJECTPROPERTY(object_id(N'dbo.DMFunctionParams'), 'IsInlineFunction') = 1
	DROP FUNCTION dbo.DMFunctionParams
go

CREATE FUNCTION DMFunctionParams
	(@DMObjectName	sysname)
RETURNS table
AS
RETURN
(SELECT o.name AS [DMObjectName]
		, p.parameter_id AS [ParameterPosition]
		, p.name AS [ParameterName]
		, t.name AS [DataType]
		, p.max_length AS [MaxLength]
		, p.* 
	FROM sys.system_parameters AS p
		JOIN sys.system_objects AS o
				ON p.[object_id] = o.[object_id]
		JOIN sys.types AS t
				ON p.user_type_id = t.user_type_id
	WHERE o.name = @DMObjectName)
go

-- List it's output columns...
IF OBJECTPROPERTY(object_id(N'dbo.DMObjectColumns'), 'IsInlineFunction') = 1
	DROP FUNCTION dbo.DMObjectColumns
go

CREATE FUNCTION dbo.DMObjectColumns
	(@DMObjectName	sysname)
RETURNS table
AS
RETURN
(SELECT o.name AS [DMObjectName]
		, c.column_id AS [ColumnPosition]
		, c.name AS [ColumnHeader]
		, t.name AS [DataType]
		, c.max_length AS [MaxLength]
		, c.precision AS [Precision]
		, c.scale AS [Scale]
	FROM sys.system_columns AS c
		JOIN sys.system_objects AS o
			ON c.[object_id] = o.[object_id]
		JOIN sys.types AS t
			ON c.user_type_id = t.user_type_id
	WHERE o.name = @DMObjectName)
go

-- Bring it all together in a nice clean sp!
IF OBJECTPROPERTY(object_id(N'dbo.sp_GetDMObjectInfo'), 'IsProcedure') = 1
	DROP PROCEDURE dbo.sp_GetDMObjectInfo
go

CREATE PROCEDURE dbo.sp_GetDMObjectInfo
		(@DMObjectName	sysname)
AS
IF (dbo.DMObjectType(@DMObjectName) NOT IN ('IF', 'TF', 'V') OR dbo.DMObjectType(@DMObjectName) IS NULL)
BEGIN
	RAISERROR ('Object does not exist or is not a Dynamic Management Object.', 16, -1)
	RETURN
END

IF dbo.DMObjectType(@DMObjectName) = 'IF'
BEGIN
	SELECT 'Dynamic Management Function' AS [Dynamic Management Object Type]

	SELECT * FROM dbo.DMFunctionParams(@DMObjectName)
	ORDER BY ParameterPosition
END
IF dbo.DMObjectType(@DMObjectName) = 'TF'
BEGIN
	SELECT 'Dynamic Management Table-Valued Function' AS [Dynamic Management Object Type]

	SELECT * FROM dbo.DMFunctionParams(@DMObjectName)
	ORDER BY ParameterPosition
END
IF dbo.DMObjectType(@DMObjectName) = 'V'
BEGIN
	SELECT 'Dynamic Management View' AS [Dynamic Management Object Type]
END

SELECT * FROM dbo.DMObjectColumns(@DMObjectName)
ORDER BY ColumnPosition
go

-- Find out if the DM object is a DMV or a DMF	
--SELECT dbo.DMObjectType(N'dm_db_index_physical_stats')

-- If it's a function, find it's parameters...
--SELECT * FROM dbo.DMFunctionParams(N'dm_db_index_physical_stats')
--ORDER BY ParameterPosition

-- List it's output columns...
--SELECT * FROM dbo.DMObjectColumns(N'dm_db_index_physical_stats')
--ORDER BY ColumnPosition

-- Bring it all together in a nice clean sp!
--EXEC dbo.sp_GetDMObjectInfo N'dm_db_index_physical_stats'