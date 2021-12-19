-- Between Script 3 and Script 4

CREATE INDEX FilteredIndexTest ON [OrdersRange] (EmployeeID, Freight)
WHERE OrderDate >= '20031001' AND OrderDate < '20040101'
go

SELECT EmployeeID, Freight
FROM OrdersRange
WHERE OrderDate  > '20031001' AND OrderDate < '20040101'
go

-- Switch out partition 1 - no problem...

-- Try to switch in partition 5 - doesn't work:
-- Msg 4947, Level 16, State 1, Line 1
-- ALTER TABLE SWITCH statement failed. There is no identical index in source table 'AdventureWorks2008Test.dbo.Orders2004Q3' for 
-- the index 'FilteredIndexTest' in target table 'AdventureWorks2008Test.dbo.OrdersRange' .

-- What if we were to create a "dummy" index on the partition that we're switching in:
CREATE INDEX FilteredIndexTest ON [Orders2004Q3] (EmployeeID, Freight)
WHERE OrderDate >= '20040701' AND OrderDate < '20041001'
go

--Msg 4947, Level 16, State 1, Line 1
--ALTER TABLE SWITCH statement failed. There is no identical index in source table 'AdventureWorks2008Test.dbo.Orders2004Q3' for the index 'FilteredIndexTest' in target table 'AdventureWorks2008Test.dbo.OrdersRange' .

CREATE INDEX FilteredIndexTest5 ON [OrdersRange] (EmployeeID, Freight)
WHERE OrderDate >= '20040701' AND OrderDate < '20041001'
go

--Msg 4947, Level 16, State 1, Line 1
--ALTER TABLE SWITCH statement failed. There is no identical index in source table 'AdventureWorks2008Test.dbo.Orders2004Q3' for the index 'FilteredIndexTest' in target table 'AdventureWorks2008Test.dbo.OrdersRange' .


-- If ALL partitions had the index:

CREATE INDEX FilteredIndexTest2 ON [OrdersRange] (EmployeeID, Freight)
WHERE OrderDate >= '20040101' AND OrderDate < '20040401'
go

CREATE INDEX FilteredIndexTest3 ON [OrdersRange] (EmployeeID, Freight)
WHERE OrderDate >= '20040101' AND OrderDate < '20040401'
go
