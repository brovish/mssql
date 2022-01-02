/*============================================================================
  File:     3a_tsql_stack_setup.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Jonathan Kehayias, SQLskills.com
	Erin Stellato, SQLskills.com
  
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

USE [AdventureWorks2019];
GO

DROP FUNCTION IF EXISTS [dbo].[ReturnsTrue];
GO
DROP PROCEDURE IF EXISTS [dbo].[CalledThird];
GO
DROP PROCEDURE IF EXISTS [dbo].[CalledSecond];
GO
DROP PROCEDURE IF EXISTS [dbo].[CalledFirst];
GO
DROP PROCEDURE IF EXISTS [dbo].[OtherProcedure];
GO

/*
	Create a function so we can track its usage
	(just returns a value when it executes)
*/
CREATE FUNCTION [dbo].[ReturnsTrue]
(@TestValue INT)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @RetVal NVARCHAR(20) = 'Fxn Called by Third';
	RETURN(@RetVal);
END
GO

/*
	Create the last procedure in the nested calls
*/
CREATE PROCEDURE [dbo].[CalledThird] (@input int)
AS 
BEGIN
	IF (@input = 100)
	BEGIN
		SELECT 'Third was called, just returns text';
	END
	ELSE 
	BEGIN
		SELECT dbo.ReturnsTrue(@input);
	END
END
GO

/*
	Create the second procedure in the nested calls
*/
CREATE PROCEDURE [dbo].[CalledSecond]
AS 
BEGIN
	EXECUTE dbo.CalledThird 1;
END

GO

/*
	Create the first procedure in the nested calls
*/
CREATE PROCEDURE [dbo].[CalledFirst]
AS 
BEGIN
	EXECUTE [dbo].[CalledSecond];
END
GO

/*
	Create another first procedure that doesn't nest as far.
*/
CREATE PROCEDURE [dbo].[OtherProcedure]
AS 
BEGIN
	
	/* Don't cause the function to be called */
	EXECUTE dbo.CalledThird 100;
	
	/* Cause the function to be called */
	EXECUTE dbo.CalledThird 1;
END
GO





