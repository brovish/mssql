USE DeadlockDemo
GO

-- Create a new covering non-clustered index
DROP INDEX [idx_TableA_col2] ON [TableA];
GO
CREATE INDEX [idx_TableA_col2_incol3]
ON [TableA] ([col2])
INCLUDE ([col3]);

-- Test the workload again




-- Replace the index to show read committed snapshot isolation effect
DROP INDEX [idx_TableA_col2_incol3] ON [TableA];
GO
CREATE INDEX [idx_TableA_col2]
ON [TableA] ([col2]);
GO


-- Enable read committed snapshot on the database
ALTER DATABASE [DeadlockDemo] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
ALTER DATABASE [DeadlockDemo] SET ALLOW_SNAPSHOT_ISOLATION ON; 
ALTER DATABASE [DeadlockDemo] SET READ_COMMITTED_SNAPSHOT ON; 
ALTER DATABASE [DeadlockDemo] SET MULTI_USER;
GO

-- Test the workload again