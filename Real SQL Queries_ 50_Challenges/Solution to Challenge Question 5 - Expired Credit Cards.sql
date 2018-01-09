/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012


--Solution to Challenge Question 5: Expired Credit Cards

-- Part I

--DROP TABLE #data

SELECT
	N1.CreditCardID
	,N1.CardType
	,ExpDate =			EOMONTH (DATEFROMPARTS (N1.ExpYear, N1.ExpMonth, 1))
	,LastOrderDate =	CAST (N2.LastOrderDate AS DATE)
	,[Orders<=Exp] =	COUNT (DISTINCT N3.SalesOrderID)
	,[Orders>Exp] =		COUNT (DISTINCT N4.SalesOrderID)
INTO #data
FROM Sales.CreditCard N1

LEFT JOIN (SELECT X1.CreditCardID, LastOrderDate = MAX (X1.OrderDate)
			FROM Sales.SalesOrderHeader X1 
			GROUP BY X1.CreditCardID) N2 ON N1.CreditCardID = N2.CreditCardID

LEFT JOIN Sales.SalesOrderHeader N3 ON 1 = 1
	AND N1.CreditCardID = N3.CreditCardID 
	AND N3.OrderDate < = EOMONTH (DATEFROMPARTS (N1.ExpYear, N1.ExpMonth, 1))

LEFT JOIN Sales.SalesOrderHeader N4 ON 1 = 1
	AND N1.CreditCardID = N4.CreditCardID 
	AND N4.OrderDate >  EOMONTH (DATEFROMPARTS (N1.ExpYear, N1.ExpMonth, 1))

GROUP BY 
	N1.CreditCardID
	,N1.CardType
	,N2.LastOrderDate
	,N1.ExpYear
	,N1.ExpMonth

SELECT * 
FROM #data
ORDER BY [Orders>Exp] DESC

--Part II
SELECT 
	CardType
	,[Orders<=Exp] =	SUM ([Orders<=Exp])
	,[Orders>Exp] =		SUM ([Orders>Exp])
FROM #data
GROUP BY CardType


