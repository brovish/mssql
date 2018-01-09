
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 33: Age Groups
 
SELECT 
	N1.JobTitle

	,AgeGroup =			CASE 
							WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 18 THEN '< 18'
							WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 35 THEN '18 - 35'
				   			WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 50 THEN '36 - 50'
							WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 60 THEN '51 - 60'
							ELSE '61 +' END

		,N2.Rate
		,Employees =	COUNT (N1.BusinessEntityID)
FROM HumanResources.Employee N1
INNER JOIN HumanResources.EmployeePayHistory N2 ON N1.BusinessEntityID = N2.BusinessEntityID 
   
INNER JOIN (SELECT BusinessEntityID, RatechangeDate = MAX (RateChangeDate) 
			FROM HumanResources.EmployeePayHistory
			GROUP BY BusinessEntityID) N3
	ON N3.BusinessEntityID = N2.BusinessEntityID AND N3.RatechangeDate = N2.RateChangeDate

GROUP BY 
	JobTitle 
	,Rate
	,CASE 
		WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 18 THEN '< 18'
		WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 35 THEN '18 - 35'
		WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 50 THEN '36 - 50'
		WHEN DATEDIFF (YY, N1.BirthDate, '2008-01-01') < 60 THEN '51 - 60'
		ELSE '61 +' END
