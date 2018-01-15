
--Solution to Challenge Question 42: The Mentors

WITH SalesGrouping AS
	(SELECT 
		SalesPersonID
		,SalesTotal =				SUM (SubTotal)
		,SalesRankSubTotalDESC =	ROW_NUMBER () OVER (ORDER BY SUM (Subtotal) DESC)
		,SalesRankSubTotalASC =		ROW_NUMBER () OVER (ORDER BY SUM (Subtotal))
	FROM Sales.SalesOrderHeader
	WHERE YEAR (OrderDate) = 2008 AND SalesPersonID IS NOT NULL
	GROUP BY SalesPersonID)

SELECT TOP 5
	SuccessSalesPersonID =		N1.SalesPersonID
	,SuccessRevenue =			N1.SalesTotal
	,UnsuccessSalesPersonID =	N2.SalesPersonID
	,UnsuccessRevenue =			N2.SalesTotal
FROM SalesGrouping N1
INNER JOIN SalesGrouping N2 ON N1.SalesRankSubTotalDESC = N2.SalesRankSubTotalASC
ORDER BY N1.SalesRankSubTotalDESC



