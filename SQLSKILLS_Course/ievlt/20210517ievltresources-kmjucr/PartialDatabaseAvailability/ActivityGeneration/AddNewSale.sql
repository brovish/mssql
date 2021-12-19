IF OBJECTPROPERTY(object_id('Sales'), 'IsUserTable') = 1
	BEGIN
		INSERT Sales (SalesPersonID, CustomerID, ProductID, Quantity)
			SELECT
				(SELECT EmployeeID 
					FROM Employees 
					WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) %24, 0), 1) = EmployeeID),
				(SELECT CustomerID 
					FROM Customers 
					WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) *10000 %19760, 0), 1) = CustomerID),
				(SELECT ProductID 
					FROM Products 
					WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) %505, 0), 1) = ProductID),
				ISNULL(NULLIF((datepart(ms, getdate())), 0), 1)

		SELECT @@IDENTITY AS 'SalesID Added'
	END
ELSE
	BEGIN
		RAISERROR('The Sales object does not exist.', 16, 1)
	END