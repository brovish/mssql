
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

--Solution to Challenge Question 37: Overpaying

--DROP TABLE #ProductVendor

SELECT
	ProductID
	,MostExpensivePrice	=		MAX (LastReceiptCost)
	,SecondMostExpensivePrice =	CONVERT (FLOAT,NULL)
	,PercOverSecondPrice =		CONVERT (FLOAT,NULL)
INTO #ProductVendor
FROM Purchasing.ProductVendor
GROUP BY ProductID
HAVING COUNT (DISTINCT LastReceiptCost) > 1

UPDATE N1 
	SET SecondMostExpensivePrice = (SELECT TOP 1 X1.LastReceiptCost
									FROM Purchasing.ProductVendor X1
									WHERE 1 = 1
										AND N1.ProductID = X1.ProductID
										AND N1.MostExpensivePrice <> X1.LastReceiptCost
									ORDER BY X1.LastReceiptCost DESC)
FROM #ProductVendor N1

UPDATE N1 
	SET PercOverSecondPrice = CONVERT (DECIMAL (10,2), 
								CONVERT(FLOAT,(MostExpensivePrice - SecondMostExpensivePrice)) 
												/ SecondMostExpensivePrice)
FROM #ProductVendor N1


SELECT *
FROM #ProductVendor
ORDER BY PercOverSecondPrice DESC