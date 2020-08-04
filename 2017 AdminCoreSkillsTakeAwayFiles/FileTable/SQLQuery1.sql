use DocumentData;
go

SELECT DB_NAME(database_id) as DatabaseName, non_transacted_access, non_transacted_access_desc 
FROM sys.database_filestream_options
where DB_NAME(database_id)='DocumentData';
GO

Select DB_NAME ( database_id) as DatabaseName, directory_name
FROM sys.database_filestream_options
where DB_NAME(database_id)='DocumentData';
go


INSERT INTO [dbo].SharedFiles
([name],[file_stream])
SELECT
 'OZTentRV4_Mesh.jpg',
  * FROM OPENROWSET(BULK N'C:\Users\sin17h\Pictures\Saved Pictures\OZTentRV4_Mesh.jpg', SINGLE_BLOB) AS FileData
GO

DECLARE @name varchar(1000);
DECLARE @filetableroot varchar(256)
DECLARE @filepath varchar(1000)
Set @name='New Bitmap Image.bmp';
 
SELECT @filetableroot = FileTableRootPath();
 
--\\DATSUN-BM\SQL2019_FileStream\DocumentData\SharedFiles\New Bitmap Image.bmp
SELECT @filetableroot + file_stream.GetFileNamespacePath() as FILEPATH
FROM [dbo].SharedFiles
WHERE Name = @name;

DECLARE @filePath varchar(max);
--\\DATSUN-BM\SQL2019_FileStream\v02-A60EC2F8-2B24-11DF-9CC3-AF2E56D89593\DocumentData\dbo\SharedFiles\file_stream\FFB7FCA7-16D6-EA11-87AD-CCF9E4C290AB\VolumeHint-HarddiskVolume3
SELECT @filePath = file_stream.PathName()
FROM dbo.SharedFiles
PRINT @filepath

SELECT *
    FROM sys.dm_filestream_non_transacted_handles
    WHERE fcb_id IN
        ( SELECT request_owner_id FROM sys.dm_tran_locks );
GO
