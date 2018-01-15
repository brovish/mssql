--Solution to Challenge Question 11: Needy Accountant

SELECT
	Country =			N3.Name			
	,MaxTaxRate =		MAX (N1.TaxRate)
FROM Sales.SalesTaxRate N1
INNER JOIN Person.StateProvince N2 ON N1.StateProvinceID = N2.StateProvinceID
INNER JOIN Person.CountryRegion N3 ON N2.CountryRegionCode = N3.CountryRegionCode
GROUP BY N3.Name


