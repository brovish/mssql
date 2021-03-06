
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
? 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution for Challenge Question 28: Revenue Trended

DECLARE @StartDate DATE = '2008-05-01'
DECLARE @EndDate DATE = '2008-05-23'

-- Part I: 
SELECT
	DaysInMonthSoFar =			DATEDIFF (day, @StartDate, @EndDate) + 1 
	,RevenueInMonthSoFar =		SUM (SubTotal)
	,RevPerDayforMonthSoFar =	(SUM (SubTotal) / (DATEDIFF (day, @StartDate, @EndDate) + 1))
	,DaysInMonth =				DAY (EOMONTH (@StartDate))

	,MonthlyRevTrended =		SUM (SubTotal) / (DATEDIFF (day, @StartDate, @EndDate) + 1)  
								* DAY (EOMONTH (@StartDate))

FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN @StartDate AND @EndDate


-- Part II:
SELECT
	ActualPerDay =	SUM (SubTotal) / DAY (EOMONTH (@StartDate))
	,ActualRev =	SUM (Subtotal)
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN @StartDate AND EOMONTH (@EndDate)