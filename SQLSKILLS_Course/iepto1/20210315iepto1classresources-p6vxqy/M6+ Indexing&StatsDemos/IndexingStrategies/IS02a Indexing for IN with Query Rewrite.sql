/*============================================================================
  File:     Indexing for IN with query rewrite.sql

  Summary:  Some queries are better off being re-written... an OR / IN
            might be a good candidate if you're having performance 
            problems!
  
  SQL Server Version: 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/resources/conferences/CreditBackup80.zip

-- NOTE: This is a SQL Server 2000 backup and MANY examples will work on 
-- SQL Server 2000 in addition to SQL Server 2005.

USE [credit];
GO

SET STATISTICS IO ON;
GO

SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (1, 2, 4, 5, 6, 7, 9, 10)
GROUP BY [c].[category_no];
GO

-- Isolated and optimized for ONE
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (2)
GROUP BY [c].[category_no];
GO

-- An index strategy that works for aggregates: 
--CREATE INDEX [SeekOnCategory]
--on [dbo].[charge] ([category_no])
--INCLUDE ([charge_amt]);
GO

-- But, to truly optimize for MIN:
CREATE INDEX [SeekOnCategory]
on [dbo].[charge] ([category_no], [charge_amt]);
GO

-- Let's test against the table scan:
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] WITH (index (0)) -- forces the table scan
WHERE [c].[category_no] IN (2)
GROUP BY [c].[category_no];
GO

-- No hints
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] IN (2)
GROUP BY [c].[category_no];
GO

-- OK, so what about the more complicated query:
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (1, 2, 4, 5, 6, 7, 9, 10)
GROUP BY [c].[category_no];
GO
-- What?!

SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (4, 5)
GROUP BY [c].[category_no];
GO

SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (4)
GROUP BY [c].[category_no];
GO

SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (5)
GROUP BY [c].[category_no];
GO

-----------------------------------
-- What can we do?!
-- 
-- Rewrite with UNION ALL?
--
-- It's UGLY... but, it works!
-----------------------------------

SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 1
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 2
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 3
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 4
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 5
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 6
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 7
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 8
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 9
GROUP BY [c].[category_no]
UNION ALL
SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c] 
WHERE [c].[category_no] = 10
GROUP BY [c].[category_no];
--OPTION (MAXDOP 1);
GO

SELECT [c].[category_no], min([c].[charge_amt])
FROM [dbo].[charge] AS [c]
WHERE [c].[category_no] IN (1, 2, 4, 5, 6, 7, 9, 10)
GROUP BY [c].[category_no];
GO

-----------------------------------
-- Question: Would a CTE work?
-- 
-- Unfortunately, no...
-----------------------------------

WITH [MinCharges] ([CatNo], [MinCA])
AS
(
    SELECT [c].[category_no], min([c].[charge_amt])
    FROM [dbo].[charge] AS [c] 
    GROUP BY [c].[category_no]
)
SELECT * 
FROM [MinCharges] AS [mc]
WHERE [mc].[CatNo] IN (1, 2, 4, 5, 6, 7, 9, 10);
GO

-----------------------------------
-- Question: Would a CROSS APPLY work?
-- 
-- Someone said YES but I can't get it to work
-- let me know and I'll update this and send out
-- another script...
-----------------------------------

CREATE TABLE #CategoryIDs (CatID int primary key not null)

INSERT #CategoryIDs (CatID)
       VALUES (1), (2), (4), (5), (6), (7), (9), (10);

SELECT [Cats].[CatID]
	 , [Mins].[MinAmount]
FROM    #CategoryIDs AS [Cats]
     CROSS APPLY (
		SELECT MIN([c].[charge_amt]) AS 'MinAmount' 
		FROM [dbo].[charge] AS [c]
		WHERE [c].[category_no] = [Cats].[CatID]
		GROUP BY [c].[category_no]) AS [Mins];
go

-- That was back to the scan?!

-----------------------------------
-- Question: What about a correlated subquery
-- 
-- YES! And, it's prettier!
-- (not sure if everything will translate but
--  this might be great for some re-writes!)
-----------------------------------

-- This is definitely "prettier" than the
-- UNION ALL query!
SELECT [c].[category_no], 
				(SELECT min([c2].[charge_amt]) AS 'min_charge_amt'
				FROM [dbo].[charge] AS [c2]
				WHERE [c].[category_no] = [c2].[category_no]
				GROUP BY [c2].[category_no]) AS [CorrSub]
FROM [dbo].[category] AS [c]
WHERE [c].[category_no] IN (1, 2, 4, 5, 6, 7, 9, 10);
GO 


-- If you want all categories then IN/SELECT will work!
SELECT [c].[category_no], 
				(SELECT min([c2].[charge_amt]) AS 'min_charge_amt'
				FROM [dbo].[charge] AS [c2]
				WHERE [c].[category_no] = [c2].[category_no]
				GROUP BY [c2].[category_no]) AS [CorrSub]
FROM [dbo].[category] AS [c]
WHERE [c].[category_no] IN (SELECT category_no from category)
GO 
