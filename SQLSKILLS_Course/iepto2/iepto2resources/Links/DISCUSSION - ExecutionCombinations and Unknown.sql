mno			Simple, CL seek, stable plan - 80%
fn
ln

mno, fn		Simple, CL seek, stable plan
mno, ln		Simple, CL seek, stable plan
fn, ln

mno, fn, ln	Simple, CL seek, stable plan

create proc sp1
	@p1 int
as
select * from member where member_no = @p1 -- parameter / literals "can be sniffed"
select * from member where member_no = 12343 --  literals

create proc sp1
	@p1 int
as
declare @v1 int
select @v1 = @p1
select * from member where member_no = @v1 -- variable "obfuscating" cannot be sniffed

create proc sp1
	@p1 int
as
select * from member where member_no = @p1 OPTION (OPTIMIZE FOR UNKNOWN) 


unknown?
cannot use histogram use density_vector (2nd stats blob)
averages...


Lastname histogram
Tripp = 1
Jones = 123

Lastname?
3.4