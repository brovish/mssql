
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 24: Clearance Sale

WITH Email AS
(SELECT
	N1.BusinessEntityID
	,N1.EmailAddress
	,EmailPref = CASE 
					WHEN N2.EmailPromotion = 0 THEN 
						'Contact does not wish to receive e-mail promotions'
					WHEN N2.EmailPromotion = 1 THEN 
						'Contact does wish to receive e-mail promotions from AdventureWorks'
					WHEN N2.EmailPromotion = 2 THEN 
						'Contact does wish to receive e-mail promotions from AdventureWorks and selected partners' 
					END
FROM Person.EmailAddress N1
LEFT JOIN Person.Person N2 ON N1.BusinessEntityID = N2.BusinessEntityID
WHERE N2.PersonType = 'IN')

SELECT 
	EmailPref
	,[Count] = COUNT (*)
FROM Email
GROUP BY EmailPref
ORDER BY COUNT (*) DESC


