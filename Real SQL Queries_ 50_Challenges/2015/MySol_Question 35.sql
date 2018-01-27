USE AdventureWorks2012;
GO

--CREATE VIEW RANDOMEMPS
--AS
	SELECT TOP(2) PR.FirstName, PR.LastName, EMP.JobTitle
	FROM HumanResources.Employee AS EMP
	INNER JOIN Person.Person AS PR ON PR.BusinessEntityID = EMP.BusinessEntityID
	WHERE EMP.OrganizationLevel = (SELECT MAX(E.OrganizationLevel) FROM HumanResources.Employee AS E)
	ORDER BY NEWID()