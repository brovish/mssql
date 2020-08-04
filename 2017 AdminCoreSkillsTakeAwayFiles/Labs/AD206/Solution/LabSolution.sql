-- AD206 Suggested Lab Solution
--
-- NOTE: There is no single right/wrong way to implement the requirements. We have provided a solution
--       based on best practices.

-- Exercise 1

-- N/A

-- Exercise 2

-- Richard Dawson should be able to run profiler

USE master;
GO

GRANT ALTER TRACE TO [SDUPROD\RichardDawson];
GO

-- Exercise 3

-- First create the users for the Windows group logins

USE WarehouseManagement;
GO

CREATE USER [SDUPROD\DBATeam] FOR LOGIN [SDUPROD\DBATeam];
GO
CREATE USER [SDUPROD\ManagementTeam] FOR LOGIN [SDUPROD\ManagementTeam];
GO
CREATE USER [SDUPROD\ReportingTeam] FOR LOGIN [SDUPROD\ReportingTeam];
GO
CREATE USER [SDUPROD\SalesTeam] FOR LOGIN [SDUPROD\SalesTeam];
GO

-- Next create the users for logins that need specific permissions that are not related to their group membership.

CREATE USER [SDUPROD\JackKlugman] FOR LOGIN [SDUPROD\JackKlugman];
GO
CREATE USER [SDUPROD\ErnestBorgnine] FOR LOGIN [SDUPROD\ErnestBorgnine];
GO

-- Then create the user for the SQL login

CREATE USER ReadyToScan FOR LOGIN ReadyToScan;
GO

-- Exercise 4

-- We need to assign the sales manager to the SalesManagers role

ALTER ROLE SalesManagers 
  ADD MEMBER [SDUPROD\ErnestBorgnine];
GO

-- Exercise 5

-- Let reporting team members execute any procs in the Reports schema.

GRANT EXECUTE ON SCHEMA::Reports TO [SDUPROD\ReportingTeam];
GO

-- The barcode printing app needs to be able to work with the Barcode schema

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Barcode TO ReadyToScan;
GO

-- Sales team can read from any table in the Sales schema

GRANT SELECT ON SCHEMA::Sales TO [SDUPROD\SalesTeam];
GO

-- Reporting team can control the Staging schema (Perform all actions)

GRANT CONTROL ON SCHEMA::Staging TO [SDUPROD\ReportingTeam];
GO

-- Warehouse team members can execute any code in the Warehouse schema

GRANT EXECUTE ON SCHEMA::Warehouse TO [SDUPROD\WarehouseTeam];
GO

-- SsasService needs to be able to select from the Staging schema

GRANT SELECT ON SCHEMA::Staging TO [SDUPROD\SsasService];
GO

-- Exercise 6

-- Sales team to insert or update rows in the Sales.Customers table

GRANT INSERT, UPDATE ON Sales.Customers TO [SDUPROD\SalesTeam];
GO

-- Sales managers need to insert/update/delete Sales.BusinessCategories

GRANT INSERT, UPDATE, DELETE ON Sales.BusinessCategories TO SalesManagers;
GO

-- Exercise 7

-- Jack Klugman is the exception. We don't have to do too much. The only access he has is via his membership
-- of the SalesTeam group, so we only have to DENY any access that he receives from that group. The only
-- schema that the group has access to is the Sales schema so we'll just deny that.

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Sales TO [SDUPROD\JackKlugman];
GO
