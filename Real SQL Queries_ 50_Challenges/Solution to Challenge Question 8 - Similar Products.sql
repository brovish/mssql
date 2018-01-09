
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

-- Solution to Challenge Question 8: Similar Products
DECLARE @Today DATE = '2014-01-01';

WITH [Data] AS

(SELECT 
	Base_ProdID =		N1.ProductID
	,Base_Prod_Name =	N1.[Name]
	,Base_Prod_Price =	N1.ListPrice

	,Similar_Product_ID =	(SELECT TOP 1 ProductID
							FROM Production.Product X1
							WHERE N1.ProductSubcategoryID = X1.ProductSubcategoryID
								AND N1.Size = X1.Size
								AND N1.Style = X1.Style
								AND X1.ListPrice < N1.ListPrice
								AND X1.FinishedGoodsFlag = 1
								AND X1.SellStartDate <= @Today
								AND ISNULL (X1.SellEndDate, '9999-12-31') > @Today
							ORDER BY X1.ListPrice DESC)

FROM Production.Product N1
WHERE N1.FinishedGoodsFlag = 1
	AND N1.SellStartDate <= @Today
	AND ISNULL (N1.SellEndDate, '9999-12-31') > @Today)

SELECT
	N1.Base_ProdID
	,N1.Base_Prod_Name
	,N1.Base_Prod_Price
	,Similar_Prod_Price =	N2.ListPrice
	,Similar_Prod_Name =	N2.[Name]
	,Similar_Product_ID
FROM [Data] N1
INNER JOIN Production.Product N2 ON N1.Similar_Product_ID = N2.ProductID
ORDER BY Base_ProdID