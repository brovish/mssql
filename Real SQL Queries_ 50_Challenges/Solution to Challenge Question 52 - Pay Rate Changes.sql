
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution 1 to Challenge Question 52: Pay Rate Changes

WITH Data AS 
	(SELECT
		BusinessEntityID
		,PayRateNumber =	ROW_NUMBER () OVER (PARTITION BY BusinessEntityID 
												ORDER BY RateChangeDate DESC)
		,RateChangeDate
		,Rate
	FROM HumanResources.EmployeePayHistory)

SELECT
	N1.BusinessEntityID
	,RatePrior =			N2.Rate
	,LatestRate =			N1.Rate
	,PercentChange =		CONVERT (VARCHAR (10), 
								(N1.Rate - N2.Rate) / N2.Rate * 100) + '%'
FROM Data N1
LEFT JOIN Data N2 ON N1.BusinessEntityID = N2.BusinessEntityID 
						AND N2.PayRateNumber = 2
WHERE N1.PayRateNumber = 1;

-- Solution 2 to Challenge Question 52: Pay Rate Changes

WITH [Data] AS 
(SELECT
	BusinessEntityID
	,RateChangeDate
	,Rate_Prior =	LAG (Rate, 1) OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate)
	,Current_Rate = LAST_VALUE (Rate) OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate 
						RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM HumanResources.EmployeePayHistory N1)

SELECT
	BusinessEntityID
	,Rate_Prior
	,Current_Rate
	,PercentChange =	CONVERT (VARCHAR (10), ((Current_Rate - Rate_Prior)/ Rate_Prior) * 100) + '%'
FROM [Data]
WHERE RateChangeDate = (SELECT MAX (RateChangeDate)
						FROM HumanResources.EmployeePayHistory AS X1
						WHERE [Data].BusinessEntityID = X1.BusinessEntityID)