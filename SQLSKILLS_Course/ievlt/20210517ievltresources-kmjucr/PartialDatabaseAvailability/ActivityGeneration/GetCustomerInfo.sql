SELECT CustomerID, 
		Firstname + N' ' + ISNULL(NULLIF(MiddleInitial + '. ', '. '), '') + LastName AS [CustomerName]
FROM Customers 
WHERE CustomerID = datepart(ms, getdate())*10000%19759 + 1