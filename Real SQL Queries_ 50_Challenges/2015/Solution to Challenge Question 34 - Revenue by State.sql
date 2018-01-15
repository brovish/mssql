
--Solution to Challenge Question 34: Revenue by State


SELECT
	[State] =		N3.Name
	,TotalSales =	SUM (N1.TotalDue)
FROM Sales.SalesOrderHeader N1
INNER JOIN Person.[Address] N2 ON N1.ShipToAddressID = N2.AddressID
INNER JOIN Person.StateProvince N3 ON N2.StateProvinceID = N3.StateProvinceID
WHERE YEAR (N1.OrderDate) = 2006
GROUP BY N3.Name
ORDER BY SUM (N1.TotalDue) DESC




