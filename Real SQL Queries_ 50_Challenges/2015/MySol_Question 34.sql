USE AdventureWorks2012;

SELECT SP.Name, SUM(SOH.SubTotal + SOH.TaxAmt + SOH.Freight) AS REV
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Person.Address AS AD ON AD.AddressID = SOH.ShipToAddressID
INNER JOIN Person.StateProvince AS SP ON SP.StateProvinceID  = AD.StateProvinceID
WHERE SOH.OrderDate >= '20120101' AND SOH.OrderDate < '20130101'
GROUP BY SP.Name
ORDER BY REV DESC