USE AdventureWorks2012;

--Solution to Challenge Question 47: Company Picnic

SELECT 
	N1.BusinessEntityID
	,FullName =	CONVERT (VARCHAR (50), FirstName) + ' ' + CONVERT (VARCHAR (50), LastName) + ISNULL (', ' + Suffix, '')
	,Dept =		N4.Name
FROM Person.Person N1
INNER JOIN (SELECT BusinessEntityID
					,MaxStart = MAX (StartDate) 
			FROM HumanResources.EmployeeDepartmentHistory
			GROUP BY BusinessEntityID) N2 ON N1.BusinessEntityID = N2.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory N3 
			ON N2.MaxStart = N3.StartDate AND N2.BusinessEntityID = N3.BusinessEntityID
INNER JOIN HumanResources.Department N4 ON N3.DepartmentID = N4.DepartmentID
WHERE N1.PersonType IN ('SP', 'EM') 
--ORDER BY Dept, FullName
ORDER BY BusinessEntityID

