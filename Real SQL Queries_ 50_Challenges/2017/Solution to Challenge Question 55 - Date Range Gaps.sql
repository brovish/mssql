
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution 1 to Challenge Question 55: Date Range Gaps

WITH [Data] AS

(SELECT
	ProductID
	,StartDate
	,EndDate
	,Days_to_Next_Start = 
		ISNULL (DATEDIFF (DAY, EndDate, 
			LEAD (StartDate) OVER (PARTITION BY ProductID ORDER BY StartDate)), 0)
FROM Production.ProductListPriceHistory)

SELECT ProductID 
FROM [Data] 
WHERE Days_to_Next_Start > 1;

-- No date range gaps exist. 

-- Solution 2 to Challenge Question 55: Date Range Gaps

WITH 
	[Data] AS
		(SELECT
			ProductID
			,StartDate
			,EndDate
			,Instance = ROW_NUMBER () OVER (PARTITION BY N1.ProductID ORDER BY N1.StartDate)
		FROM Production.ProductListPriceHistory N1)

	,[Data2] AS
		(SELECT
			N1.*
			,Days_to_Next_Start = ISNULL (DATEDIFF (DAY, N1.EndDate, N2.StartDate), 0)
		FROM [Data] N1
		LEFT JOIN [Data] N2 ON N1.ProductID = N2.ProductID 
							AND N2.Instance = N1.Instance + 1)
SELECT ProductID
FROM [Data2]
WHERE Days_to_Next_Start > 1
-- No date range gaps exist. 