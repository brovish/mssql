/*============================================================================
  File:     DDLTrigger-PreventAllDDL.sql

  Summary:  This script creates an audit table and a DDL trigger to show
			how DDL triggers can prevent accidental data modifications.
			Additionally, this script shows some of the uses of the
			new XML EVENTDATA() function.

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by SQLskills.com

  (c) SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE AdventureWorks;
go
CREATE TABLE AuditDDLOperations
(
	OpID		int				NOT NULL identity	
								CONSTRAINT AuditDDLOperationsPK
									PRIMARY KEY CLUSTERED,
	LoginName	sysname			NOT NULL,
	UserName	sysname			NOT NULL,
	PostTime	datetime		NOT NULL,
	EventType	nvarchar(100)	NOT NULL,
	DDLOp		nvarchar(2000)	NOT NULL
);
GO

CREATE TRIGGER PreventAllDDL
ON DATABASE
WITH ENCRYPTION
FOR DDL_DATABASE_LEVEL_EVENTS
AS 
DECLARE @data XML
SET @data = EVENTDATA()
RAISERROR ('DDL Operations are prohibited on this production database. Please contact ITOperations for proper policies and change control procedures.', 16, -1)
ROLLBACK
INSERT AuditDDLOperations
		(LoginName, 
		 UserName,
		 PostTime,
		 EventType,
		 DDLOp)
VALUES   (SYSTEM_USER, CURRENT_USER, GETDATE(), 
   @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), 
   @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)') ) 
RETURN;
go

--Test the trigger.
CREATE TABLE TestTable (col1 int);
go
DROP TABLE AuditDDLOperations;
GO
SELECT * FROM AuditDDLOperations;
GO
--Drop the trigger.
DROP TRIGGER PreventAllDDL
ON DATABASE;
GO
DROP TABLE AuditDDLOperations;
go
