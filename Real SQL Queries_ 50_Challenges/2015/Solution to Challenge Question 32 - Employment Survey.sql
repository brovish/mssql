USE AdventureWorks2012;
--Solution to Challenge Question 32: Employment Survey


-- Part I
SELECT 
	Employees =		COUNT (*)
	,[%Male] =		ROUND (SUM (CASE WHEN Gender = 'M' THEN 1 ELSE 0 END) / CONVERT (FLOAT, COUNT (*)) * 100, 2)
	,[%Female] =	ROUND (SUM (CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) / CONVERT (FLOAT, COUNT (*)) * 100, 2)
	,AvgMonthsEmp =	AVG (DATEDIFF (MONTH, HireDate, SYSDATETIME()))
FROM HumanResources.Employee

-- Part II
SELECT
	X1.Quartile
	,Employees =	COUNT (*)
	,[%Male] =		ROUND (SUM (CASE WHEN X1.Gender = 'M' THEN 1 ELSE 0 END) / CONVERT (FLOAT, COUNT (*)) * 100, 2)
	,[%Female] =	ROUND (SUM (CASE WHEN X1.Gender = 'F' THEN 1 ELSE 0 END) / CONVERT (FLOAT, COUNT (*)) * 100, 2)
	,AvgMonthsEmp =	AVG (X1.MonthsEmployed)
FROM (SELECT 
		BusinessEntityID
		,Quartile =			NTILE (4) OVER (ORDER BY DATEDIFF (MONTH, HireDate, SYSDATETIME()))
		,HireDate
		,MonthsEmployed  =	DATEDIFF (MONTH, HireDate, SYSDATETIME())
		,Gender
		FROM HumanResources.Employee) X1
GROUP BY X1.Quartile







