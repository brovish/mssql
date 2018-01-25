USE AdventureWorks2012;

SELECT EM.BusinessEntityID, EM.LoginID
	,SUBSTRING(EM.LoginID, 0, CHARINDEX('\', EM.LoginID))
	,SUBSTRING(EM.LoginID, CHARINDEX('\', EM.LoginID) + 1, LEN(EM.LoginID))
FROM HumanResources.Employee AS EM 
ORDER BY BusinessEntityID
