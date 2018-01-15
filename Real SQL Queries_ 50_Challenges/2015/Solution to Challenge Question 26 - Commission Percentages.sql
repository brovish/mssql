
-- Solution to Challenge Question 26: Commission Percentages


SELECT
	BusinessEntityID
	,CommissionPct
	,Bonus
	,[Rank] = DENSE_RANK () OVER (ORDER BY CommissionPct DESC, Bonus DESC)
FROM Sales.SalesPerson
ORDER BY CommissionPct DESC