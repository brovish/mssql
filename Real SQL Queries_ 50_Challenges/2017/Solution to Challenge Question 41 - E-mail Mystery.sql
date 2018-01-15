
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 41: E-mail Mystery

SELECT
	N2.PersonType
	,AWEmail =		SUM (CASE WHEN N1.EmailAddress LIKE '%adventure-works%' THEN 1 ELSE 0 END)
	,NotAWEmail =	SUM (CASE WHEN N1.EmailAddress NOT LIKE '%adventure-works%' THEN 1 ELSE 0 END)
	,Total =		COUNT (*)
FROM Person.EmailAddress N1
INNER JOIN Person.Person N2 ON N1.BusinessEntityID = N2.BusinessEntityID
GROUP BY N2.PersonType
ORDER BY Total DESC



