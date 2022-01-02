USE [msdb];
GO

IF OBJECT_ID(N'WMI_DeadlockEvents') IS NOT NULL
BEGIN
    DROP TABLE [WMI_DeadlockEvents];
END
GO

-- Create a table to store the deadlock graphs
CREATE TABLE [WMI_DeadlockEvents]
(
	[RowID] INT IDENTITY PRIMARY KEY,
	[DeadlockGraph] XML, 
	[CollectionDate] DATETIME DEFAULT(CURRENT_TIMESTAMP)
) ;
GO

-- Enable job tokens in SQL Agent
EXEC [sp_set_sqlagent_properties]
		@alert_replace_runtime_tokens=1
GO

-- Restart Agent

-- Create a job for the Agent alert to execute
EXECUTE [sp_add_job] 
	@job_name=N'Capture WMI Deadlock Graphs', 
    @enabled=1, 
    @description=N'Captures DEADLOCK_GRAPH events raised by SQL Agent alerts to a table';
GO

-- Add a jobstep to insert the grafph from WMI
EXECUTE [sp_add_jobstep]
    @job_name = N'Capture WMI Deadlock Graphs',
    @step_name=N'Insert graph into WMI_DeadlockEvents',
    @step_id=1, 
    @on_success_action=1, 
    @on_fail_action=2, 
    @subsystem=N'TSQL', 
    @command= N'INSERT INTO WMI_DeadlockEvents
                (DeadlockGraph)
                VALUES (N''$(ESCAPE_SQUOTE(WMI(TextData)))'')',
    @database_name=N'msdb';
GO

-- Set the job server for the job
EXECUTE [sp_add_jobserver] 
	@job_name = N'Capture WMI Deadlock Graphs';
GO

--Add a WMI alert for the DEADLOCK_GRAPH
EXECUTE [sp_add_alert] 
	@name=N'Capture DEADLOCK_GRAPH events', 
	@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
    @wmi_query=N'SELECT * FROM DEADLOCK_GRAPH', 
    @job_name=N'Capture WMI Deadlock Graphs';
GO
