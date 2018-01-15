
--Solution to Challenge Question 30: Shift Coverage

SELECT
	DepartmentName	=	N2.Name
	,ShiftName =		N3.Name
	,Employees =		COUNT (*)
FROM HumanResources.EmployeeDepartmentHistory N1
INNER JOIN HumanResources.Department N2 ON N1.DepartmentID = N2.DepartmentID
INNER JOIN HumanResources.[Shift] N3 ON N1.ShiftID = N3.ShiftID
WHERE N2.Name = 'Production'
	AND N1.EndDate IS NULL
GROUP BY N2.Name, N3.Name
ORDER BY N2.Name, N3.Name
