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
-- and stess testing it.

-- ostress runs fine in the cmd window but not in powershell. haven't analysed must be some command syntax diff
-- C:\Users\sin17h\Documents\sql-server-samples\samples\features\in-memory-database\memory-optimized-tempdb-metadata>ostress.exe -Slocalhost,1401 -USA -Ppassw0rd1! -Q"Select name from sys.databases" -n1 -r1
-- ostress -Slocalhost,1401 -USA -Ppassw0rd1! -Q"exec letsgomavs" -n50 -r5000 -dDallasMavericks
-- Repeat step 2 on local as not sure how to connect perfmon to sql in docker
-- ostress -SINTERVAL-BM\sql2019 -E -Q"exec letsgomavs" -n50 -r5000 -dDallasMavericks --this uses windows auth 

---- if you run the Create table command directly (without wrapping it in a SP), it will throw an error that the object #gomavs already exists
---- this can be explained based on sessions and scope.
-- ostress -SINTERVAL-BM\sql2019 -E -Q"USE DallasMavericks; CREATE TABLE #gomavs (col1 INT);" -n50 -r5000 -dDallasMavericks 

---- works fine beause each of the 500 threads starts a new session and in each session we create a temp table with same name.
--ostress -SINTERVAL-BM\sql2019 -E -Q"USE DallasMavericks; CREATE TABLE #gomavs (col1 INT);" -n500 -r1
---- where this fails saying "#gomavs already exists" because in the same session we create temp table twice with the same name.
-- ostress -SINTERVAL-BM\sql2019 -E -Q"USE DallasMavericks; CREATE TABLE #gomavs (col1 INT);" -n1 -r2

----this work fine even though for the same session (thread) we are calling the sp twice. And that is because the temp table we create is in  
----the sp scoped by the sp. It only exists locally in the sp, not visible in the outer session context.
-- ostress -SINTERVAL-BM\sql2019 -E -Q"exec letsgomavs" -n1 -r2 -dDallasMavericks 


--step 4: run page_latchWaits.sql to see to what objects the majority of page latch wait belongs to. Run it while the stress testing
-- script is still running. It is better to run it in data studio or ssms. It shows that sysschobjs is the primary object involved in page latch waits.
-- This system table is the primary table to store table metadata in the tempdb database 
-- SQLCMD.EXE -S INTERVAL-BM\sql2019 -E -i page_latchWaits.sql

--step 5: Enable the Optimize Tempdb Metadata capability 
-- SQLCMD.EXE -S INTERVAL-BM\sql2019 -E -i optimizetempdb.sql

-- --step 6: restart the service
-- net stop MSSQL$SQL2019 --this works on cmd admin
-- net stop 'MSSQL$SQL2019' --this works in powershell.
-- net start MSSQL$SQL2019

-- --step 7: run stress test from step 3 again. It took just 10 seconds to complete the stress test. I alo ran the page_latchWaits.sql while 
-- the stress test was running and it did not show any wait 
-- 06/01/20 14:29:21.630 [0x00006898] OSTRESS exiting normally, elapsed time: 00:00:10.802
----where as before it took 32 secs
-- 06/01/20 14:33:38.383 [0x00001EC8] OSTRESS exiting normally, elapsed time: 00:00:32.407