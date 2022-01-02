-- Setup Event Notification for Deadlock Capture
USE [msdb];
GO

--  Create a service broker queue to hold the events
CREATE QUEUE [DeadlockGraphQueue];
GO

--  Create a service broker service receive the events
CREATE SERVICE [DeadlockGraphService]
ON QUEUE [DeadlockGraphQueue] ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO

-- Create the event notification for deadlock graphs on the service
CREATE EVENT NOTIFICATION [CaptureDeadlocks]
ON SERVER
WITH FAN_IN
FOR DEADLOCK_GRAPH
TO SERVICE N'DeadlockGraphService', N'current database';
GO

-- Query the catalog to see the notification
SELECT * 
FROM [sys].[server_event_notifications];

