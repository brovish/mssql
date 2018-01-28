USE AdventureWorks2012;

SELECT 
		CASE 
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 1000 THEN 1
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt >1000 AND SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 5000 THEN 2
			ELSE 3
		END
		,CASE 
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 1000 THEN 'LESS THAN 1000'
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt >1000 AND SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 5000 THEN 'LESS THAN 5000'
			ELSE 'MORE THAN 5000'
		END
		,COUNT(*)
FROM Sales.SalesOrderHeader AS SOH
WHERE SOH.OrderDate >= '20120101' AND SOH.OrderDate < '20130101'
GROUP BY
		CASE 
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 1000 THEN 1
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt >1000 AND SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 5000 THEN 2
			ELSE 3
		END
		,CASE 
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 1000 THEN 'LESS THAN 1000'
			WHEN SOH.SubTotal + SOH.Freight + SOH.TaxAmt >1000 AND SOH.SubTotal + SOH.Freight + SOH.TaxAmt < 5000 THEN 'LESS THAN 5000'
			ELSE 'MORE THAN 5000'
		END