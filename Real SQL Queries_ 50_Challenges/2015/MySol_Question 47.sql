USE AdventureWorks2012;


SELECT EMP.BusinessEntityID
		,CONCAT(PR.FirstName,' ', PR.LastName, IIF(PR.Suffix IS NOT NULL, CONCAT(',',PR.Suffix, '.'), '.' )) AS FULLN
		,T.DepartmentID
FROM HumanResources.Employee AS EMP
INNER JOIN Person.Person AS PR ON PR.BusinessEntityID = EMP.BusinessEntityID
INNER JOIN (SELECT EPDH.BusinessEntityID, EPDH.DepartmentID, EPDH.StartDate
					, EPDH.EndDate, ROW_NUMBER() OVER(PARTITION BY EPDH.BusinessEntityID ORDER BY EPDH.StartDate DESC) AS RN
				FROM HumanResources.EmployeeDepartmentHistory AS EPDH 
				) AS T ON T.BusinessEntityID = EMP.BusinessEntityID AND T.RN = 1 AND T.EndDate IS NULL
ORDER BY BusinessEntityID 
		