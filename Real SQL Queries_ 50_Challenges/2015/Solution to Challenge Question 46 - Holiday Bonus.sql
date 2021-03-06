USE AdventureWorks2012;
-- Solution for Challenge Question 46: Holiday Bonus

SELECT
	N1.BusinessEntityID
	,N2.FirstName
	,N2.LastName
	,N1.JobTitle

	,Bonus  =		(SELECT TOP 1 Rate	
					FROM HumanResources.EmployeePayHistory X1
					WHERE N1.BusinessEntityID = X1.BusinessEntityID
					ORDER BY RateChangeDate DESC) * 50

FROM HumanResources.Employee N1
INNER JOIN Person.Person AS N2 ON N1.BusinessEntityID = N2.BusinessEntityID
WHERE N1.SalariedFlag = 1
ORDER BY N1.BusinessEntityID






