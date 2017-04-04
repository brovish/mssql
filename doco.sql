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
--varchar is varying width characters...null specifies a nullable column
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

--this is an error as specifying Null won't direct the table to use the default for Supplied...only not specifying a value would
Insert Into Sales.Product 
Values('Widget',Null,Null);

Select * from Sales.Product
Select Name, Price, Supplier from Sales.Product
Select Name As Product, Price * .9  As SalesPrice from Sales.Product
--it looks at the From clause, then at the Where clause and then the Select clause
Select Name, Price from Sales.Product Where Supplier = 2
