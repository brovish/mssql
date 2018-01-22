USE AdventureWorks2012;

DEClare @M AS INT =  (SELECT MAX(E.VacationHours) FROM HumanResources.Employee AS E);

SELECT SUBSTRING(EM.NationalIDNumber, LEN(EM.NationalIDNumber) - 3, LEN(EM.NationalIDNumber)), PR.FirstName, PR.LastName, EM.JobTitle,  EM.VacationHours
 FROM HumanResources.Employee AS EM INNER JOIN Person.Person AS PR ON PR.BusinessEntityID = EM.BusinessEntityID
WHERE EM.VacationHours = @M