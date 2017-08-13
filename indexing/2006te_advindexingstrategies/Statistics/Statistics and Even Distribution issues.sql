/*============================================================================
  File:     Statistics and Even Distribution Issues.sql

  Summary:  Can we really correlate columns when EACH column is indexed 
			ALONE? Especially when the data IS NOT evenly distributed...
			SQL Server 2005 DOES correlate dates A LOT better but you
			can still see where the estimates are OFF and are expecting
			even distribution.
  
  Date:     June 2006

  SQL Server Version: 9.00.2047.00 (SP1)
------------------------------------------------------------------------------
  Copyright (C) 2005 Kimberly L. Tripp, SYSolutions, Inc.
  All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE Northwind
go

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o WITH (INDEX(0))
WHERE o.ShippedDate IS NULL

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o WITH (INDEX(ShippedDate))
WHERE o.ShippedDate IS NULL

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o
WHERE o.ShippedDate IS NULL

-- Is there anything that would be better... single column indexes (or very narrow indexes)
-- tend to be useful for a narrower number of queries (lame pun intended)

-- A wider index - one that could really tell us what's going on here...

CREATE INDEX OrderDateShipped 
ON Orders(ShippedDate, OrderDate)
go

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o
WHERE o.ShippedDate IS NULL

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o WITH (INDEX(0))
WHERE o.ShippedDate IS NULL

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o WITH (INDEX(ShippedDate))
WHERE o.ShippedDate IS NULL

SELECT min(o.OrderDate) AS OldestUnshipped
FROM dbo.Orders AS o WITH (Index(OrderDate))
WHERE o.ShippedDate IS NULL