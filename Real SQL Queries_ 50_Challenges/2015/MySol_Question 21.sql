USE AdventureWorks2012;

SELECT PR.FirstName, PR.LastName, EM.JobTitle, EM.BirthDate, EM.MaritalStatus, EM.HireDate
FROM HumanResources.Employee AS EM
INNER JOIN Person.Person AS PR ON PR.BusinessEntityID = EM.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDP ON EDP.BusinessEntityID = PR.BusinessEntityID
INNER JOIN HumanResources.Department AS DP ON DP.DepartmentID = EDP.DepartmentID
WHERE (EM.HireDate < '20020101' OR EM.HireDate > '20041231') AND DP.Name = 'Marketing' AND EDP.EndDate IS NULL