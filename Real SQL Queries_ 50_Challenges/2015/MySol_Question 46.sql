USE AdventureWorks2012;

SELECT EMP.BusinessEntityID, PR.FirstName, PR.LastName, EMP.JobTitle, T.Rate * 50 AS BONUS
FROM HumanResources.Employee AS EMP
INNER JOIN Person.Person AS PR ON PR.BusinessEntityID = EMP.BusinessEntityID
INNER JOIN (SELECT EPH.BusinessEntityID, EPH.RateChangeDate , EPH.Rate
					, ROW_NUMBER() OVER(PARTITION BY EPH.BusinessEntityID ORDER BY EPH.RateChangeDate DESC) AS RN
				FROM HumanResources.EmployeePayHistory AS EPH 
				) AS T ON T.BusinessEntityID = EMP.BusinessEntityID AND T.RN = 1 
WHERE EMP.SalariedFlag = 1
