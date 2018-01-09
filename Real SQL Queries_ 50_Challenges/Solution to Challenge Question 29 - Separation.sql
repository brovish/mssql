
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 29: Separation

SELECT
	BusinessEntityID
	,LoginID
	,Domain =		LEFT (LoginID, CHARINDEX ('\', LoginID, 1) - 1)
	,UserName =		RIGHT (LoginID, LEN (LoginID) - CHARINDEX ('\', LoginID, 1))
FROM HumanResources.Employee
ORDER BY BusinessEntityID



