USE [master]
GO
ALTER DATABASE [TestSchemaChanges] SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE
GO


select schema_name(1952937985)

dbcc dropcleanbuffers

create table schema1.testxml
(
    c1  int,
    c2  xml
)