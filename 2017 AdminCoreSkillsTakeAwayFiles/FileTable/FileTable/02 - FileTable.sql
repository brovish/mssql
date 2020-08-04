USE master;
GO

CREATE DATABASE DocumentData
  WITH FILESTREAM
  ( NON_TRANSACTED_ACCESS = FULL,
    DIRECTORY_NAME = N'DocumentData'
  );
GO

ALTER DATABASE DocumentData
  ADD FILEGROUP ExternalAccess_FG
  CONTAINS FILESTREAM;
GO

ALTER DATABASE DocumentData
ADD FILE
(
    NAME= 'ExternalAccess_Files',
    FILENAME = 'C:\ExternalAccess\ExternalAccess_Files'
)
TO FILEGROUP ExternalAccess_FG;
GO

USE DocumentData;
GO

CREATE TABLE SharedFiles AS FILETABLE
  WITH
  ( FILETABLE_DIRECTORY = 'SharedFiles',
    FILETABLE_COLLATE_FILENAME = database_default
  );
GO

-- Open the share and create a file

SELECT * FROM SharedFiles;
GO

USE master;
GO
