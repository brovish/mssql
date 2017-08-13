/*============================================================================
  File:     Heap - Table Scan IOs.sql

  Summary:  This script shows the IOs caused by a HEAP that has
			forwarding pointers.

  Date:     June 2006

  Tested for SQL Server Version: 9.00.2047.00 (SP1)
------------------------------------------------------------------------------
  Copyright (C) 2005 Kimberly L. Tripp, SYSolutions, Inc.
  All rights reserved.

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Use a "TestDB" Database with at Least 3-8 MB Free Space.
-- USE TestFGDB
-- go
SET STATISTICS IO OFF
go

-- Turn Graphical Showplan ON (Ctrl+K)
SET NOCOUNT ON
go
IF OBJECTPROPERTY(object_id('dbo.DemoTableHeap'), 'IsUserTable') = 1
	DROP TABLE dbo.DemoTableHeap
go

CREATE TABLE dbo.DemoTableHeap
(
	col1	int	 		identity(100,10),
	col2	datetime 	CONSTRAINT DemoTableHeapCol2Default 
							DEFAULT current_timestamp,
	col3	datetime 	CONSTRAINT DemoTableHeapCol3Default 
							DEFAULT getdate(),
	col4	char(30) 	CONSTRAINT DemoTableHeapCol4Default 
							DEFAULT suser_name(),
	col5	char(30)  	CONSTRAINT DemoTableHeapCol5Default 
							DEFAULT user_name(),
	col6	char(100)  	CONSTRAINT DemoTableHeapCol6Default 
							DEFAULT 'Long text value of "Now is the time for all good men to come to the aid of their country."',
	col7	varchar(200)  	CONSTRAINT DemoTableHeapCol7Default 
							DEFAULT 'short value'
)
go
DECLARE @EndTime	datetime
SELECT @EndTime = dateadd(ss, 60, getdate())
WHILE getdate() <= @EndTime
BEGIN
	INSERT dbo.DemoTableHeap DEFAULT VALUES
END
go

EXEC sp_spaceused 'dbo.DemoTableHeap', true
go
-- Record the RowCount = 144042           
-- Figure out the number of pages by dividing "data" by 8
-- SELECT 30328/8 = 3791
-- This SHOULD MATCH the I/Os shown by SELECT COUNT(*)

SET STATISTICS IO ON
go
SELECT COUNT(*) AS 'RowCount' FROM dbo.DemoTableHeap
go

-- Modify roughly 15% - keep track of the rows affected
UPDATE dbo.DemotableHeap
	SET col7 = 'This is a test to create some fragmentation. The previously small column is now filled to capacity. This is a test to create some fragmentation. The previously small column is now filled to capacity.'
	where col1 % 7 = 0
go
select @@rowcount

-- Keep track of Rows Affected Here = 20577

-- Check the space again and calculate # of Pages
SET STATISTICS IO OFF
go
EXEC sp_spaceused 'dbo.DemoTableHeap', true
go

-- Figure out the number of pages by dividing "data" by 8
-- SELECT 34008/8 = 4251  --  select 13456-4251  
-- This SHOULD MATCH the I/Os shown by SELECT COUNT(*)

-- Does this match the I/Os shown by SELECT COUNT(*)
-- ??
SET STATISTICS IO ON
go
SELECT COUNT(*) AS 'RowCount' FROM dbo.DemoTableHeap
go

-- What does is equal?
-- Pages + Rows Modified that caused Forwarding Pointers
-- Do the math Total I/Os - Pages in Table = ???
-- SELECT 3690 - 1167 = 2523
-- So what does that number represent?

-- Forwarding Pointers!
-- A Forwarding Pointer is ALWAYS honored. This is a good thing for most operations
-- however, it is seemingly wrong for a table scan.


-- To confirm (this command ONLY works in SQL Server 2005)
SELECT 'SAMPLED' AS Type, * 
	FROM sys.dm_db_index_physical_stats(db_id(), object_id('dbo.DemoTableHeap'), DEFAULT, DEFAULT, 'SAMPLED')
UNION ALL
SELECT 'LIMITED', * 
	FROM sys.dm_db_index_physical_stats(db_id(), object_id('dbo.DemoTableHeap'), DEFAULT, DEFAULT, 'LIMITED')
	-- Limited doesn't return
UNION ALL
SELECT 'DETAILED', * 
	FROM sys.dm_db_index_physical_stats(db_id(), object_id('dbo.DemoTableHeap'), DEFAULT, DEFAULT, 'DETAILED')
go

SELECT p.* 
FROM sys.partitions AS p
WHERE [object_id] = object_id('DemoTableHeap')