USE AdventureWorks2012;

--SELECT *
--FROM Purchasing.ProductVendor AS PV
--WHERE PV.ProductID =433

;WITH CTE AS
(
SELECT PV.ProductID, PV.LastReceiptCost, RANK() OVER(PARTITION BY PV.ProductID ORDER BY PV.LastReceiptCost DESC) AS RNK
FROM Purchasing.ProductVendor AS PV
),
C2 AS
(SELECT C.ProductID, C.LastReceiptCost, C.RNK
FROM CTE AS C
WHERE RNK < 3
)
SELECT ProductID, [1], [2], ROUND(([1] - [2]) / [2],2,1) AS DIFF
FROM (SELECT C2.ProductID, C2.LastReceiptCost, C2.RNK FROM C2) AS D
PIVOT(SUM(LastReceiptCost) FOR RNK IN ([1],[2]) ) AS PVT
ORDER BY DIFF DESC

--SELECT PV.ProductID, MAX(PV.LastReceiptCost), MIN(PV.LastReceiptCost)
--	 ,ROUND((MAX(PV.LastReceiptCost) - MIN(PV.LastReceiptCost)) / MIN(PV.LastReceiptCost),2,1) AS DIFF
--FROM Purchasing.ProductVendor AS PV
--GROUP BY PV.ProductID
--ORDER BY DIFF DESC

--;WITH CTE AS
--(
--SELECT PV.ProductID, PV.LastReceiptCost, DENSE_RANK() OVER(PARTITION BY PV.ProductID ORDER BY PV.LastReceiptCost DESC) AS RNK
--FROM Purchasing.ProductVendor AS PV
--)
--SELECT C.ProductID, CASE WHEN RNK = 1 THEN C.LastReceiptCost END AS 'MOSTEXP'
--		,CASE WHEN RNK = 2 THEN C.LastReceiptCost END AS '2NDMOSTEXP'
--FROM CTE AS C
--WHERE RNK < 3
--GROUP BY C.ProductID


--C2 AS
--(SELECT C.ProductID, CASE WHEN RNK = 1 THEN C.LastReceiptCost END AS 'MOSTEXP'
--		,CASE WHEN RNK = 2 THEN C.LastReceiptCost END AS '2NDMOSTEXP'
--FROM CTE AS C
--WHERE RNK < 3
--)