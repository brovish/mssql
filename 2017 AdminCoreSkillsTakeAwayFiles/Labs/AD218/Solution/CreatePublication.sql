use [PopkornKraze]
exec sp_replicationdboption @dbname = N'PopkornKraze', @optname = N'publish', @value = N'true'
GO
-- Adding the transactional publication
use [PopkornKraze]
exec sp_addpublication @publication = N'ACM_Cinemas', @description = N'Transactional publication of database ''PopkornKraze'' from Publisher ''SDUPROD''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'true', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot @publication = N'ACM_Cinemas', @frequency_type = 4, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1


use [PopkornKraze]
exec sp_addarticle @publication = N'ACM_Cinemas', @article = N'Cinemas', @source_owner = N'dbo', @source_object = N'Cinemas', @type = N'logbased', @description = N'', @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'ACMCinemas', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboCinemas', @del_cmd = N'CALL sp_MSdel_dboCinemas', @upd_cmd = N'SCALL sp_MSupd_dboCinemas', @filter_clause = N'TradingName LIKE ''%ACM%'''

-- Adding the article filter
exec sp_articlefilter @publication = N'ACM_Cinemas', @article = N'Cinemas', @filter_name = N'FLTR_Cinemas_1__56', @filter_clause = N'TradingName LIKE ''%ACM%''', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'ACM_Cinemas', @article = N'Cinemas', @view_name = N'SYNC_Cinemas_1__56', @filter_clause = N'TradingName LIKE ''%ACM%''', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO




