/*============================================================================
  File:     sp_SQLskills_SQL2008_finddupes_helpindex.sql

  Summary:  This is similar to the rewrite of sp_helpindex but it requires
            that the included columns be unordered.

  Date:     March 2021

  Version:	SQL Server 2008-2019
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills instructors.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE master;
GO

IF OBJECTPROPERTY(OBJECT_ID('sp_SQLskills_SQL2008_finddupes_helpindex'), 'IsProcedure') = 1
	DROP PROCEDURE sp_SQLskills_SQL2008_finddupes_helpindex;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_SQL2008_finddupes_helpindex]
	@objname NVARCHAR(776)		-- the table to check for indexes
AS

--   March 2021: Ignore columnstore indexes, case-sensitive collation,
--               added semicolons, standardized formatting.
--November 2010: Added a column to show if an index is disabled.
--     May 2010: Added tree/leaf columns to the output - this requires the 
--               stored procedure: sp_SQLskills_ExposeColsInIndexLevels
--               (Better known as sp_helpindex8)
--   March 2010: Added index_id to the output (ordered by index_id as well)
--  August 2008: Fixed a bug (missing begin/end block) AND I found
--               a few other issues that people hadn't noticed (yikes!)!
--   April 2008: Updated to add included columns to the output. 

-- See my blog for updates and/or additional information
-- http://www.SQLskills.com/blogs/Kimberly (Kimberly L. Tripp)

	SET NOCOUNT ON;

	DECLARE @objid INT,			-- the object id of the table
			@indid SMALLINT,	-- the index id of an index
			@groupid INT,  		-- the filegroup id of an index
			@indname			sysname,
			@groupname			sysname,
			@status				INT,
			@keys				NVARCHAR(2126),	--Length (16*max_identifierLength)+(15*2)+(16*3)
			@inc_columns		NVARCHAR(MAX),
			@inc_Count			SMALLINT,
			@loop_inc_Count		SMALLINT,
			@dbname				sysname,
			@ignore_dup_key		BIT,
			@is_unique			BIT,
			@is_hypothetical	BIT,
			@is_primary_key		BIT,
			@is_unique_key 		BIT,
			@is_disabled		BIT,
			@auto_created		BIT,
			@no_recompute		BIT,
			@filter_definition	NVARCHAR(MAX),
			@ColsInTree			NVARCHAR(2126),
			@ColsInLeaf			NVARCHAR(MAX);

	-- Check to see that the object names are local to the current database.
	SELECT @dbname = PARSENAME(@objname,3);
	IF @dbname IS NULL
		SELECT @dbname = DB_NAME();
	ELSE IF @dbname <> DB_NAME()
		BEGIN
			RAISERROR(15250,-1,-1);
			RETURN (1);
		END;

	-- Check to see the the table exists and initialize @objid.
	SELECT @objid = OBJECT_ID(@objname);
	IF @objid IS NULL
	BEGIN
		RAISERROR(15009,-1,-1,@objname,@dbname);
		RETURN (1);
	END;

	-- OPEN CURSOR OVER INDEXES (skip stats: bug shiloh_51196)
	DECLARE ms_crs_ind CURSOR LOCAL STATIC FOR
		SELECT i.index_id, i.data_space_id, QUOTENAME(i.name, N']') AS name,
			i.ignore_dup_key, i.is_unique, i.is_hypothetical, i.is_primary_key, i.is_unique_constraint,
			s.auto_created, s.no_recompute, i.filter_definition, i.is_disabled
		FROM sys.indexes AS i 
			JOIN sys.stats AS s
				ON i.object_id = s.object_id 
					AND i.index_id = s.stats_id
		WHERE i.object_id = @objid;
	OPEN ms_crs_ind;
	FETCH ms_crs_ind INTO @indid, @groupid, @indname, @ignore_dup_key, @is_unique, @is_hypothetical,
			@is_primary_key, @is_unique_key, @auto_created, @no_recompute, @filter_definition, @is_disabled;

	-- IF NO INDEX, QUIT
	IF @@fetch_status < 0
	BEGIN
		DEALLOCATE ms_crs_ind;
		--raiserror(15472,-1,-1,@objname) -- Object does not have any indexes.
		RETURN (0);
	END;

	-- create temp tables
	CREATE TABLE #spindtab
	(
		index_name			sysname	COLLATE DATABASE_DEFAULT NOT NULL,
		index_id			INT,
		ignore_dup_key		BIT,
		is_unique			BIT,
		is_hypothetical		BIT,
		is_primary_key		BIT,
		is_unique_key		BIT,
		is_disabled         BIT,
		auto_created		BIT,
		no_recompute		BIT,
		groupname			sysname COLLATE DATABASE_DEFAULT NULL,
		index_keys			NVARCHAR(2126)COLLATE DATABASE_DEFAULT NOT NULL, -- see @keys above for length descr
		filter_definition	NVARCHAR(MAX),
		inc_Count			SMALLINT,
		inc_columns			NVARCHAR(MAX),
		cols_in_tree		NVARCHAR(2126),
		cols_in_leaf		NVARCHAR(MAX)
	);

	CREATE TABLE #IncludedColumns
	(	RowNumber	SMALLINT,
		[Name]	NVARCHAR(128)
	);

	-- Now check out each index, figure out its type and keys and
	--	save the info in a temporary table that we'll print out at the end.
	WHILE @@fetch_status >= 0
	BEGIN
		-- First we'll figure out what the keys are.
		DECLARE @i INT, @thiskey NVARCHAR(131); -- 128+3

		-- ISNULL because columnstore indexes return NULL here
		SELECT @keys = ISNULL(QUOTENAME(INDEX_COL(@objname, @indid, 1), N']'), N''), @i = 2;
		IF (INDEXKEY_PROPERTY(@objid, @indid, 1, 'isdescending') = 1)
			SELECT @keys = @keys  + '(-)';

		SELECT @thiskey = QUOTENAME(INDEX_COL(@objname, @indid, @i), N']');
		IF ((@thiskey IS NOT NULL) AND (INDEXKEY_PROPERTY(@objid, @indid, @i, 'isdescending') = 1))
			SELECT @thiskey = @thiskey + '(-)';

		WHILE (@thiskey IS NOT NULL)
		BEGIN
			SELECT @keys = @keys + ', ' + @thiskey, @i = @i + 1;
			SELECT @thiskey = QUOTENAME(INDEX_COL(@objname, @indid, @i), N']');
			IF ((@thiskey IS NOT NULL) AND (INDEXKEY_PROPERTY(@objid, @indid, @i, 'isdescending') = 1))
				SELECT @thiskey = @thiskey + '(-)';
		END;

		-- Second, we'll figure out what the included columns are.
		SELECT @inc_columns = NULL;
		
		SELECT @inc_Count = COUNT(*)
		FROM sys.tables AS tbl
		INNER JOIN sys.indexes AS si 
			ON (si.index_id > 0 
				AND si.is_hypothetical = 0) 
				AND (si.object_id=tbl.object_id)
		INNER JOIN sys.index_columns AS ic 
			ON (ic.column_id > 0 
				AND (ic.key_ordinal > 0 OR ic.partition_ordinal = 0 OR ic.is_included_column != 0)) 
				AND (ic.index_id=CAST(si.index_id AS INT) AND ic.object_id=si.object_id)
		INNER JOIN sys.columns AS clmns 
			ON clmns.object_id = ic.object_id 
			AND clmns.column_id = ic.column_id
		WHERE ic.is_included_column = 1 AND
			(si.index_id = @indid) AND 
			(tbl.object_id= @objid);

		IF @inc_Count > 0
		BEGIN
			DELETE FROM #IncludedColumns;
			INSERT #IncludedColumns
				SELECT ROW_NUMBER() OVER (ORDER BY clmns.column_id) 
				, clmns.name 
				FROM
				sys.tables AS tbl
				INNER JOIN sys.indexes AS si 
					ON (si.index_id > 0 
						AND si.is_hypothetical = 0) 
						AND (si.object_id=tbl.object_id)
				INNER JOIN sys.index_columns AS ic 
					ON (ic.column_id > 0 
						AND (ic.key_ordinal > 0 OR ic.partition_ordinal = 0 OR ic.is_included_column != 0)) 
						AND (ic.index_id=CAST(si.index_id AS INT) AND ic.object_id=si.object_id)
				INNER JOIN sys.columns AS clmns 
					ON clmns.object_id = ic.object_id 
					AND clmns.column_id = ic.column_id
				WHERE ic.is_included_column = 1 AND
					(si.index_id = @indid) AND 
					(tbl.object_id= @objid);
			
			SELECT @inc_columns = QUOTENAME([Name], N']') FROM #IncludedColumns WHERE RowNumber = 1;

			SET @loop_inc_Count = 1;

			WHILE @loop_inc_Count < @inc_Count
			BEGIN
				SELECT @inc_columns = @inc_columns + ', ' + QUOTENAME([Name], N']') 
					FROM #IncludedColumns WHERE RowNumber = @loop_inc_Count + 1;
				SET @loop_inc_Count = @loop_inc_Count + 1;
			END;
		END;
	
		SELECT @groupname = NULL;
		SELECT @groupname = name FROM sys.data_spaces WHERE data_space_id = @groupid;

		-- Get the column list for the tree and leaf level, for all nonclustered indexes IF the table has a clustered index
		IF @indid = 1 AND (SELECT is_unique FROM sys.indexes WHERE index_id = 1 AND object_id = @objid) = 0
			SELECT @ColsInTree = @keys + N', UNIQUIFIER', @ColsInLeaf = N'All columns "included" - the leaf level IS the data row, plus the UNIQUIFIER';
			
		IF @indid = 1 AND (SELECT is_unique FROM sys.indexes WHERE index_id = 1 AND object_id = @objid) = 1
			SELECT @ColsInTree = @keys, @ColsInLeaf = N'All columns "included" - the leaf level IS the data row.';
		
		IF @indid > 1 AND (SELECT COUNT(*) FROM sys.indexes WHERE index_id = 1 AND object_id = @objid) = 1
		EXEC sp_SQLskills_ExposeColsInIndexLevels_INCLUDE_UNORDERED @objid, @indid, @ColsInTree OUTPUT, @ColsInLeaf OUTPUT;
		
		IF @indid > 1 AND @is_unique = 0 AND (SELECT is_unique FROM sys.indexes WHERE index_id = 1 AND object_id = @objid) = 0 
			SELECT @ColsInTree = @ColsInTree + N', UNIQUIFIER', @ColsInLeaf = @ColsInLeaf + N', UNIQUIFIER';
		
		IF @indid > 1 AND @is_unique = 1 AND (SELECT is_unique FROM sys.indexes WHERE index_id = 1 AND object_id = @objid) = 0 
			SELECT @ColsInLeaf = @ColsInLeaf + N', UNIQUIFIER';
		
		IF @indid > 1 AND (SELECT COUNT(*) FROM sys.indexes WHERE index_id = 1 AND object_id = @objid) = 0 -- table is a HEAP
		BEGIN
			IF (@is_unique_key = 0)
				SELECT @ColsInTree = @keys + N', RID'
					, @ColsInLeaf = @keys + N', RID' + CASE WHEN @inc_columns IS NOT NULL THEN N', ' + @inc_columns ELSE N'' END;
		
			IF (@is_unique_key = 1)
				SELECT @ColsInTree = @keys
					, @ColsInLeaf = @keys + N', RID' + CASE WHEN @inc_columns IS NOT NULL THEN N', ' + @inc_columns ELSE N'' END;
		END;
			
		-- INSERT ROW FOR INDEX
		INSERT INTO #spindtab VALUES (@indname, @indid, @ignore_dup_key, @is_unique, @is_hypothetical,
			@is_primary_key, @is_unique_key, @is_disabled, @auto_created, @no_recompute, @groupname, @keys, @filter_definition, @inc_Count, @inc_columns, @ColsInTree, @ColsInLeaf);

		-- Next index
    	FETCH ms_crs_ind INTO @indid, @groupid, @indname, @ignore_dup_key, @is_unique, @is_hypothetical,
			@is_primary_key, @is_unique_key, @auto_created, @no_recompute, @filter_definition, @is_disabled;
	END;
	DEALLOCATE ms_crs_ind;

	-- DISPLAY THE RESULTS	
	SELECT
		'index_id' = index_id,
		'is_disabled' = is_disabled,
		'index_name' = index_name,
		'index_description' = CONVERT(VARCHAR(210), --bits 16 off, 1, 2, 16777216 on, located on group
				CASE WHEN index_id = 1 THEN 'clustered' ELSE 'nonclustered' END
				+ CASE WHEN ignore_dup_key <>0 THEN ', ignore duplicate keys' ELSE '' END
				+ CASE WHEN is_unique=1 THEN ', unique' ELSE '' END
				+ CASE WHEN is_hypothetical <>0 THEN ', hypothetical' ELSE '' END
				+ CASE WHEN is_primary_key <>0 THEN ', primary key' ELSE '' END
				+ CASE WHEN is_unique_key <>0 THEN ', unique key' ELSE '' END
				+ CASE WHEN auto_created <>0 THEN ', auto create' ELSE '' END
				+ CASE WHEN no_recompute <>0 THEN ', stats no recompute' ELSE '' END
				+ ' located on ' + groupname),
		'index_keys' = index_keys,
		'included_columns' = inc_columns,
		'filter_definition' = filter_definition,
		'columns_in_tree' = cols_in_tree,
		'columns_in_leaf' = cols_in_leaf
		
	FROM #spindtab
	ORDER BY index_id;

	RETURN (0); -- sp_SQLskills_SQL2008_finddupes_helpindex
GO

EXEC sys.sp_MS_marksystemobject 'sp_SQLskills_SQL2008_finddupes_helpindex';
GO
