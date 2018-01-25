USE AdventureWorks2012;

--Solution to Challenge Question 29: Separation

SELECT
	BusinessEntityID
	,LoginID
	,Domain =		LEFT (LoginID, CHARINDEX ('\', LoginID, 1) - 1)
	,UserName =		RIGHT (LoginID, LEN (LoginID) - CHARINDEX ('\', LoginID, 1))
FROM HumanResources.Employee
ORDER BY BusinessEntityID



