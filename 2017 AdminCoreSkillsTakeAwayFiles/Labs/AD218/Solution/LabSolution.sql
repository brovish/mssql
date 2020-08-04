-- AD218 Lab Solution

-- Exercise 4

USE WarehouseManagement;
GO

SELECT * FROM dbo.ACMCinemas; 
GO


UPDATE PopkornKraze.dbo.Cinemas SET TradingName = 'ACM Utopian' WHERE CinemaID = 1;
GO

SELECT * FROM dbo.ACMCinemas; 
GO


SELECT * FROM dbo.ACMCinemas WHERE TradingName NOT LIKE '%ACM%'; 
GO
