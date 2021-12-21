/*============================================================================
  File:     Using-DBCC_IND.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows examples of how to use the undocumented
            DBCC IND command as described in Chapter 6 of SQL Server 
            2008 Internals.
  
  Date:     April 2009
  UPDATED:	For SQL Server 2012 and higher with DMV queries
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- In SQL Server 2012 and higher, you can use this query INSTEAD of 
-- creating a worktable / inserting. The remainder of this example
-- is from the Inside SQL Server title for SQL Server 2008.

SELECT [PA].[allocated_page_file_id] AS [PageFID]
, [PA].[allocated_page_page_id] AS [PagePID]
, [PA].[allocated_page_iam_file_id] AS [IAMFID]
, [PA].[allocated_page_iam_page_id] AS [IAMPID]
, [PA].[object_id] AS [ObjectID]
, [PA].[index_id] AS [IndexID]
, [PA].[partition_id] AS [PartitionNumber]
, [PA].[rowset_id] AS [PartitionID]
, [PA].[allocation_unit_type_desc] AS [iam_chain_type]
, [PA].[page_type] AS [PageType]
, [PA].[page_level] AS [IndexLevel]
, [PA].[next_page_file_id] AS [NextPageFID]
, [PA].[next_page_page_id] AS [NextPagePID]
, [PA].[previous_page_file_id] AS [PrevPageFID]
, [PA].[previous_page_page_id] AS [PrevPagePID]
FROM [sys].[dm_db_database_page_allocations]
	(DB_ID(), OBJECT_ID('Employee'), 1, NULL, 'DETAILED') AS [PA]
	CROSS APPLY [sys].[dm_db_page_info]
			([PA].[database_id], [PA].[allocated_page_file_id], [PA].[allocated_page_page_id], 'DETAILED') AS PInf
WHERE [PA].[is_allocated] = 1
ORDER BY [Pinf].[page_type_desc], [IndexLevel] DESC, [PrevPagePID];



------------------------------------------------------------------------------
-- Many examples use the DBCC IND command but change the output in some 
-- way (change the sort or only look at one level - for example). To do this
-- easily, use the sp_TablePages to store the data.
------------------------------------------------------------------------------
USE master;
go

IF OBJECTPROPERTY(object_id('sp_tablepages'), 'IsUserTable') IS NOT NULL
    DROP TABLE sp_tablepages;
go

CREATE TABLE sp_tablepages
(
    PageFID         tinyint,
    PagePID         int,
    IAMFID          tinyint,
    IAMPID          int,
    ObjectID        int,
    IndexID         tinyint,
    PartitionNumber tinyint,
    PartitionID     bigint,
    iam_chain_type  varchar(30),
    PageType        tinyint,
    IndexLevel      tinyint,
    NextPageFID     tinyint,
    NextPagePID     int,
    PrevPageFID     tinyint,
    PrevPagePID     int,
    CONSTRAINT sp_tablepages_PK
        PRIMARY KEY (PageFID, PagePID)
);
go

------------------------------------------------------------------------------
-- How do you use sp_tablepages?
-- Just truncate the table before insert and then select!
------------------------------------------------------------------------------
TRUNCATE TABLE sp_tablepages;
INSERT INTO sp_tablepages
EXEC ('DBCC IND (AdventureWorks2008, [Sales.SalesOrderDetail], -1)');
go

-- More examples in later scripts!
SELECT * 
FROM sp_tablepages
ORDER BY IndexLevel DESC;
go