-- AD205 Suggested Lab Solution
--
-- NOTE: There is no single right/wrong way to implement the requirements. We have provided a solution
--       based on best practices.

-- Exercise 1

-- N/A

-- Exercise 2

USE WarehouseManagement;
GO

CREATE SCHEMA Staging AUTHORIZATION dbo;
GO

-- Exercise 3

-- First, the relevant Windows groups need to be created as logins.

USE master;
GO

CREATE LOGIN [SDUPROD\DBATeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\ManagementTeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\ReportingTeam] FROM WINDOWS;
GO
CREATE LOGIN [SDUPROD\SalesTeam] FROM WINDOWS;
GO

-- Next, Windows logins are needed for any windows users that need specific permissions that are not related to their group membership.

-- We need Jack Klugman to be able to exclude him from access that the SalesTeam has

CREATE LOGIN [SDUPROD\JackKlugman] FROM WINDOWS;
GO

-- We need the sales manager (only member of both SalesTeam and ManagementTeam).
-- Note that as there will later potentially be another sales manager, it would be better for the Windows administrators
-- to create a SalesManagerTeam group. However, in the meantime, we can achieve that with a database role.

CREATE LOGIN [SDUPROD\ErnestBorgnine] FROM WINDOWS;
GO

-- We need to be able to assign Richard Dawson the ability to run profiler
-- (that will be achieved later as server permission)

CREATE LOGIN [SDUPROD\RichardDawson] FROM WINDOWS;
GO

-- Exercise 4

-- The only SQL login identified is the one for the barcode scanning application

CREATE LOGIN ReadyToScan WITH PASSWORD = 'SQLRocks!', CHECK_POLICY = OFF;
GO
 
-- Exercise 5

-- No user-defined server roles are required

-- Exercise 6

-- The DBATeam needs to be part of the sysadmin fixed server role

ALTER SERVER ROLE sysadmin ADD MEMBER [SDUPROD\DBATeam];
GO

-- Exercise 7

-- A user-defined database role will be needed for the Sales Managers so let's create one

USE WarehouseManagement;
GO

CREATE ROLE SalesManagers;
GO


