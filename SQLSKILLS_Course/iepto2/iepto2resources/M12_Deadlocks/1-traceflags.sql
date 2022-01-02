-- Enable trace flag 1222 for the session
DBCC TRACEON(1222);

-- Determine current trace flag statuses
DBCC TRACESTATUS;

-- Disable trace flag 1222 for the session
DBCC TRACEOFF(1222);

-- Enable trace flag 1222 globally
DBCC TRACEON(1222, -1);

-- Determine current trace flag status
DBCC TRACESTATUS;
