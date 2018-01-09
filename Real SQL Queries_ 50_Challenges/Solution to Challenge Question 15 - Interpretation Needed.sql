/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution to Challenge Question 15: Interpretation Needed

SELECT
	N2.ProductModelID
	,ProductModel =		N3.Name
	,N1.[Description]
	,[Language] =		N4.Name
FROM Production.ProductDescription N1
INNER JOIN Production.ProductModelProductDescriptionCulture N2 
	ON N1.ProductDescriptionID = N2.ProductDescriptionID
INNER JOIN Production.ProductModel N3 ON N2.ProductModelID = N3.ProductModelID
INNER JOIN Production.Culture N4 ON N2.CultureID = N4.CultureID
WHERE N4.Name <> 'English'