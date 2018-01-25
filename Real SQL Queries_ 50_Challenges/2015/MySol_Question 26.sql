USE AdventureWorks2012;

SELECT SP.BusinessEntityID, SP.CommissionPct, SP.Bonus, 
ROW_NUMBER() OVER(ORDER BY SP.CommissionPct DESC, SP.Bonus DESC) AS RANK--COULD HAVE USED DENSE_RANK AS WELL
FROM Sales.SalesPerson AS SP
ORDER BY SP.CommissionPct DESC, SP.Bonus DESC