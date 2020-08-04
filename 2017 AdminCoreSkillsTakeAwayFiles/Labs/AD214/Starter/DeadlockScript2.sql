USE PopkornKraze;
GO

BEGIN TRAN;

UPDATE dbo.Products SET Description = 'Modified' WHERE ProductID = (SELECT MAX(ProductID) FROM dbo.Products);

WAITFOR DELAY '0:00:20';

UPDATE dbo.Products SET Description = 'Modified' WHERE ProductID = (SELECT MIN(ProductID) FROM dbo.Products);

COMMIT;
