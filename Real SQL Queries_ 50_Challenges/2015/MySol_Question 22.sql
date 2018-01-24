USE AdventureWorks2012;

SELECT PRV.ProductReviewID, PRV.ProductID, PR.Name, PRV.ReviewerName, PRV.Rating, PRV.EmailAddress, EA.BusinessEntityID
FROM Production.ProductReview AS PRV 
INNER JOIN Production.Product AS PR ON PR.ProductID = PRV.ProductID
LEFT OUTER JOIN Person.EmailAddress AS EA ON EA.EmailAddress = PRV.EmailAddress 

--INNER JOIN Sales.Customer AS CU ON CU.CustomerID
--ON PRV.EmailAddress = EA.EmailAddress