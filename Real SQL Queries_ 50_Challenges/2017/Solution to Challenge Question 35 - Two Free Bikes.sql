
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 35: Two Free Bikes

--DROP VIEW HumanResources.Vw_Employee_Bicycle_Giveaway

CREATE VIEW HumanResources.Vw_Employee_Bicycle_Giveaway

AS

SELECT TOP 2
	N2.FirstName
	,N2.LastName
	,N1.JobTitle
FROM HumanResources.Employee N1
INNER JOIN Person.Person N2 ON N1.BusinessEntityID = N2.BusinessEntityID

WHERE N1.OrganizationLevel = (SELECT MAX (OrganizationLevel) 
								FROM HumanResources.Employee)
ORDER BY NEWID ()



