
--	Solution to Challenge Question 22: Who Left That Review?

SELECT
	N1.ProductReviewID
	,N1.ProductID
	,ProductName =		N2.Name
	,N1.ReviewerName
	,N1.Rating
	,ReviewerEmail =	N1.EmailAddress
	,N3.BusinessEntityID
FROM Production.ProductReview N1
INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
LEFT JOIN Person.EmailAddress N3 ON N1.EmailAddress = N3.EmailAddress

--Execution returns each BusinessEntityID as NULL. It will not be possible to locate sales orders related to product reviews because there are no matches. 
--------------------------------------------------------------------------------------------------------------