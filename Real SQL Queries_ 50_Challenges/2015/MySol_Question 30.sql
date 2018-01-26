USE AdventureWorks2012;

SELECT SF.Name, DP.Name, COUNT(EM.BusinessEntityID)
FROM HumanResources.Shift AS SF
INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH ON EDH.ShiftID = SF.ShiftID
INNER JOIN HumanResources.Department AS DP ON DP.DepartmentID = EDH.DepartmentID
INNER JOIN HumanResources.Employee AS EM ON EM.BusinessEntityID = EDH.BusinessEntityID
WHERE EDH.EndDate IS NULL
GROUP BY SF.Name, DP.Name
HAVING DP.Name = 'PRODUCTION'--MOVING IT TO WHERE CLAUSE WOULD HAVE BEEN MORE EFFICIENT