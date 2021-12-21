/*============================================================================
  File:     Error Handling and XACT_ABORT

  Summary:  Why you should ALWAYS use TRY...CATCH and how not using
            TRY...CATCH is both ugly or possibly prone to data integrity errors!
  
  SQL Server Version: SQL Server 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE JunkDB;
GO

IF OBJECTPROPERTY(object_id('TestTxFailure'), 'IsTable') = 1
    DROP TABLE TestTxFailure;
GO

CREATE TABLE TestTxFailure
(
	col1	int				identity,
	col2	varchar(100)	default ('test')
							check (col2 in ('test', 'update')),
	col3	char(100)		default ('junk')
);
GO

-- Session settings that are ON for this session
DBCC USEROPTIONS;
go

-- if you're an admin - how are the currently connected
-- sessions set
SELECT * 
FROM sys.dm_exec_sessions
--WHERE session_id = @@spid
WHERE is_user_process = 1;
GO

-- Server setting for "user options" 
-- sp_configure 'user options', 17216

--	64		ARITHABORT
--	256		QUOTED_IDENTIFIER
--	512		NOCOUNT
--	16384	XACT_ABORT
--  = 17216

-----------------------------------------------------------------------------
--  The worst - NO ERROR handling and inconsistent xact_abort settings
-----------------------------------------------------------------------------

-- default: XACT_ABORT is OFF

SET XACT_ABORT OFF;
go

-- Concept... with absolutely NO error handling!
BEGIN TRAN
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem (row 1)
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint (row 2)
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem (row 3)
COMMIT TRAN;
go

SELECT * FROM TestTxFailure;	-- two rows with IDs 1 and 3
go

-- What can we see happening?
BEGIN TRAN;
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- USE the scoped identity over @@identity
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- last SUCCESSFUL identity setting
	SELECT * FROM TestTxFailure;
COMMIT TRAN;
go

-- Now, what do we have? (another bad row [4] because XACT_ABORT was off)
SELECT * FROM TestTxFailure;	-- three rows with IDs 1, 3, and 4
go

-- Now, what happens with set xact_abort on   (MUCH BETTER... but not great handling)
SET XACT_ABORT ON;
go

BEGIN TRAN;
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- USE the scoped identity over @@identity
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- last SUCCESSFUL identity setting
	SELECT * FROM TestTxFailure;
COMMIT TRAN;
go

-- Now, what do we have? (Same as before because XACT_ABORT was on and it didn't allow another row to get in)
SELECT * FROM TestTxFailure;	-- ONLY the three rows with IDs 1, 3, and 4 because
								-- 6 was rolled back because of XACT_ABORT being on
go

-----------------------------------------------------------------------------
--  What about "old school" error handling?
-----------------------------------------------------------------------------

-- Start with xact_abort off:
SET XACT_ABORT OFF;
go

DECLARE @ErrorNumber	int = 0;	
BEGIN TRAN;
	
	INSERT TestTxFailure DEFAULT VALUES;-- won't be a problem
	SET @ErrorNumber = @@ERROR;
	IF @ErrorNumber > 0
	BEGIN;
			SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber);
			ROLLBACK TRANSACTION;
	END;
	
	SELECT @@TRANCOUNT;
	
	INSERT TestTxFailure (col2) VALUES ('fail'); -- this will fail the constraint
	SET @ErrorNumber = @@ERROR; 
	IF @ErrorNumber > 0
	BEGIN;
			SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber);
			ROLLBACK TRANSACTION;
	END;
	
	SELECT @@TRANCOUNT;
	
	SELECT * FROM TestTxFailure;
	
IF @@TRANCOUNT > 1
	COMMIT TRAN;
go

-- Now, what do we have?
SELECT * FROM TestTxFailure;	-- still only those three rows with IDs 1, 3, and 4
								-- because we "handled" the ERROR. But - UGLY and 
								-- too much code, etc.
go

-- But now it's not trappable...
SET XACT_ABORT ON
go

DECLARE @ErrorNumber	int = 0;	
BEGIN TRAN;
	
	INSERT TestTxFailure DEFAULT VALUES;-- won't be a problem
	SET @ErrorNumber = @@ERROR;
	IF @ErrorNumber > 0
	BEGIN;
			SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber);
			ROLLBACK TRANSACTION;
	END;
	
	SELECT @@TRANCOUNT;
	
	INSERT TestTxFailure (col2) VALUES ('fail'); -- this will fail the constraint
	SET @ErrorNumber = @@ERROR; 
	IF @ErrorNumber > 0
	BEGIN;
			SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber);
			ROLLBACK TRANSACTION;
	END;
	
	SELECT @@TRANCOUNT;
	
	SELECT * FROM TestTxFailure;
	
IF @@TRANCOUNT > 1
	COMMIT TRAN;
go

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--	
--  This is definitely a best practice - USE TRY/CATCH for error handling!
--
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- Check our current state
SELECT * FROM TestTxFailure;	-- three rows with IDs 1, 3, and 4
go

-- What about with TRY/CATCH:
-- What can you control with xact_abort off:
SET XACT_ABORT OFF;
go

BEGIN TRAN;
BEGIN TRY;
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- USE the scoped identity over @@identity
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- last SUCCESSFUL identity setting
    COMMIT TRANSACTION -- should be here
END TRY

BEGIN CATCH
	SELECT error_number()	AS ErrorNumber
		, error_message()	AS ErrorMessage
		, error_severity()	AS ErrorSeverity
		, error_state()		AS ErrorState
		, error_line()		AS ErrorLine
		, error_procedure() AS ProcedureName;
	-- Since we caught something...
		ROLLBACK TRAN
END CATCH;
go

-- Check our current state
SELECT * FROM TestTxFailure;	-- still just those three rows (IDs 1, 3, and 4)
go

-- Nothing changes with xact_abort on:
SET XACT_ABORT ON;
go

BEGIN TRAN
BEGIN TRY
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- USE the scoped identity over @@identity
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- last SUCCESSFUL identity setting
    COMMIT TRANSACTION; -- should be here if all goes well
END TRY

BEGIN CATCH
	SELECT error_number()	AS ErrorNumber
		, error_message()	AS ErrorMessage
		, error_severity()	AS ErrorSeverity
		, error_state()		AS ErrorState
		, error_line()		AS ErrorLine
		, error_procedure() AS ProcedureName;
	-- Since we caught something...
		ROLLBACK TRAN; -- decrements @@trancount to 0
END CATCH;
GO

-- Check our current state
SELECT * FROM TestTxFailure;	-- still just those three rows (IDs 1, 3, and 4)
go

------------------------------------------------------------
-- What about TRY...CATCH, XACT_ABORT, and SAVEPOINTS
------------------------------------------------------------

-- Uncommittable transactions BECAUSE XACT_ABORT is on!
SET XACT_ABORT ON;
go

BEGIN TRAN;
SAVE TRAN SavePoint1TerribleNotUniqueName;

BEGIN TRY;
	
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- USE the scoped identity over @@identity
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- last SUCCESSFUL identity setting
    COMMIT TRANSACTION -- should be here IF all goes well

END TRY

BEGIN CATCH

	SELECT error_number() 	AS ErrorNumber
		, error_message()	AS ErrorMessage
		, error_severity()	AS ErrorSeverity
		, error_state()		AS ErrorState
		, error_line()		AS ErrorLine
		, error_procedure() AS ProcedureName;

	-- Not all transactions are "committable" and when it's NOT
	-- you can't rollback to a savepoint - you must rollback the entire
	-- transaction

	-- The safest approach
	IF XACT_STATE() = -1
		BEGIN;  
			RAISERROR (N'The transaction is in an uncommittable state. Rolling back transaction.', 10, -1)
			ROLLBACK TRANSACTION;  
		END;
	ELSE  
		BEGIN;
			RAISERROR (N'The transaction is NOT in an uncommittable state.', 10, -1)
			ROLLBACK TRAN SavePoint1TerribleNotUniqueName;  -- Only controls state...
			COMMIT TRANSACTION;								-- must be used to reset @@trancount
		END;

END CATCH;
go

-- Check our current state
SELECT * FROM TestTxFailure;	-- still just those three rows (IDs 1, 3, and 4)
go

-----------------------------------------------
-- What about savepoints?
-----------------------------------------------

-- You can do whatever you want if XACT_ABORT is OFF!
SET XACT_ABORT OFF;
go

BEGIN TRAN 
SAVE TRAN SavePoint1TerribleNotUniqueName

BEGIN TRY
	
	INSERT TestTxFailure DEFAULT VALUES;			-- won't be a problem
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- USE the scoped identity over @@identity
	INSERT TestTxFailure (col2) VALUES ('fail');	-- this will fail the constraint
	SELECT @@TRANCOUNT, SCOPE_IDENTITY();			-- last SUCCESSFUL identity setting
    COMMIT TRANSACTION -- should be here IF all goes well

END TRY

BEGIN CATCH

	SELECT error_number() 	AS ErrorNumber
		, error_message()	AS ErrorMessage
		, error_severity()	AS ErrorSeverity
		, error_state()		AS ErrorState
		, error_line()		AS ErrorLine
		, error_procedure() AS ProcedureName

	-- Not all transactions are "committable" and when it's NOT
	-- you can't rollback to a savepoint - you must rollback the entire
	-- transaction

	-- The safest approach
	IF XACT_STATE() = -1
		BEGIN  
			RAISERROR (N'The transaction is in an uncommittable state. Rolling back transaction.', 10, -1)
			ROLLBACK TRANSACTION;  
		END
	ELSE  
		BEGIN
			RAISERROR (N'The transaction is NOT in an uncommittable state.', 10, -1)
			ROLLBACK TRAN SavePoint1TerribleNotUniqueName   -- Only controls state...
			COMMIT TRANSACTION								-- must be used to reset @@trancount
		END;

END CATCH;
go
