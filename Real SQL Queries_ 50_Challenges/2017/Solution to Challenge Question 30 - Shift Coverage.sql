
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 30: Shift Coverage

SELECT
	DepartmentName	=	N2.[Name]
	,ShiftName =		N3.[Name]
	,Employees =		COUNT (*)
FROM HumanResources.EmployeeDepartmentHistory N1
INNER JOIN HumanResources.Department N2 ON N1.DepartmentID = N2.DepartmentID
INNER JOIN HumanResources.[Shift] N3 ON N1.ShiftID = N3.ShiftID
WHERE N2.[Name] = 'Production'
	AND N1.EndDate IS NULL
GROUP BY N2.[Name], N3.[Name]
ORDER BY N2.[Name], N3.[Name]
