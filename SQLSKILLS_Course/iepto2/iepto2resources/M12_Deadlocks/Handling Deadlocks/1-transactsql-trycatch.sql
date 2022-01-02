USE [DeadlockDemo];
GO

-- Use TRY/CATCH to handle the deadlock
BEGIN TRY
	-- place sql code here
	EXEC [BookmarkLookupSelect] 4;
	SELECT 'Successful' ;
END TRY
BEGIN CATCH
	-- Error is a deadlock
	IF ( ERROR_NUMBER() = 1205 )
	BEGIN
		SELECT 'Deadlock occurred.' ;
	END
	-- Error is not a deadlock
	ELSE
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(4000) ;
		DECLARE @ErrorSeverity INT ;
		DECLARE @ErrorState INT ;
		SELECT	@ErrorMessage = ERROR_MESSAGE() ,
				@ErrorSeverity = ERROR_SEVERITY() ,
				@ErrorState = ERROR_STATE() ;
		-- Re-Raise the Error that caused the problem
		RAISERROR (@ErrorMessage, -- Message text.
					@ErrorSeverity, -- Severity.
					@ErrorState -- State.
					) ;
	END
	-- Check transaction state and roll back if necessary
	IF XACT_STATE() <> 0
		ROLLBACK TRANSACTION ;
END CATCH ;
