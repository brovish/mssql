--relational schema is the result of normalization
--only one value in each column. you might have to repeat rows to get that(First normal form)
--if a column has duplicate data, then it might be worthwhile to extract that data to a separate table and join with a foreign
--key relationship. the foreign key can either be placed in the original table or we can again create a separate mapping table
-- that will just associate the primary keys from both tables(second normal form)
--all the columns in the table should depend on the primary key of that table(third normal forms)

--collation refers to the character set and sort order
--mdf extension is used for data files...it is just an convention..no need for .mdf extension and ldf extension is used for transaction 
--log files...for fault tolerance, the mdf and ldf files should be on separate disks
CREATE DATABASE [MVADemoLocalDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MVADemoLocalDB', FILENAME = N'C:\SampleMSSQLDBs\data\MVADemoLocalDB.mdf' , SIZE = 4096KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'MVADemoLocalDB_log', FILENAME = N'C:\SampleMSSQLDBs\logs\MVADemoLocalDB_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO

--sales is the schema and product is the table. schema is a way to organize db objects(tables, views, stored procedures). sort of a namespace fo db
--identity is a auto incrementing column. primary key(composed of one or more columns) uniquely identifies data rows in the table. there can be 
--only one primary key and identity in a table
--varchar is varying length character string...null specifies a nullable column
create table Sales.Product
(ProductID Integer Identity Primary Key,
Name VarChar(20),
Price Decimal Null);

Go

--constraints are rules you apply to a particular column.Can be used to enforce integrity of data..so cant have products without suppliers
--.alter allows u to add/remove cols, constraints, keys.
Alter Table Sales.Product
Add Supplier Integer Not Null
Constraint def_supplier	Default 1;

--make sure every product hahs a valid supplier
Alter Table Sales.Product
Add Constraint fk_product_supplier
Foreign Key (Supplier) References Supplier(SupplierID);


--delete deletes the data in the table while drop removes the table itself from the database. Data definition language(DDL) is comprised of
--create, alter and drop
Drop Table Sales.Product

--position of the columns in the table correlates to the order in which we supplied the values here. so not need to specify column names
Insert Into Sales.Product
Values('Widget',12.99,1);

Insert Into Sales.Product (Name, Price, Supplier)
Values('Widget',12.99,1);

Insert Into Sales.Product 
Values('Widget',Null,Default);

--this is an error as the supplier column is not Null. had the supplier column allowed Nulls, this would have succedded with 
--Null insertion
Insert Into Sales.Product 
Values('Widget',Null,Null);

Select * from Sales.Product
Select Name, Price, Supplier from Sales.Product
Select Name As Product, Price * .9  As SalesPrice from Sales.Product
--it looks at the From clause, then at the Where clause and then the Select clause
Select Name, Price from Sales.Product Where Supplier = 2

Use AdventureWorks2014
Go

--NvarChar is variable width unicode. maximum lenght of 20 chars
Create Table dbo.Customer
(CustomerID Integer Identity Primary Key,
FirstName NVarChar(20) Not Null,
MiddleName NVarChar(20) Null,
LastName NVarChar(20) Null,
AccountOpened Date Default GetDate(),
CreditLimit Decimal(6,2) Default 1000.00);
Go

--Insert a row with values
Insert Into dbo.Customer
Values('Dan','D','Drayton','1/1/2016',500.00);
Go

--Insert explicit Nulls and Defaults
Insert Into dbo.Customer
Values('Ram',Null,'Ford',Default,Default);
Go

--Insert into specific cols
Insert Into dbo.Customer(FirstName,LastName)
Values('Jatt','Putt');
Go

--Insert invalid data
Insert Into dbo.Customer(FirstName,LastName)
Values(Null,'Putt');
Go

--Insert: Are Null credit limits allowed? We have not specified Null or Not Null for this column
--by default Null values are allowed if not specified. We should change this default behavior in the database
Insert Into dbo.Customer
Values('Sphia','S','Gtot','1/1/2016',Null);
Go

--since one of the inserts above failed, the customerId col would be missing a value in the sequence
Select * from Customer;
Go

Select CustomerID,FirstName,LastName From Customer;

--select calculated cols
Select CustomerID,
	FirstName + ' ' + LastName As FullName,
	DATEDIFF(dd,AccountOpened,GETDATE()) As AccountDays
From Customer;

--filter rows
Select CustomerID,FirstName,LastName 
	From dbo.Customer
	Where CreditLimit > 500;

Alter Table dbo.Customer
	Add AccountManager Int Null References dbo.AccountManagers(EmployeeID);

--data types Character strings
--1) fixed length
--2) variable length
--3) large text
--4) unicode for character sets not in ascii

--data types numbers
--1) ints
--2) exact decimals
--3) approximate decimals

--data types for temporal values
--1) dates
--2) times
--3) date and time
--4) offsets

--data types
--1) bit for true false
--2) binary for say a pic or video
--3) guid
--4) xml
--5) spatial data like coordinates
--6) timestamp

--if anything fails, nothing gets inserted

--a view can be 'viewed' as a wrapper on a select statement so that user does not havd to write that select statement again and again
Create View as vw_ProductPrice
As
	Select Name,Price
	From Product
	Where Supplier = 2;
Go

Select Name, Price
From vw_ProductPrice;

--move from checkings account to savings account..a transaction
Create Procedure transferFunds
As
Begin Transaction
	Update Savings
	Set Balance +=500
	Where AccountID =3;
	Update Savings
	Set Balance -=500
	Where AccountID =3;
Commit Transaction
--or if an error
RollBack Transaction

Exec transferFunds;

--indexes to improve performance of db. Data in a table is stored in pages on disk. using a clustered index on ProductId means that
--the data in the Pprduct table will be stored in pages in order of Product Ids. The first page might have product Id 1 and 2, next page might have 
--product Id 3 and 4 and so on..This mapping between index and pages(1-->01;3-->02) is maintained so that you do not have to read all the pages to get data
--you are looking for.You can have index on composite cols 
Create Clustered Index idx_ProductID
On Sales.Product(ProductId);

--so u create a clustered index to determine the order in which the data is stored on the disk. You can have one clustered index per table.
--and then u cna create one or more non-clustered index for additional fields that you commonly search on to reduce the number of pages u
--have to read.

--A clustered index determines the order in which the rows are stored. only one clustered index per table. a table without a clustered index is 
--a heap
--A non clustered index stores pointers either to the 1) to the rowid of the a heap OR 2) the cluster key of clustered index.

SELECT *  FROM [AdventureWorks2014].[Sales].[SalesOrderDetail]

--SET STATS on to see how many pages are read...logical reads suggests the number of pages read to find the data
Set Statistics IO On

--Show the actual execution plan...visually see the sql server query engine is performing the query

Select ProductID, OrderQty
From [AdventureWorks2014].[Sales].[SalesOrderDetail]
Where SalesOrderID = 58125;

Select SalesOrderID
From [AdventureWorks2014].[Sales].[SalesOrderDetail]
Where ProductID = 758;

--columnstore index are stored in memory and store data by column instead of by row. They use compression to optimize memory usage and performance. They can
--be clustered or non-clustered. clustered cloumnstore indexes include all the columns in the table(by default). Only one clustered columnstore index per table

--creating memory optimized tables and native stored procedures....In the create database statement, you have to use a thing called FileGroup that contains memory
--optimized data
CREATE DATABASE [MemDB]
 ON  PRIMARY 
( NAME = N'MemDB', FILENAME = N'C:\DATA\MemDB.mdf' , SIZE = 5120KB , FILEGROWTH = 1024KB )
FILEGROUP [MemDB] Contains MEMORY_OPTIMIZED_DATA 
( NAME = N'MemData', FILENAME = N'C:\DATA\MEMDATA' )
 LOG ON 
( NAME = N'MemDB_log', FILENAME = N'C:\Log\MemDB_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO

Use MemDB
--in-memory table..are actually c# structs that are then compiled to dll 
Create Table dbo.MemoryTable
(id Integer not null primary key nonclustered hash with (bucket_count = 1000000),
date_value datetime null)
with(memory_optimized = on ,durability=schema_and_data);

--for comparison, this is the table with same structure but on disk
Create Table dbo.DiskTable
(id Integer not null primary key nonclustered,
date_value datetime null);

--use a transaction to insert 500,000 rows in disktable...slow..took 17 seconds
begin
	declare @diskid int =1
	while @diskid<=500000
	begin
		insert into dbo.disktable values(@diskid, getdate())
		set @diskid += 1
	end
commit;

select count(*) from dbo.disktable

--insert 50000 rows in memorytable....much faster..took 7 seconds
begin
	declare @memid int =1
	while @memid <=500000
	begin
		insert into dbo.memorytable values(@memid , getdate())
		set @memid += 1
	end
commit;

select count(*) from dbo.memorytable;

delete from  disktable;--slow
delete from  memorytable;--fast

--native stored procedure are also c# code compiled to dll....instead of firing of a standalone sql insert, this compiled stored proecure 
--takes less than a second
create procedure dbo.insertdata
	with native_compilation, schemabinding, execute as owner
as 
Begin atomic with (transaction isolation level =snapshot, language='us_english')
	declare @memid int =1
	while @memid <=500000
	begin
		insert into dbo.memorytable values(@memid , getdate())
		set @memid += 1
	end
end;
go
	
exec dbo.insertdata;

--working with non-relational data
--1) xml...xml data type is supported in sql server
select top 5 lastname
from dbo.customer
for xml auto, root('customer')--return the results as xml using auto formatting rule and wrap them in a root element called cutomer

--suppose an application passes in a xml chunk and sql server here is interpresting it
select *
from openxml(@idoc,'root/customer',1)--pass in a variable and telling it what part of the tree to traverse
with (customerid varchar(10), contactname varchar(20));--and then take those results and assign them column names

--2) json--store as nvarchar or documentdb
select top 5 lastname
from dbo.customer
for json auto, --return the results as json using auto formatting rule

declare @json nvarchar(255)
set @json = N'[null, "string", 1, true ]';

select * from openjson(@json)

--3) documentdb...we are not talking about word or pdf or other documents....we are talking about json...is documentdb separate from sql server

--backups: full or partial backups possible, transaction log backups for point in time recovery, backup locally or to cloud
--security: authentication(who are u), authorization(ur permissions), encryption, auditing
--monitoring and maintenance:server and db health, resource usage, job execution, validate backups,  tune indexes, updates to os and sql server
