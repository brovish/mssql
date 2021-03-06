
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 21: Marketing Employees

SELECT 
	N3.FirstName
	,N3.LastName
	,N4.JobTitle
	,N4.BirthDate
	,N4.MaritalStatus
	,N4.HireDate
FROM HumanResources.EmployeeDepartmentHistory N1
INNER JOIN HumanResources.Department N2 ON N1.DepartmentID = N2.DepartmentID
INNER JOIN Person.Person N3 ON N1.BusinessEntityID = N3.BusinessEntityID
INNER JOIN HumanResources.Employee N4 ON N1.BusinessEntityID = N4.BusinessEntityID
WHERE N2.[Name] = 'Marketing'
	AND ((YEAR (N4.HireDate) < 2002) OR YEAR (N4.HireDate) > 2004)
	AND N1.EndDate IS NULL



