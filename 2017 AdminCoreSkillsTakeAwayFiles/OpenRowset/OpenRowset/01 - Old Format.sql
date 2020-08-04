USE tempdb;
GO

-- Select all columns

SELECT *
FROM OPENROWSET(BULK 'C:\GregDemo\Demos 2012\OpenRowset\NewProspects.csv', 
                FORMATFILE = 'C:\GregDemo\Demos 2012\OpenRowset\NewProspects.fmt',
	            FIRSTROW = 2) AS a;

-- Select specific columns and rows

SELECT ProspectID, FirstName, LastName
FROM OPENROWSET(BULK 'C:\GregDemo\Demos 2012\OpenRowset\NewProspects.csv', 
                FORMATFILE = 'C:\GregDemo\Demos 2012\OpenRowset\NewProspects.fmt',
	            FIRSTROW = 2) AS a
WHERE LastName LIKE 'Wal%';