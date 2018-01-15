
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution to Challenge Question 43: Calendar of Work Days

--DROP TABLE HumanResources.Calendar

CREATE TABLE HumanResources.Calendar 
	(DateID INT
	,[Date] DATETIME
	,[Year] INT
	,TextMonth VARCHAR (50)
	,DateMonth DATETIME
	,[DayOfWeek] VARCHAR (50)
	,IsBusinessDay TINYINT)

DECLARE @StartDate DATETIME = '1990-01-01'
DECLARE @EndDate DATETIME = '2015-01-01'

DECLARE @TotalDays INT = DATEDIFF (DAY, @StartDate, @EndDate) + 1                 ;

DECLARE @Index INT = 1

WHILE @Index <= @TotalDays
BEGIN
	INSERT INTO HumanResources.Calendar (DateID)
	SELECT @Index
	SET @Index = @Index + 1
END

UPDATE N1
SET [Date] = DATEADD (DAY, DateID - 1, @StartDate)
FROM HumanResources.Calendar N1

UPDATE N1 
	SET
		[Year] =			YEAR ([Date])
		,TextMonth	=		DATENAME (MONTH, [Date]) + ' ' + DATENAME (YEAR, [Date])
		,DateMonth	=		DATEADD (MONTH, DATEDIFF (MONTH, 0, [Date]), 0)
		,[DayOfWeek] =		DATENAME (DW, [Date])
		,IsBusinessDay =	CASE WHEN DATENAME (DW, [Date]) IN ('Saturday', 'Sunday')
								THEN 0 ELSE 1 END
FROM HumanResources.Calendar N1

SELECT
	[Year]
	,BusinessDays = SUM (IsBusinessDay)
FROM HumanResources.Calendar
GROUP BY [Year]
ORDER BY [Year]

-- Solution to Challenge Question 44: Annual Salaries by Employee

--DROP TABLE #EmployeePayHistory

SELECT *
	,BusinessEntityOrder =	ROW_NUMBER () OVER (PARTITION BY BusinessEntityID 
												ORDER BY RateChangeDate)

	,RateEndDate =			CONVERT (DATETIME, NULL)
	,BusinessDays =			CONVERT (INT, NULL)
INTO #EmployeePayHistory
FROM HumanResources.EmployeePayHistory 

UPDATE N1 
	SET	RateEndDate	=		(SELECT TOP 1 RateChangeDate
								FROM #EmployeePayHistory X1
								WHERE N1.BusinessEntityID = X1.BusinessEntityID
									AND X1.BusinessEntityOrder = N1.BusinessEntityOrder + 1         
								ORDER BY X1.RateChangeDate)
FROM #EmployeePayHistory N1


UPDATE N1 
	SET BusinessDays =		(SELECT COUNT (*)
								FROM HumanResources.Calendar X1
								WHERE X1.[Date] BETWEEN N1.RateChangeDate 
									AND ISNULL (N1.RateEndDate, '2009-01-01')
								AND X1.IsBusinessDay = 1)
FROM #EmployeePayHistory N1

--DROP TABLE #EmployeePayCalendar

SELECT *
	,DailyPay = Rate * 8
INTO #EmployeePayCalendar
FROM #EmployeePayHistory N1
INNER JOIN HumanResources.Calendar N2 ON 1 = 1
	AND N2.[Date] >= N1.RateChangeDate 
	AND N2.[Date] < ISNULL (N1.RateEndDate, '2009-01-01')                               
	AND N2.IsBusinessDay = 1

SELECT
	BusinessEntityID
	,WorkingYear =	[Year]
	,TotalPay =		SUM (DailyPay)
FROM #EmployeePayCalendar
WHERE [Year] BETWEEN 2005 AND 2008
GROUP BY BusinessEntityID, [Year]
ORDER BY BusinessEntityID, [Year]

-- Solution to Challenge Question 45: Annual Salaries by Department

--DROP TABLE #EmployeePayDepartmentCalendar

SELECT
	N1.DepartmentID
	,N1.StartDate
	,N1.EndDate
	,N2.*
INTO #EmployeePayDepartmentCalendar
FROM HumanResources.EmployeeDepartmentHistory N1
LEFT JOIN #EmployeePayCalendar N2 ON 1 = 1
			AND N1.BusinessEntityID = N2.BusinessEntityID
			AND N2.[Date] BETWEEN N1.StartDate AND ISNULL (N1.EndDate, '2009-01-01')

--DROP TABLE #DepartmentEmployeeSummary

SELECT
	DepartmentID
	,BusinessEntityID
	,TotalPay =			SUM (DailyPay)
INTO #DepartmentEmployeeSummary
FROM #EmployeePayDepartmentCalendar
WHERE [Year] = 2008
GROUP BY DepartmentID, BusinessEntityID

SELECT
	DepartmentID
	,MinSalary = MIN (TotalPay)
	,AvgSalary = AVG (TotalPay)
	,MaxSalary = MAX (TotalPay)
FROM #DepartmentEmployeeSummary
GROUP BY DepartmentID






