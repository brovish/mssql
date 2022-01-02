SELECT  [dm_tran_active_snapshot_database_transactions].[transaction_id],
        [dm_tran_active_snapshot_database_transactions].[transaction_sequence_num],
        [dm_tran_active_snapshot_database_transactions].[commit_sequence_num],
        [dm_tran_active_snapshot_database_transactions].[session_id],
        [dm_tran_active_snapshot_database_transactions].[is_snapshot],
        [dm_tran_active_snapshot_database_transactions].[first_snapshot_sequence_num],
        [dm_tran_active_snapshot_database_transactions].[max_version_chain_traversed],
        [dm_tran_active_snapshot_database_transactions].[average_version_chain_traversed],
        [dm_tran_active_snapshot_database_transactions].[elapsed_time_seconds]
FROM    [sys].[dm_tran_active_snapshot_database_transactions]
ORDER BY [dm_tran_active_snapshot_database_transactions].[elapsed_time_seconds] DESC;
GO