USE PopkornKraze;
GO

DECLARE @Total bigint = 0;

WHILE (1 = 1)
BEGIN
  SELECT @Total += COUNT(*) FROM dbo.Products AS p1 
    CROSS JOIN dbo.Products AS p2;
  IF @Total > 1000000 SET @Total = 0;
END;
