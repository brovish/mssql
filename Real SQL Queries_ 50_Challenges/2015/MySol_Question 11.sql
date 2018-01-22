USE AdventureWorks2012;

SELECT CR.Name, MAX(TaxRate)
 FROM Sales.SalesTaxRate AS ST INNER JOIN Person.StateProvince AS SP ON SP.StateProvinceID = ST.StateProvinceID
 INNER JOIN Person.CountryRegion AS CR ON CR.CountryRegionCode = SP.CountryRegionCode
 GROUP BY CR.Name