
IF DB_ID('Credit2') IS NULL
BEGIN

-- Attach database
USE [master]

CREATE DATABASE [Credit2] ON 
( FILENAME = N'E:\CreditX.mdf' ),
( FILENAME = N'E:\CreditX_log.ldf' )
 FOR ATTACH

END