/****** Scripting replication configuration. Script Date: 26/06/2013 5:56:51 PM ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Installing the server as a Distributor. Script Date: 26/06/2013 5:56:51 PM ******/
use master
exec sp_adddistributor @distributor = N'SDUPROD', @password = N''
GO
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'C:\SqlData', @log_folder = N'C:\SqlLogs', @log_file_size = 2, @min_distretention = 0, @max_distretention = 72, @history_retention = 48, @security_mode = 1
GO

use [distribution] 
if (not exists (select * from sysobjects where name = 'UIProperties' and type = 'U ')) 
	create table UIProperties(id int) 
if (exists (select * from ::fn_listextendedproperty('SnapshotFolder', 'user', 'dbo', 'table', 'UIProperties', null, null))) 
	EXEC sp_updateextendedproperty N'SnapshotFolder', N'C:\SqlData\MSSQL11.MSSQLSERVER\MSSQL\ReplData', 'user', dbo, 'table', 'UIProperties' 
else 
	EXEC sp_addextendedproperty N'SnapshotFolder', N'C:\SqlData\MSSQL11.MSSQLSERVER\MSSQL\ReplData', 'user', dbo, 'table', 'UIProperties'
GO

exec sp_adddistpublisher @publisher = N'SDUPROD', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'C:\SqlData\MSSQL11.MSSQLSERVER\MSSQL\ReplData', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO
