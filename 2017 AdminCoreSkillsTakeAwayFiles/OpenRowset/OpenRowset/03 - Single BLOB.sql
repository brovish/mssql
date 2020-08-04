USE tempdb;
GO

-- Note the returned column

SELECT *
FROM OPENROWSET(BULK 'C:\GregDemo\Demos 2012\OpenRowset\CartoonGreg.jpg',
                SINGLE_BLOB) AS p;
GO


-- Insert into a table from bulk data

CREATE TABLE StaffPhotos
( StaffID int PRIMARY KEY,
  StaffName varchar(35) NOT NULL,
  StaffPhoto varbinary(max) NULL
);
GO

INSERT StaffPhotos (StaffID, StaffName, StaffPhoto)
SELECT 1,'Greg',BulkColumn
FROM OPENROWSET(BULK 'C:\GregDemo\Demos 2012\OpenRowset\CartoonGreg.jpg',
                SINGLE_BLOB) AS p;
GO

SELECT * FROM StaffPhotos;

