/*============================================================================
  File: ExtendedEvents_Azure.sql

  SQL Server Versions:  Azure SQL Database
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
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
	Azure SQL DB
*/
SELECT @@VERSION;
GO

SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'event'
ORDER BY name;
GO

SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'pred_source'
ORDER BY name;
GO

SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'action'
ORDER BY name;
GO

SELECT name, description
FROM sys.dm_xe_objects
WHERE object_type = 'target'
ORDER BY name;
GO


IF NOT EXISTS
    (SELECT * FROM sys.symmetric_keys
        WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '0C34C960-6621-4682-A123-C7EA08E3FC46' -- Or any newid().
END
GO

/* 
	Need Azure StorageAccount name (xefiletarget), and the associated Container name (xedemo)
	For Storage Account: use '.blob.',   and not '.queue.' or '.table.' etc.
*/
IF EXISTS
    (SELECT * FROM sys.database_scoped_credentials
        WHERE name = 'https://xefiletarget.blob.core.windows.net/xedemo')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL
       [https://xefiletarget.blob.core.windows.net/xedemo] ;
END
GO


/* 
	Need Azure StorageAccount name (xefiletarget), and the associated Container name (xedemo)
	Also need the Shared Access Signature (SAS) key for the container
	For the SECRET: Paste in the long SasToken string, but exclude any leading '?'
*/
CREATE
    DATABASE SCOPED
    CREDENTIAL
        [https://xefiletarget.blob.core.windows.net/xedemo]
    WITH
        IDENTITY = 'SHARED ACCESS SIGNATURE',  -- "SAS" token.
        SECRET = 'sp=racwdl&st=2021-04-13T01:26:35Z&se=2021-04-23T09:26:35Z&sv=2020-02-10&sr=c&sig=FvlyNjUVwtPPhOy%2BHNjEy0xB3gSuDpRo9UGWnOMIDlI%3D'
    ;
GO


CREATE EVENT SESSION [XEAzure_Queries] 
	ON DATABASE 
ADD EVENT sqlserver.sp_statement_completed,
ADD EVENT sqlserver.sql_statement_completed
ADD TARGET package0.event_file(
	SET filename=N'https://xefiletarget.blob.core.windows.net/xedemo/xeazurequeries2.xel',
	max_file_size=(128)
	)
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO

ALTER EVENT SESSION [XEAzure_Queries]
	ON DATABASE
	STATE = START;
GO

/*
	Run some queries
*/

SELECT *
FROM Application.People;
GO

SELECT TOP 100 *
FROM Sales.Orders;
GO

SELECT TOP 10 *
FROM Sales.OrderLines
WHERE StockItemID = 42;
GO

/*
	Stop the event session
*/
ALTER EVENT SESSION [XEAzure_Queries]
	ON DATABASE
	STATE = STOP;
GO


/*
	How to view the data?
	Use the portal, or...
	(need to get the filename from the portal)
*/
SELECT 
	event_data = CONVERT(XML, event_data)
INTO #xetarget
FROM sys.fn_xe_file_target_read_file (
	'https://xefiletarget.blob.core.windows.net/xedemo/xeazurequeries_0_132627516365390000.xel',
	null, null, null
	);
GO

SELECT *
FROM #xetarget;
GO

SELECT
	event_data.value(N'(event/@timestamp)[1]', N'datetime') AS [timestamp],
	event_data.value(N'(event/data[@name=''duration'']/value)[1]', 'int') AS [duration],
	event_data.value(N'(event/data[@name=''cpu_time'']/value)[1]', 'int') AS [cpu_time],
	event_data.value(N'(event/data[@name=''logical_reads'']/value)[1]', 'int') AS [logical_reads],
	event_data.value(N'(event/data[@name=''statement'']/value)[1]', N'nvarchar(max)') AS [statement]
FROM #xetarget
ORDER BY [timestamp];
GO

DROP TABLE #xetarget;
GO

/*
	Clean up
*/
DROP EVENT SESSION [XEAzure_Queries] 
	ON DATABASE;
GO