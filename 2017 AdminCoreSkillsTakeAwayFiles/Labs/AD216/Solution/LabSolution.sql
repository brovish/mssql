-- AD216 Lab Solution

-- Exercise 2

USE WarehouseManagement;
GO

SELECT * FROM Sales.Currencies;
GO

-- this step will fail
ALTER TABLE Sales.Currencies 
  ADD CONSTRAINT PK_Currencies PRIMARY KEY (CurrencyCode);
GO

ALTER TABLE Sales.Currencies 
  ALTER COLUMN CurrencyCode nvarchar(3) NOT NULL;
GO

ALTER TABLE Sales.Currencies 
  ADD CONSTRAINT PK_Currencies PRIMARY KEY (CurrencyCode);
GO

ALTER TABLE Sales.Currencies 
  ALTER COLUMN CurrencyName nvarchar(50) NOT NULL;
GO

ALTER TABLE Sales.Currencies
  ADD CONSTRAINT UQ_CurrencyName UNIQUE (CurrencyName);
GO


-- Exercise 3

SELECT *
FROM OPENROWSET(BULK 'C:\Labs\AD216\Starter\Currencies.txt', FORMATFILE = 'C:\Labs\AD216\Starter\Currencies.xml', FIRSTROW = 2) AS c;
GO

SELECT CAST(CurrencyCode AS nvarchar(3)) AS CurrencyCode,
       CAST(CurrencyName AS nvarchar(50)) AS CurrencyName,
       CAST(ExchangeRate AS decimal(18,4)) AS ExchangeRate,
       CAST(IsActive AS integer) AS IsActive
FROM OPENROWSET(BULK 'C:\Labs\AD216\Starter\Currencies.txt', FORMATFILE = 'C:\Labs\AD216\Starter\Currencies.xml', FIRSTROW = 2) AS c;
GO

SELECT CAST(CurrencyCode AS nvarchar(3)) AS CurrencyCode,
       CAST(CurrencyName AS nvarchar(50)) AS CurrencyName,
       CAST(ExchangeRate AS decimal(18,4)) AS ExchangeRate,
       CAST(IsActive AS integer) AS IsActive
FROM OPENROWSET(BULK 'C:\Labs\AD216\Starter\Currencies.txt', FORMATFILE = 'C:\Labs\AD216\Starter\Currencies.xml', FIRSTROW = 2) AS c
WHERE CAST(IsActive AS integer) <> 0;
GO

INSERT Sales.Currencies (CurrencyCode, CurrencyName, ExchangeRate)
SELECT CAST(CurrencyCode AS nvarchar(3)) AS CurrencyCode,
       CAST(CurrencyName AS nvarchar(50)) AS CurrencyName,
       CAST(ExchangeRate AS decimal(18,4)) AS ExchangeRate
FROM OPENROWSET(BULK 'C:\Labs\AD216\Starter\Currencies.txt', FORMATFILE = 'C:\Labs\AD216\Starter\Currencies.xml', FIRSTROW = 2) AS c
WHERE CAST(IsActive AS integer) <> 0;
GO

SELECT * FROM Sales.Currencies;
GO
