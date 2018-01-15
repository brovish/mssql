
--Challenge Question 30

--Tuesday’s are “upsell” days for sales people at Adventure Works. Management wants to compare sales from Tuesday to other days of the week to see if the initiative is working. Help monitor the upsell initiative by creating a query to calculate average revenue per order by day of week in 2008.
--Include the following columns with your output: 

--•	Day of week
--•	Revenue 
--•	Orders
--•	Revenue per order

--Notes:

--•	Revenue based on Order Date. 
--•	Tax and freight should not be considered. 
--•	Exclude online orders.


--Hints for Challenge Question 30

--Key Table: Sales.SalesOrderHeader
--Key Column: OnlineOrderFlag
--Key Function: DATENAME

--Solution to Challenge Question 30

SELECT 
	DayCategory =		DATENAME (WEEKDAY, OrderDate)
	,Revenue =			SUM (Subtotal)
	,Orders =			COUNT (*)
	,RevenuePerOrder =	SUM (Subtotal) / COUNT (*)
FROM Sales.SalesOrderHeader
WHERE YEAR (OrderDate) = 2008 AND OnlineOrderFlag = 0
GROUP BY DATENAME (WEEKDAY, OrderDate)
ORDER BY RevenuePerOrder DESC





