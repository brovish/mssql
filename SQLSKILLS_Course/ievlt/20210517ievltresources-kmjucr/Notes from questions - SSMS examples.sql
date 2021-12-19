--------------------------------------------------
-- Talking about the CE 
--------------------------------------------------
-- Talking about the CE - is the new CE "better"
-- is the legacy CE "out of date,"  per se.
-- NO - they're just different. And, generally
-- speaking the NEW CE tends to estimate LOWER.

-- Take the following example with Products
-- 1/3 of your products are red
-- 1/4 of your products are round

-- What would this WHERE clause estimate?
WHERE shape = 'round' and color = 'red'

-- LEGACY CE
-- 1/4 * 1/3 = 1/12

-- New CE
-- "exponential backoff"
-- 1/4 * 1/9 = 1/36

--------------------------------------------------
-- Partitioning Keys and pushing down predicates
--------------------------------------------------
-- For the Orders and OrderDetails tables you
-- probably want to partition both the same way

-- This requires the date to be in both tables
Orders 
	CL PK	date, id

OrderDetails
	CL PK	date, id, li

--If you have an OrderPV and an OrderDetailsPV
View OrderPV
View OrderDetailsPV

-- And then you join those views, you need to make
-- sure that you put DATE for BOTH tables in the
-- WHERE clause:
Joining..
FROM
	OrdersPV as o
	Join OrderDetailsPV as od
		on o.orderdate = od.orderdate 
			AND o.orderid = od.orderid
WHERE
	o.OrderDate = date... 
	AND od.OrderDate = date 

-- Without that AND clause (line 51) then SQL Server
-- won't be able to eliminate for OrderDetailsPC

--------------------------------------------------
-- Recovering - anything special to do for views?
--------------------------------------------------
-- YES... when a file/filegroup is damaged you
-- also need to modify the view or users will get
-- errors even when they're selecting data that's 
-- NOT damaged (if they're selecting through the VIEW)

ChargePV
June damaged...
July
Aug
Sept

-- For the recovery process, you need to take the FG
-- offline

-- Then, modify the view to remove June

-- Then, restore / recover June 
-- (restore the "full" backup, last diff, any logs to get to current)

-- Then, modify the view to add June back in



--------------------------------------------------
-- What is "primary" in a database (confusing!!!)
--------------------------------------------------

-- mdf in SSMS and elsewhere is POORLY defined as the "primary" file
--     sometimes they even as "as a primary file" vs. ndf meaning
--     secondary or non-primary file. It's TERRIBLE naming.
-- The extension of your files means NOTHING. Only the primary
-- filegroup matters (in terms of availability).

-- PRIMARY FILEGROUP has at least one file and it's ALWAYS
-- the fist file added to the database. You can add files to 
-- the primary filegroup but when this is isolated then you 
-- probably don't need to (since it won't be all that large)



--------------------------------------------------
-- What if you can't really take the DB offline
-- (even momentarily) to set a FG to ReadOnly?
--------------------------------------------------

-- The trick - use "dummy" differentials where
-- they'll be basically empty.

(M) fg backup after all of RW is done

do not set it to RO

(T) fg differential		--(you could delete this one you do the next one)

(W) fg differential		--(keeping a few, just in case one is damaged isn't
						-- a bad idea)

(Th) fg differential	-- the "closer to current" the differential IS
						-- the fewer log backups you'll have to restore!

-- If there's a disaster then you'll need to recover:

Restore the "full filegroup backup" done at line 107
Then, restore the most recent differential at line 116
Then, restore ALL of the logs since line 116 to when the FG was taken offline


--------------------------------------------------
-- Datatime data types
--------------------------------------------------

-- this shows the settings for your session
DBCC USEROPTIONS;
go

-- This format is not NOT affected by dateformat setting
-- 'YYYYMMDD' use CONVERT for display
'20161029'

----------------------------------------
-- datetime2(0-7)
----------------------------------------

datetime2(0-2) -> 6 bytes storage
datetime2(3-4) -> 7 bytes storage
datetime2(5-7) -> 8 bytes storage

With datetime2 use SYSDATETIME()

----------------------------------------
-- datetime
----------------------------------------
only precise to timetick 3.33 ms

23:59:59.999 -> up 
23:59:59.998 -> down
23:59:59.997

with datetime use getdate()

-- Here you can see both values
select getdate(), sysdatetime()

----------------------------------------
-- Always use the smallest but most
-- reasonable data type for a column
----------------------------------------

-- If you think you might have 100s of millions
-- go straight to bigint. You don't want the hassle
-- of running out!

Limitations...
int -> 2bn
bigint -> HUGE!

----------------------------------------
-- For other data types, always consider 
-- using the highest precision for the 
-- storage you're using
----------------------------------------

decimal( p, s )

-- You *need* an (11, 5) and the storage
-- is 9 bytes for p 10-19 so instead
-- use 19, 5