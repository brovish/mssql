
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012
GO

-- Solution to Challenge Question 26: Commission Percentages

SELECT
	BusinessEntityID
	,CommissionPct
	,Bonus
	,[Rank] = DENSE_RANK () OVER (ORDER BY CommissionPct DESC, Bonus DESC)
FROM Sales.SalesPerson
ORDER BY CommissionPct DESC