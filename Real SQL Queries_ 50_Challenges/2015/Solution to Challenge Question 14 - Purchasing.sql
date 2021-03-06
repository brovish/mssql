USE AdventureWorks2012;

--Solution to Challenge Question 14: Purchasing

	SELECT  
		N1.ProductID
		,ProductName =		N2.Name
		,N3.OrderDate
		,QuantityOrdered =	SUM (N1.OrderQty) 	 
	FROM Purchasing.PurchaseOrderDetail N1
	INNER JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
	INNER JOIN Purchasing.PurchaseOrderHeader N3 ON N1.PurchaseOrderID = N3.PurchaseOrderID
	--WHERE YEAR (N3.OrderDate) = 2007
	WHERE N3.OrderDate >= '20100101' AND N3.OrderDate < '20120101' 
	GROUP BY N1.Productid, N2.Name, N3.OrderDate
	ORDER BY SUM (N1.OrderQty) DESC