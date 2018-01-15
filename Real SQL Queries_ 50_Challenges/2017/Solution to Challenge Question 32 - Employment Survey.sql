
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 32: Employment Survey

-- Part I
SELECT 
	Employees =		COUNT (*)
	,[%Male] =		ROUND (SUM (CASE WHEN Gender = 'M' THEN 1 ELSE 0 END) / CONVERT (FLOAT, COUNT (*)) * 100, 2)
	,[%Female] =	ROUND (SUM (CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) / CONVERT (FLOAT, COUNT (*)) * 100, 2)
	,AvgMonthsEmp =	AVG (DATEDIFF (MONTH, HireDate, '2008-01-01'))
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
		,Quartile =			NTILE (4) OVER (ORDER BY DATEDIFF (MONTH, HireDate, '2008-01-01'))
		,HireDate
		,MonthsEmployed  =	DATEDIFF (MONTH, HireDate, '2008-01-01')
		,Gender
		FROM HumanResources.Employee) X1
GROUP BY X1.Quartile