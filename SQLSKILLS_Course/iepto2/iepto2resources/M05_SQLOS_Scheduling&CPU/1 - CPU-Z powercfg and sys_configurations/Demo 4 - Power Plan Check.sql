
-- Run powercfg.cpl

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE
GO

EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE
GO

EXEC master.dbo.xp_cmdshell 'powercfg /list';

EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE
GO

EXEC sp_configure 'show advanced options', 0;
RECONFIGURE
GO

/*
NULL
Existing Power Schemes (* Active)
-----------------------------------
Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance) *
Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
NULL
*/

-- Don't forget about BIOS settings (non-high performance is common)
-- 
-- Don't forget about Group Policy enforcement
-- Server Manager -> Features -> Group Policy Management ->
-- Forest -> Domain -> sqlskillsdemos.com ->
-- Default Domain Policy -> Settings tab -> Administrative Templates -> System / Power Management

-- Greg Gonzalez Group Policy Post (recommended reading):
-- http://greg.blogs.sqlsentry.net/2011/01/ensuring-maximum-cpu-performance-via.html




