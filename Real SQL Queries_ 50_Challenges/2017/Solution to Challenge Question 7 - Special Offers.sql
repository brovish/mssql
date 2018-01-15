
/*

An excerpt from:
Real SQL Queries: 50 Challenges
by Brian Cohen, Neil Pepi, and Neerja Mishra
© 2015, 2017 Brian Cohen, Neil Pepi, and Neerja Mishra.
http://buy.realsqlqueries.com 

*/

USE AdventureWorks2012

-- Solution 1 to Challenge Question 7: Special Offers 
SELECT
	N1.SpecialOfferID
	,N1.[Description] 
	,N1.EndDate
FROM Sales.SpecialOffer N1
LEFT JOIN Sales.SpecialOfferProduct N2 
	ON N1.SpecialOfferID = N2.SpecialOfferID
WHERE N2.SpecialOfferID IS NULL 
	AND N1.DiscountPct > 0
	AND N1.EndDate > '2008-01-01'

------------------

-- Solution 2 to Challenge Question 7: Special Offers
SELECT
	SpecialOfferID
	,[Description] 
	,EndDate
FROM Sales.SpecialOffer N1
WHERE N1.DiscountPct > 0
	AND N1.EndDate > '2008-01-01'
	AND NOT EXISTS (SELECT 1 
			        FROM Sales.SpecialOfferProduct X1
				    WHERE N1.SpecialOfferID = X1.SpecialOfferID);

------------------

-- Solution 3 to Challenge Question 7: Special Offers
WITH [Data] AS 
	(SELECT SpecialOfferID 
	 FROM Sales.SpecialOffer 
	 WHERE DiscountPct > 0 
		AND EndDate > '2008-01-01'
	 
	 EXCEPT
	 
	 SELECT SpecialOfferID 
	 FROM Sales.SpecialOfferProduct)

SELECT
	N1.SpecialOfferID
	,N1.[Description]
	,N1.EndDate
FROM Sales.SpecialOffer N1
INNER JOIN [Data] N2 ON N1.SpecialOfferID = N2.SpecialOfferID