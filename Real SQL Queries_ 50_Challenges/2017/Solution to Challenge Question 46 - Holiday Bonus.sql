
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution 1 to Challenge Question 46: Holiday Bonus
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
ORDER BY BusinessEntityID

-- Solution 2 to Challenge Question 46: Holiday Bonus

SELECT
	N1.BusinessEntityID
	,N2.FirstName
	,N2.LastName
	,N1.JobTitle
	,Bonus  =	N3.Rate * 50
FROM HumanResources.Employee N1
INNER JOIN Person.Person AS N2 ON N1.BusinessEntityID = N2.BusinessEntityID
INNER JOIN HumanResources.EmployeePayHistory  AS N3 
	ON N1.BusinessEntityID = N3.BusinessEntityID 
		AND N3.RateChangeDate = (SELECT MAX (RateChangeDate)
							     FROM HumanResources.EmployeePayHistory X1
							     WHERE N1.BusinessEntityID = X1.BusinessEntityID)
WHERE N1.SalariedFlag = 1
ORDER BY BusinessEntityID
 
-- Solution 3 to Challenge Question 46: Holiday Bonus

SELECT 
	N1.BusinessEntityID
	,N2.FirstName
	,N2.LastName
	,N1.JobTitle 
	,Bonus =	N4.Rate * 50
FROM HumanResources.Employee N1
INNER JOIN Person.Person AS N2 ON N1.BusinessEntityID = N2.BusinessEntityID
INNER JOIN (SELECT BusinessEntityID, MaxDate = MAX (RateChangeDate)
			FROM HumanResources.EmployeePayHistory
			GROUP BY BusinessEntityID) AS N3 ON N1.BusinessEntityID = N3.BusinessEntityID  
INNER JOIN HumanResources.EmployeePayHistory N4 ON N3.MaxDate = N4.RateChangeDate
											 AND N3.BusinessEntityID = N4.BusinessEntityID
WHERE SalariedFlag = 1
ORDER BY BusinessEntityID

