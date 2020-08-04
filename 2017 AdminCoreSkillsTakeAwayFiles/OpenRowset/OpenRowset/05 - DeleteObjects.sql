USE tempdb;
GO

IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'StaffPhotos')
BEGIN
  DROP TABLE StaffPhotos;
END;