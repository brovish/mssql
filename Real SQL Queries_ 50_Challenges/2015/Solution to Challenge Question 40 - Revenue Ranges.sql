
--Solution to Challenge Question 40: Revenue Ranges

SELECT
	SortID =				CASE
								WHEN TotalDue < 100 THEN 1
								WHEN TotalDue < 500 THEN 2
								WHEN TotalDue < 1000 THEN 3
								WHEN TotalDue < 2500 THEN 4
								WHEN TotalDue < 5000 THEN 5
								WHEN TotalDue < 10000 THEN 6			
								WHEN TotalDue < 50000 THEN 7
								WHEN TotalDue < 100000 THEN 8
								ELSE 9
							END
	,SalesAmountCategory =	CASE
								WHEN TotalDue < 100 THEN '0 - 100'
								WHEN TotalDue < 500 THEN '100 - 500'
								WHEN TotalDue < 1000 THEN '500 - 1,000'
								WHEN TotalDue < 2500 THEN '1,000 - 2,500'
								WHEN TotalDue < 5000 THEN '2,500 - 5,000'
								WHEN TotalDue < 10000 THEN '5,000 - 10,000'
								WHEN TotalDue < 50000 THEN '10,000 - 50,000'
								WHEN TotalDue < 100000 THEN '50,000 - 100,000'   
								ELSE '> 100,000'
							END
	,Orders	=				COUNT (*)
FROM Sales.SalesOrderHeader
WHERE YEAR (OrderDate) = 2005
GROUP BY                                                                              
	CASE
		WHEN TotalDue < 100 THEN 1
		WHEN TotalDue < 500 THEN 2
		WHEN TotalDue < 1000 THEN 3
		WHEN TotalDue < 2500 THEN 4
		WHEN TotalDue < 5000 THEN 5
		WHEN TotalDue < 10000 THEN 6
		WHEN TotalDue < 50000 THEN 7
		WHEN TotalDue < 100000 THEN 8
		ELSE 9
	END
	,CASE
		WHEN TotalDue < 100 THEN '0 - 100'
		WHEN TotalDue < 500 THEN '100 - 500'
		WHEN TotalDue < 1000 THEN '500 - 1,000'
		WHEN TotalDue < 2500 THEN '1,000 - 2,500'
		WHEN TotalDue < 5000 THEN '2,500 - 5,000'
		WHEN TotalDue < 10000 THEN '5,000 - 10,000'
		WHEN TotalDue < 50000 THEN '10,000 - 50,000'
		WHEN TotalDue < 100000 THEN '50,000 - 100,000'
		ELSE '> 100,000'
	END
ORDER BY SortID





