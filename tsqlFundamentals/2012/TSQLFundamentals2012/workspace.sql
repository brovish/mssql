--WITH a AS (SELECT * FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS a(a))
--SELECT TOP(5000000)
--ROW_NUMBER() OVER (ORDER BY a.a) AS OrderItemId
--,a.a + b.a + c.a + d.a + e.a + f.a + g.a + h.a AS OrderId
--,a.a * 10 AS Price
--,CONCAT(a.a, N' ', b.a, N' ', c.a, N' ', d.a, N' ', e.a, N' ', f.a, N' ', g.a, N' ', h.a) AS ProductName
--INTO Table_with_5M_rows
--FROM a, a AS b, a AS c, a AS d, a AS e, a AS f, a AS g, a AS h;

--select * from Table_with_5M_rows
SELECT SUM(Price) FROM Table_with_5M_rows

--CREATE CLUSTERED COLUMNSTORE INDEX Columnstoreindex ON Table_with_5M_rows;

SELECT SUM(Price) FROM Table_with_5M_rows

SELECT SUM(OrderItemId) FROM Table_with_5M_rows



--USE [master];
--GO
--IF DB_ID('RunningTotals') IS NOT NULL
--BEGIN
--	ALTER DATABASE RunningTotals SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--	DROP DATABASE RunningTotals;
--END
--GO
--CREATE DATABASE RunningTotals;
--GO
--USE RunningTotals;
--GO
--SET NOCOUNT ON;
--GO

--CREATE TABLE dbo.SpeedingTickets
--(
--	[Date]      DATE NOT NULL,
--	TicketCount INT
--);
--GO
 
--ALTER TABLE dbo.SpeedingTickets ADD CONSTRAINT pk PRIMARY KEY CLUSTERED ([Date]);
--GO
 
--;WITH x(d,h) AS
--(
--	SELECT TOP (250)
--		ROW_NUMBER() OVER (ORDER BY [object_id]),
--		CONVERT(INT, RIGHT([object_id], 2))
--	FROM sys.all_objects
--	ORDER BY [object_id]
--)
--INSERT dbo.SpeedingTickets([Date], TicketCount)
--SELECT TOP (10000)
--	d = DATEADD(DAY, x2.d + ((x.d-1)*250), '19831231'),
--	x2.h
--FROM x CROSS JOIN x AS x2
--ORDER BY d;
--GO
 
--SELECT [Date], TicketCount
--	FROM dbo.SpeedingTickets
--	ORDER BY [Date];
--GO

SELECT
	st1.[Date],
	st1.TicketCount,
	RunningTotal = SUM(st2.TicketCount)
FROM
	dbo.SpeedingTickets AS st1
INNER JOIN
	dbo.SpeedingTickets AS st2
	ON st2.[Date] <= st1.[Date]
GROUP BY st1.[Date], st1.TicketCount
ORDER BY st1.[Date];

SELECT 
S.Date, S.TicketCount, (SELECT SUM(S1.TicketCount) FROM dbo.SpeedingTickets AS S1 WHERE S1.Date <= S.Date) AS RUNNINGTOTAL
FROM dbo.SpeedingTickets AS S
ORDER BY S.Date


