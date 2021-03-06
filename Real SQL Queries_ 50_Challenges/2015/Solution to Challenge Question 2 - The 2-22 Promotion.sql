--Solution to Challenge Question 2: The 2/22 Promotion

--	Part I

--DROP TABLE #data

SELECT
	N1.SalesOrderID
	,ShipToState =			N4.Name
	,OrderDate =			N1.OrderDate
	,[HistoricalOrder$] =	N1.SubTotal
	,HistoricalFreight =	N1.Freight

	,PotentialPromoEffect =	CASE 
								WHEN N1.SubTotal > = 1700 AND N1.SubTotal < 2000
									THEN 'INCREASE ORDER TO $2,000 & PAY 22 CENTS FREIGHT'
								WHEN N1.Subtotal > = 2000 
									THEN 'NO ORDER CHANGE AND PAY 22 CENTS FREIGHT'
								ELSE'NO ORDER CHANGE & PAY HISTORICAL FREIGHT' END

	,PotentialOrderGain =	CASE
								WHEN N1.SubTotal > = 1700 AND N1.SubTotal < 2000 THEN 2000 - N1.SubTotal
								ELSE 0 END

	,PotentialFreightLoss =	CASE 
								WHEN N1.SubTotal > =  1700 THEN 0.22 ELSE N1.Freight END
							- N1.Freight
	 
	,[PromoNetGain/Loss] =	CASE
								WHEN N1.SubTotal > = 1700 AND N1.SubTotal < 2000 THEN 2000 - N1.SubTotal
								ELSE 0 END 

							+ CASE 
								WHEN N1.SubTotal > =  1700 THEN 0.22 ELSE N1.Freight END 
							- N1.Freight 
INTO #data
FROM Sales.SalesOrderHeader N1
INNER JOIN Person.BusinessEntityAddress N2 ON N1.ShipToAddressID = N2.AddressID
INNER JOIN Person.[Address] N3 ON N2.AddressID = N3.AddressID
INNER JOIN Person.StateProvince N4 ON N3.StateProvinceID = N4.StateProvinceID
WHERE N4.Name = 'California' AND DATEPART (YEAR, DATEADD (MONTH, 6, N1.OrderDate)) = 2008

SELECT *
FROM #data

--	Part II
SELECT 
	PotentialPromoEffect
	,PotentialOrderGains =		SUM (PotentialOrderGain)
	,PotentialFreightLosses =	SUM (PotentialFreightLoss)
	,OverallNet =				SUM ([PromoNetGain/Loss])
FROM #data
GROUP BY PotentialPromoEffect


