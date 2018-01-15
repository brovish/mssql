
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--	Solution to Challenge Question 22: Who Left That Review?

SELECT
	N1.ProductReviewID
	,N1.ProductID
	,ProductName =		N2.[Name]
	,N1.ReviewerName
	,N1.Rating
	,ReviewerEmail =	N1.EmailAddress
	,N3.BusinessEntityID
FROM Production.ProductReview N1
INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
LEFT JOIN Person.EmailAddress N3 ON N1.EmailAddress = N3.EmailAddress

--Execution returns each BusinessEntityID as NULL. It will not be possible to locate sales orders related to product reviews because there are no matches. 
--------------------------------------------------------------------------------------------------------------