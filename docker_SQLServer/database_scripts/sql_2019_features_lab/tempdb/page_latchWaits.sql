USE tempdb;
GO
SELECT d.status, object_name(page_info.object_id), page_info.*
FROM sys.dm_exec_requests AS d
  CROSS APPLY sys.fn_PageResCracker(d.page_resource) AS r
  CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id,'DETAILED')
    AS page_info;
GO

--you should get 3 types of exec requests: suspended, runnable, running
SELECT distinct d.status
FROM sys.dm_exec_requests AS d
  CROSS APPLY sys.fn_PageResCracker(d.page_resource) AS r
  CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id,'DETAILED')
    AS page_info;
GO


