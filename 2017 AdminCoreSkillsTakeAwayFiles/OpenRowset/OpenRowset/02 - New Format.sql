USE tempdb;
GO

SELECT * 
FROM OPENROWSET(BULK 'C:\GregDemo\Demos 2012\OpenRowset\CurrencyExchange.csv', 
                FORMATFILE = 'C:\GregDemo\Demos 2012\OpenRowset\CurrencyExchange.xml',
	            FIRSTROW = 2) AS ce;

SELECT * 
FROM OPENROWSET(BULK 'C:\GregDemo\Demos 2012\OpenRowset\CurrencyExchange.csv', 
                FORMATFILE = 'C:\GregDemo\Demos 2012\OpenRowset\CurrencyExchange.xml',
	            FIRSTROW = 2) AS ce
WHERE ce.CurrencyCode = 'JPY';