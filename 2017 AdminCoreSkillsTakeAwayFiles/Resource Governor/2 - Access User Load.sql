-- Time to open Performance Monitor
-- Add SQLServer:ResourcePool entries for both new pools and the default pool
-- Show only the CPU% for now

USE RGovernor;
GO

 when is the pool determined?
EXECUTE AS USER = 'AnnoyingAccessUserOnFloor5';
GO

DECLARE @Total bigint = 0;

WHILE (1 = 1)
BEGIN
  SELECT @Total += COUNT(*) FROM dbo.Product AS p1 
    CROSS JOIN dbo.Product AS p2;
  IF @Total > 1000000 SET @Total = 0;
END;

-- disconnect and reconnect as AnnoyingAccessUserOnFloor5
-- try executing code again