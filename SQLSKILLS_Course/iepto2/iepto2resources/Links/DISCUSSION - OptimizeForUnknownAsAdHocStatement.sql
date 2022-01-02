USE credit;
go

create index test on member(lastname, firstname, middleinitial)
go

-- View the statistics components:
dbcc show_statistics (member, test)
go

-- talking about the histgram (with a STEP value)
select * 
from member 
where lastname = 'Alexander' -- gets an estimate of 125
go

-- talking about the histgram (using AVG)
select * from member where lastname = 'Adoson'
go

--Then, we tried to use OPTIMIZE FOR UNKNOWN
select * from member where lastname = 'Adoson'
option (optimize for unknown)
go
-- And, it still seemed to sniff...

--So, we tried clearing the cache
dbcc freeproccache
go

select * from member where lastname = 'Adoson'
option (optimize for unknown)
go
-- NOPE! it still seemed to sniff...

-- What about a variable (that's ALWAYS UNKNOWN)
declare @varln varchar(15)
select @varln = 'Adoson'
select * from member where lastname = @varln
go

-- YEP! We got the average from the density vector
-- remember that's all density * rows
select 0.0008143322 * 29996
go

-- We also tried CE
ALTER DATABASE SCOPED CONFIGURATION 
		SET LEGACY_CARDINALITY_ESTIMATION = OFF;
go

select * from member 
where lastname = 'Adoson'
option (optimize for unknown)
-- Nope, still sniffed!

-- And, compat mode
alter database credit
	SET COMPATIBILITY_LEVEL = 120 
go

select * from member 
where lastname = 'Adoson'
option (optimize for unknown)
-- Nope, still sniffed!

-- What about a proc!
create proc test2sdlfjs
	@lname varchar(15)
as
select * from member 
where lastname = @lname
option (optimize for unknown)
go

-- FINALLY, OPTIMIZE FOR UNKNOWN works with the DV
exec test2sdlfjs 'Adoson'
go