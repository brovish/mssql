-- Initial setup
DECLARE @SPID INT
DECLARE @HighestInternal INT
DECLARE @LastInternal INT
DECLARE @ThisInternal INT
DECLARE @CurrentDiff INT
Declare @Detailed INT
SELECT @SPID = 99
Select @Detailed = 0
SELECT @HighestInternal = 0
SELECT @LastInternal =  [internal_objects_alloc_page_count]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID



-- Sprinkle these in the code
SELECT @ThisInternal = [internal_objects_alloc_page_count]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID
SET @CurrentDiff = @ThisInternal - @LastInternal
SET @LastInternal = @ThisInternal
IF @CurrentDiff > @HighestInternal SET @HighestInternal = @CurrentDiff

If @Detailed = 1
SELECT 1, [user_objects_alloc_page_count]-[user_objects_dealloc_page_count] AS [User],
@HighestInternal AS [Internal],
([user_objects_alloc_page_count]-[user_objects_dealloc_page_count]) + @HighestInternal AS [Total]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID


-- Final output
SELECT [user_objects_alloc_page_count]-[user_objects_dealloc_page_count] AS [User],
@HighestInternal AS [Internal],
([user_objects_alloc_page_count]-[user_objects_dealloc_page_count]) + @HighestInternal AS [Total]
FROM sys.dm_db_task_space_usage
WHERE [session_id] = @SPID

