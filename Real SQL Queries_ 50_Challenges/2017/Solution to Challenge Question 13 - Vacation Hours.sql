
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
? 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 13: Vacation Hours


WITH MaxVacHrs AS 
	(SELECT MaxVacHrs = MAX (VacationHours) FROM HumanResources.Employee)
SELECT 
	NationalID =	RIGHT (N1.NationalIDNumber, 4)
	,N2.FirstName
	,N2.LastName
	,N1.JobTitle
	,N1.VacationHours
FROM HumanResources.Employee N1
INNER JOIN Person.Person N2 ON N1.BusinessEntityID = N2.BusinessEntityID
INNER JOIN MaxVacHrs N3 ON N1.VacationHours = N3.MaxVacHrs