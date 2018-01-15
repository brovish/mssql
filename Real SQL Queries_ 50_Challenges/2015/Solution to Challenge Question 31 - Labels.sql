
-- Solution to Challenge Question 31: Labels

-- Part I
SELECT DISTINCT Size
FROM Production.Product
WHERE ISNUMERIC (Size) = 0 
	AND Size IS NOT NULL

-- The variety of stickers is appropriate for assignment to the company's products. 


-- Part II
SELECT 
	N1.Size
	,CurrentQty =			SUM (N2.Quantity)

	,AdditLabelsNeeded =	CASE
								WHEN SUM (N2.Quantity) - 1000 < 0 
									THEN 0 
								ELSE SUM (N2.Quantity) - 1000 END

FROM Production.Product N1
INNER JOIN Production.ProductInventory N2 ON N1.ProductID = N2.ProductID
WHERE ISNUMERIC (N1.Size) = 0
	AND N1.Size IS NOT NULL 
GROUP BY N1.Size 



