USE AdventureWorks2012;

--SELECT *
--FROM Sales.CreditCard

DROP TABLE #DATA;

WITH CTE AS
(
SELECT CR.CreditCardID,CR.CardType, EOMONTH(DATEFROMPARTS(CR.ExpYear,CR.ExpMonth,1)) AS EXPIRATIONDATE, MAX(SH.OrderDate) AS LASTORDERDATE, COUNT(*) AS NOOFORDERSAFTEREXPIRY
FROM Sales.SalesOrderHeader AS SH
INNER JOIN Sales.CreditCard AS CR ON CR.CreditCardID = SH.CreditCardID
WHERE SH.OrderDate > EOMONTH(DATEFROMPARTS(CR.ExpYear,CR.ExpMonth,1)) 
GROUP BY CR.CreditCardID,CR.CardType, EOMONTH(DATEFROMPARTS(CR.ExpYear,CR.ExpMonth,1))
),
CTE2 AS
(
SELECT CR.CreditCardID,CR.CardType, EOMONTH(DATEFROMPARTS(CR.ExpYear,CR.ExpMonth,1)) AS EXPIRATIONDATE, MAX(SH.OrderDate) AS LASTORDERDATE, COUNT(*) AS NOOFORDERSBEFOREEXPIRY
FROM Sales.SalesOrderHeader AS SH
INNER JOIN Sales.CreditCard AS CR ON CR.CreditCardID = SH.CreditCardID
WHERE SH.OrderDate <= EOMONTH(DATEFROMPARTS(CR.ExpYear,CR.ExpMonth,1)) 
GROUP BY CR.CreditCardID,CR.CardType, EOMONTH(DATEFROMPARTS(CR.ExpYear,CR.ExpMonth,1))
)
SELECT CTE.*, CTE2.NOOFORDERSBEFOREEXPIRY
INTO #DATA
FROM CTE FULL OUTER JOIN CTE2 ON CTE.CreditCardID = CTE2.CreditCardID
ORDER BY NOOFORDERSAFTEREXPIRY DESC


SELECT * FROM #DATA


SELECT D.CardType,SUM(D.NOOFORDERSBEFOREEXPIRY) AS NOOFORDERSBEFOREEXPIRY, SUM(D.NOOFORDERSAFTEREXPIRY) AS NOOFORDERSAFTEREXPIRY
FROM #DATA AS D
GROUP BY D.CardType

