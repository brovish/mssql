USE MASTER;
GO
DROP DATABASE IF EXISTS DallasMavericks;
GO
CREATE DATABASE DallasMavericks;
GO
USE DallasMavericks;
GO
CREATE OR ALTER PROCEDURE letsgomavs
AS
CREATE TABLE #gomavs (col1 INT);
GO

-- --step 1: run this file to create a db in container that will be used for stress testing:
-- SQLCMD.EXE -S localhost,1401 -U SA -P passw0rd1! -Q "Select name from sys.databases"
-- SQLCMD.EXE -S localhost,1401 -U SA -P passw0rd1! -i tempdb.sql
-- -- since i could not connect the perfmon to sqlserver running inside docker, redo the step 1 on sqlserver running on local machine
-- SQLCMD.EXE -S INTERVAL-BM\sql2019 -E -Q "Select name from sys.databases"
-- SQLCMD.EXE -S INTERVAL-BM\sql2019 -E -i tempdb.sql

--step 2: creae perfmon counters (refer perfmon_counters.png)

-- Step 3: And then stress test the db and observe the perfmon counters. we are creating a temp table in the sp
-- and stess testing it (execution context/scope of the temp table would be different for different execution calls hence same name temp table
-- would be created in temp db??)TODO: difference bw sessions and scope is what explains it. write about it

-- ostress runs fine in the cmd window but not in powershell. haven't analysed must be some command syntax diff
-- C:\Users\sin17h\Documents\sql-server-samples\samples\features\in-memory-database\memory-optimized-tempdb-metadata>ostress.exe -Slocalhost,1401 -USA -Ppassw0rd1! -Q"Select name from sys.databases" -n1 -r1
-- ostress -Slocalhost,1401 -USA -Ppassw0rd1! -Q"exec letsgomavs" -n50 -r5000 -dDallasMavericks
-- Repeat step 2 on local as not sure how to connect perfmon to sql in docker
-- ostress -SINTERVAL-BM\sql2019 -E -Q"exec letsgomavs" -n50 -r5000 -dDallasMavericks --this uses windows auth 
---- if you run the Create table command directly (without wrapping it in a SP), it will throw an error that the object #gomavs already exists
-- ostress -SINTERVAL-BM\sql2019 -E -Q"USE DallasMavericks;GO CREATE TABLE #gomavs (col1 INT);" -n50 -r5000 -dDallasMavericks 


--step 4: run page_latchWaits.sql to see to what objects the majority of page latch wait belongs to. Run it while the stress testing
-- script is still running. It is better to run it in data studio or ssms. It shows that sysschobjs is the primary object involved in page latch waits.
-- This system table is the primary table to store table metadata in the tempdb database 
-- SQLCMD.EXE -S INTERVAL-BM\sql2019 -E -i page_latchWaits.sql

--step 5: 