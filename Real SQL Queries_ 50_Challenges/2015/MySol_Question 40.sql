USE AdventureWorks2012;

SELECT CASE 
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 1000 THEN 1  
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 5000 THEN 1 
			ELSE 0
		END
FROM Sales.SalesOrderHeader AS SOH
WHERE SOH.OrderDate >= '20120101' AND SOH.OrderDate < '20130101'