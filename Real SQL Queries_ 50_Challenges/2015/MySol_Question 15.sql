USE AdventureWorks2012;

SELECT PC.ProductModelID, PD.Description, CL.Name
FROM Production.ProductModelProductDescriptionCulture AS PC 
INNER JOIN Production.ProductDescription AS PD ON PD.ProductDescriptionID = PC.ProductDescriptionID
INNER JOIN Production.Culture AS CL ON CL.CultureID = PC.CultureID
INNER JOIN Production.ProductModel AS PR ON PR.ProductModelID = PC.ProductModelID
WHERE CL.Name <> 'ENGLISH'