
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



