USE AdventureWorks2008R2;
GO

SET NOCOUNT ON;

WHILE (1=1)
BEGIN
	SELECT * FROM Sales.SalesOrderDetailEnlarged sod INNER JOIN Production.Product p ON sod.ProductID = p.ProductID ORDER BY Style;
END;
GO

dbcc checkdb



