---------------------------------------------------------------------
-- T-SQL Querying (Microsoft Press, 2015)
-- Chapter 11 - Graphs and Recursive Queries
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Scenarios
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Employees Organizational Chart
---------------------------------------------------------------------

-- Listing 11-1: DDL & Sample Data for Employees
SET NOCOUNT ON;
USE tempdb;
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL CONSTRAINT PK_Employees PRIMARY KEY,
  mgrid   INT             NULL CONSTRAINT FK_Employees_Employees REFERENCES dbo.Employees,
  empname VARCHAR(25) NOT NULL,
  salary  MONEY       NOT NULL,
  CHECK (empid <> mgrid)
);

INSERT INTO dbo.Employees(empid, mgrid, empname, salary) VALUES
  (1,  NULL, 'David'  , $10000.00),
  (2,  1,    'Eitan'  ,  $7000.00),
  (3,  1,    'Ina'    ,  $7500.00),
  (4,  2,    'Seraph' ,  $5000.00),
  (5,  2,    'Jiru'   ,  $5500.00),
  (6,  2,    'Steve'  ,  $4500.00),
  (7,  3,    'Aaron'  ,  $5000.00),
  (8,  5,    'Lilach' ,  $3500.00),
  (9,  7,    'Rita'   ,  $3000.00),
  (10, 5,    'Sean'   ,  $3000.00),
  (11, 7,    'Gabriel',  $3000.00),
  (12, 9,    'Emilia' ,  $2000.00),
  (13, 9,    'Michael',  $2000.00),
  (14, 9,    'Didi'   ,  $1500.00);

CREATE UNIQUE INDEX idx_unc_mgrid_empid ON dbo.Employees(mgrid, empid);
GO

--ramneek: to generate more data such that we can test the performance, use this. Also read the ..\..\Divide_and_Conquer_Halloween.htm which improves the performance

--create or alter view getrandvalue
--as
--select rand() as value;
--go
 
-- --gets a random empid (from a given range of empids)
--create or alter function dbo.getrandommanagerid(@maxempid int, @minempid int) returns int
--as
--begin
--  return  floor((select value from getrandvalue)*(@maxempid-@minempid+1)+@minempid)
--end;
--go

--delete from dbo.Employees;
--go

--declare @numberOfLevels as int=1000--so total employees would be @numberOfLevels * @numberOfEmpsAtEachLevel
--declare @numberOfEmpsAtEachLevel as int=4--so total employees would be @numberOfLevels * @numberOfEmpsAtEachLevel 

--;with basetable as
--(select case when node.n =1 then 0 else lvl.n end as [level]
--	, node.n as [empid]
--	, max(node.n) over(partition by case when node.n =1 then 0 else lvl.n end) as maxempid
--	, min(node.n) over(partition by case when node.n =1 then 0 else lvl.n end) as minempid
--from tsqlv3.dbo.getnums(1,@numberOfLevels) as lvl
--cross apply tsqlv3.dbo.getnums((lvl.n-1)*@numberOfEmpsAtEachLevel+1, (lvl.n)*@numberOfEmpsAtEachLevel) as node
--)
----insert into dbo.employees(empid, mgrid, empname, salary) 
--select empid
--	  ,[mgrid]
--	  ,concat('emp', cast(empid as nvarchar)) as empname
--	  ,(abs(checksum(newid())%13) + 354) *93 as salary
--	  ,[level]
--from basetable as b1
--outer apply (select max(maxempid), min(minempid) from basetable as b2 where b2.[level] = b1.[level]-1) as b2(prev_maxempid, prev_minempid )
--cross apply (select dbo.getrandommanagerid(prev_maxempid, prev_minempid)) as rnd(mgrid)
--go

--ramneek:end

---------------------------------------------------------------------
-- Bill Of Materials (BOM)
---------------------------------------------------------------------

-- Listing 11-2: DDL & Sample Data for Parts, BOM

IF OBJECT_ID(N'dbo.BOM', N'U') IS NOT NULL DROP TABLE dbo.BOM;
IF OBJECT_ID(N'dbo.Parts', N'U') IS NOT NULL DROP TABLE dbo.Parts;
GO
CREATE TABLE dbo.Parts
(
  partid   INT         NOT NULL CONSTRAINT PK_Parts PRIMARY KEY,
  partname VARCHAR(25) NOT NULL
);

INSERT INTO dbo.Parts(partid, partname) VALUES
  ( 1, 'Black Tea'      ),
  ( 2, 'White Tea'      ),
  ( 3, 'Latte'          ),
  ( 4, 'Espresso'       ),
  ( 5, 'Double Espresso'),
  ( 6, 'Cup Cover'      ),
  ( 7, 'Regular Cup'    ),
  ( 8, 'Stirrer'        ),
  ( 9, 'Espresso Cup'   ),
  (10, 'Tea Shot'       ),
  (11, 'Milk'           ),
  (12, 'Coffee Shot'    ),
  (13, 'Tea Leaves'     ),
  (14, 'Water'          ),
  (15, 'Sugar Bag'      ),
  (16, 'Ground Coffee'  ),
  (17, 'Coffee Beans'   );

CREATE TABLE dbo.BOM
(
  partid     INT           NOT NULL CONSTRAINT FK_BOM_Parts_pid REFERENCES dbo.Parts,
  assemblyid INT               NULL CONSTRAINT FK_BOM_Parts_aid REFERENCES dbo.Parts,
  unit       VARCHAR(3)    NOT NULL,
  qty        DECIMAL(8, 2) NOT NULL,
  CONSTRAINT UNQ_BOM_pid_aid UNIQUE(partid, assemblyid),
  CONSTRAINT CHK_BOM_diffids CHECK (partid <> assemblyid)
);

INSERT INTO dbo.BOM(partid, assemblyid, unit, qty) VALUES
  ( 1, NULL, 'EA',   1.00),
  ( 2, NULL, 'EA',   1.00),
  ( 3, NULL, 'EA',   1.00),
  ( 4, NULL, 'EA',   1.00),
  ( 5, NULL, 'EA',   1.00),
  ( 6,    1, 'EA',   1.00),
  ( 7,    1, 'EA',   1.00),
  (10,    1, 'EA',   1.00),
  (14,    1, 'mL', 230.00),
  ( 6,    2, 'EA',   1.00),
  ( 7,    2, 'EA',   1.00),
  (10,    2, 'EA',   1.00),
  (14,    2, 'mL', 205.00),
  (11,    2, 'mL',  25.00),
  ( 6,    3, 'EA',   1.00),
  ( 7,    3, 'EA',   1.00),
  (11,    3, 'mL', 225.00),
  (12,    3, 'EA',   1.00),
  ( 9,    4, 'EA',   1.00),
  (12,    4, 'EA',   1.00),
  ( 9,    5, 'EA',   1.00),
  (12,    5, 'EA',   2.00),
  (13,   10, 'g' ,   5.00),
  (14,   10, 'mL',  20.00),
  (14,   12, 'mL',  20.00),
  (16,   12, 'g' ,  15.00),
  (17,   16, 'g' ,  15.00);
GO

---------------------------------------------------------------------
-- Road System
---------------------------------------------------------------------

-- Listing 11-3: DDL & Sample Data for Cities, Roads
IF OBJECT_ID(N'dbo.Roads', N'U') IS NOT NULL DROP TABLE dbo.Roads;
IF OBJECT_ID(N'dbo.Cities', N'U') IS NOT NULL DROP TABLE dbo.Cities;
GO
CREATE TABLE dbo.Cities
(
  cityid  CHAR(3)     NOT NULL CONSTRAINT PK_Cities PRIMARY KEY,
  city    VARCHAR(30) NOT NULL,
  region  VARCHAR(30)     NULL,
  country VARCHAR(30) NOT NULL
);

INSERT INTO dbo.Cities(cityid, city, region, country) VALUES
  ('ATL', 'Atlanta', 'GA', 'USA'),
  ('ORD', 'Chicago', 'IL', 'USA'),
  ('DEN', 'Denver', 'CO', 'USA'),
  ('IAH', 'Houston', 'TX', 'USA'),
  ('MCI', 'Kansas City', 'KS', 'USA'),
  ('LAX', 'Los Angeles', 'CA', 'USA'),
  ('MIA', 'Miami', 'FL', 'USA'),
  ('MSP', 'Minneapolis', 'MN', 'USA'),
  ('JFK', 'New York', 'NY', 'USA'),
  ('SEA', 'Seattle', 'WA', 'USA'),
  ('SFO', 'San Francisco', 'CA', 'USA'),
  ('ANC', 'Anchorage', 'AK', 'USA'),
  ('FAI', 'Fairbanks', 'AK', 'USA');

CREATE TABLE dbo.Roads
(
  city1       CHAR(3) NOT NULL CONSTRAINT FK_Roads_Cities_city1 REFERENCES dbo.Cities,
  city2       CHAR(3) NOT NULL CONSTRAINT FK_Roads_Cities_city2 REFERENCES dbo.Cities,
  distance    INT     NOT NULL,
  CONSTRAINT PK_Roads PRIMARY KEY(city1, city2),
  CONSTRAINT CHK_Roads_citydiff CHECK(city1 < city2),
  CONSTRAINT CHK_Roads_posdist CHECK(distance > 0)
);

INSERT INTO dbo.Roads(city1, city2, distance) VALUES
  ('ANC', 'FAI',  359),
  ('ATL', 'ORD',  715),
  ('ATL', 'IAH',  800),
  ('ATL', 'MCI',  805),
  ('ATL', 'MIA',  665),
  ('ATL', 'JFK',  865),
  ('DEN', 'IAH', 1120),
  ('DEN', 'MCI',  600),
  ('DEN', 'LAX', 1025),
  ('DEN', 'MSP',  915),
  ('DEN', 'SEA', 1335),
  ('DEN', 'SFO', 1270),
  ('IAH', 'MCI',  795),
  ('IAH', 'LAX', 1550),
  ('IAH', 'MIA', 1190),
  ('JFK', 'ORD',  795),
  ('LAX', 'SFO',  385),
  ('MCI', 'ORD',  525),
  ('MCI', 'MSP',  440),
  ('MSP', 'ORD',  410),
  ('MSP', 'SEA', 2015),
  ('SEA', 'SFO',  815);
GO

---------------------------------------------------------------------
-- Iterations/Recursion
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Subgraph/Descendants
---------------------------------------------------------------------

-- Creation Script for Function Subordinates1

---------------------------------------------------------------------
-- Function: Subordinates1, Descendants
--
-- Input   : @root INT: Manager id
--
-- Output  : @Subs Table: id and level of subordinates of
--                        input manager (empid = @root) in all levels
--
-- Process : * Insert into @Subs row of input manager
--           * In a loop, while previous insert loaded more than 0 rows
--             insert into @Subs next level of subordinates
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Subordinates1', N'TF') IS NOT NULL DROP FUNCTION dbo.Subordinates1;
GO
CREATE FUNCTION dbo.Subordinates1(@root AS INT) RETURNS @Subs Table
(
  empid INT NOT NULL PRIMARY KEY NONCLUSTERED,
  lvl   INT NOT NULL,
  UNIQUE CLUSTERED(lvl, empid)        -- Index will be used to filter level
)
AS
BEGIN
  DECLARE @lvl AS INT = 0;            -- Initialize level counter with 0

  -- Insert root node to @Subs
  INSERT INTO @Subs(empid, lvl)
    SELECT empid, @lvl FROM dbo.Employees WHERE empid = @root;

  WHILE @@rowcount > 0                -- while previous level had rows
  BEGIN
    SET @lvl += 1;                    -- Increment level counter

    -- Insert next level of subordinates to @Subs
    INSERT INTO @Subs(empid, lvl)
      SELECT C.empid, @lvl
      FROM @Subs AS P                 -- P = Parent
        INNER JOIN dbo.Employees AS C -- C = Child
          ON P.lvl = @lvl - 1         -- Filter parents from previous level
             AND C.mgrid = P.empid;
  END

  RETURN;
END
GO

-- Node ids of descendants of a given node
SELECT empid, lvl FROM dbo.Subordinates1(3) AS S;

-- Descendants of a given node
SELECT E.empid, E.empname, S.lvl
FROM dbo.Subordinates1(3) AS S
  INNER JOIN dbo.Employees AS E
    ON E.empid = S.empid;

-- Leaf nodes underneath a given node
SELECT empid 
FROM dbo.Subordinates1(3) AS P
WHERE NOT EXISTS
  (SELECT * FROM dbo.Employees AS C
   WHERE C.mgrid = P.empid);
GO

-- Subtree of a Given Root, CTE Solution
DECLARE @root AS INT = 3;

WITH Subs AS
(
  -- Anchor member returns root node
  SELECT empid, empname, 0 AS lvl 
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  -- Recursive member returns next level of children
  SELECT C.empid, C.empname, P.lvl + 1
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, empname, lvl FROM Subs;
GO

-- Creation Script for Function PartsExplosion

---------------------------------------------------------------------
-- Function: PartsExplosion, Parts Explosion
--
-- Input   : @root INT: Root part id
--
-- Output  : @PartsExplosion Table:
--              id and level of contained parts of input part
--              in all levels
--
-- Process : * Insert into @PartsExplosion row of input root part
--           * In a loop, while previous insert loaded more than 0 rows
--             insert into @PartsExplosion next level of parts
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.PartsExplosion', N'TF') IS NOT NULL DROP FUNCTION dbo.PartsExplosion;
GO
CREATE FUNCTION dbo.PartsExplosion(@root AS INT) RETURNS @PartsExplosion Table
(
  partid INT           NOT NULL,
  qty    DECIMAL(8, 2) NOT NULL,
  unit   VARCHAR(3)    NOT NULL,
  lvl    INT           NOT NULL,
  n      INT           NOT NULL IDENTITY, -- surrogate key
  UNIQUE CLUSTERED(lvl, n)                -- Index will be used to filter lvl
)
AS
BEGIN
  DECLARE @lvl AS INT = 0;       -- Initialize level counter with 0

  -- Insert root node to @PartsExplosion
  INSERT INTO @PartsExplosion(partid, qty, unit, lvl)
    SELECT partid, qty, unit, @lvl
    FROM dbo.BOM
    WHERE partid = @root;

  WHILE @@rowcount > 0           -- while previous level had rows
  BEGIN
    SET @lvl += 1;               -- Increment level counter

    -- Insert next level of subordinates to @PartsExplosion
    INSERT INTO @PartsExplosion(partid, qty, unit, lvl)
      SELECT C.partid, P.qty * C.qty, C.unit, @lvl
      FROM @PartsExplosion AS P  -- P = Parent
        INNER JOIN dbo.BOM AS C  -- C = Child
          ON P.lvl = @lvl - 1    -- Filter parents from previous level
             AND C.assemblyid = P.partid;
  END

  RETURN;
END
GO

-- Parts Explosion
SELECT P.partid, P.partname, PE.qty, PE.unit, PE.lvl
FROM dbo.PartsExplosion(2) AS PE
  INNER JOIN dbo.Parts AS P
    ON P.partid = PE.partid;
GO

-- CTE Solution for Parts Explosion
DECLARE @root AS INT = 2;

WITH PartsExplosion
AS
(
  -- Anchor member returns root part
  SELECT partid, qty, unit, 0 AS lvl
  FROM dbo.BOM
  WHERE partid = @root

  UNION ALL

  -- Recursive member returns next level of parts
  SELECT C.partid, CAST(P.qty * C.qty AS DECIMAL(8, 2)), C.unit, P.lvl + 1
  FROM PartsExplosion AS P
    INNER JOIN dbo.BOM AS C
      ON C.assemblyid = P.partid
)
SELECT P.partid, P.partname, PE.qty, PE.unit, PE.lvl
FROM PartsExplosion AS PE
  INNER JOIN dbo.Parts AS P
    ON P.partid = PE.partid;

-- Parts Explosion, Aggregating Parts
SELECT P.partid, P.partname, PES.qty, PES.unit
FROM (SELECT partid, unit, SUM(qty) AS qty
      FROM dbo.PartsExplosion(2) AS PE
      GROUP BY partid, unit) AS PES
  INNER JOIN dbo.Parts AS P
    ON P.partid = PES.partid;

SELECT P.partid, P.partname, PES.qty, PES.unit
FROM (SELECT partid, unit, SUM(qty) AS qty
      FROM dbo.PartsExplosion(5) AS PE
      GROUP BY partid, unit) AS PES
  INNER JOIN dbo.Parts AS P
    ON P.partid = PES.partid;

-- Creation Script for Function Subordinates2

---------------------------------------------------------------------
-- Function: Subordinates2,
--           Descendants with optional level limit
--
-- Input   : @root      INT: Manager id
--           @maxlevels INT: Max number of levels to return 
--
-- Output  : @Subs TABLE: id and level of subordinates of
--                        input manager in all levels <= @maxlevels
--
-- Process : * Insert into @Subs row of input manager
--           * In a loop, while previous insert loaded more than 0 rows
--             and previous level is smaller than @maxlevels
--             insert into @Subs next level of subordinates
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Subordinates2', N'TF') IS NOT NULL DROP FUNCTION dbo.Subordinates2;
GO
CREATE FUNCTION dbo.Subordinates2 (@root AS INT, @maxlevels AS INT = NULL) RETURNS @Subs TABLE
(
  empid INT NOT NULL PRIMARY KEY NONCLUSTERED,
  lvl   INT NOT NULL,
  UNIQUE CLUSTERED(lvl, empid)        -- Index will be used to filter level
)
AS
BEGIN
  DECLARE @lvl AS INT = 0;            -- Initialize level counter with 0

  -- Insert root node to @Subs
  INSERT INTO @Subs(empid, lvl)
    SELECT empid, @lvl FROM dbo.Employees WHERE empid = @root;

  WHILE @@rowcount > 0                -- while previous level had rows
    AND (@lvl < @maxlevels            -- and haven't reached level limit
         OR @maxlevels IS NULL)       
  BEGIN
    SET @lvl += 1;                    -- Increment level counter

    -- Insert next level of subordinates to @Subs
    INSERT INTO @Subs(empid, lvl)
      SELECT C.empid, @lvl
      FROM @Subs AS P                 -- P = Parent
        INNER JOIN dbo.Employees AS C -- C = Child
          ON P.lvl = @lvl - 1         -- Filter parents from previous level
             AND C.mgrid = P.empid;
  END

  RETURN;
END
GO

-- Descendants of a given node, no limit on levels
SELECT empid, lvl
FROM dbo.Subordinates2(3, NULL) AS S;

-- Descendants of a given node, limit 2 levels
SELECT empid, lvl
FROM dbo.Subordinates2(3, 2) AS S;

-- Descendants that are 2 levels underneath a given node
SELECT empid
FROM dbo.Subordinates2(3, 2) AS S
WHERE lvl = 2;
GO

-- CTE code, with MAXRECURSION

DECLARE @root AS INT = 3;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl 
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, empname, lvl FROM Subs
OPTION (MAXRECURSION 2);
GO

-- Subtree with level limit, CTE Solution, with level column
DECLARE @root AS INT = 3, @maxlevels AS INT = 2;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl 
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
         AND lvl < @maxlevels
)
SELECT empid, empname, lvl
FROM Subs;

---------------------------------------------------------------------
-- Ancestors/Path
---------------------------------------------------------------------

-- Creation Script for Function Managers

---------------------------------------------------------------------
-- Function: Managers, Ancestors with optional level limit
--
-- Input   : @empid INT : Employee id
--           @maxlevels : Max number of levels to return 
--
-- Output  : @Mgrs Table: id and level of managers of
--                        input employee in all levels <= @maxlevels
--
-- Process : * In a loop, while current manager is not null
--             and previous level is smaller than @maxlevels
--             insert into @Mgrs current manager,
--             and get next level manager
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Managers', N'TF') IS NOT NULL DROP FUNCTION dbo.Managers;
GO
CREATE FUNCTION dbo.Managers
  (@empid AS INT, @maxlevels AS INT = NULL) RETURNS @Mgrs TABLE
(
  empid INT NOT NULL PRIMARY KEY,
  lvl   INT NOT NULL
)
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM dbo.Employees WHERE empid = @empid)
    RETURN;  

  DECLARE @lvl AS INT = 0;      -- Initialize level counter with 0

  WHILE @empid IS NOT NULL      -- while current employee has a manager
    AND (@lvl <= @maxlevels     -- and haven't reached level limit
         OR @maxlevels IS NULL)       
  BEGIN
    -- Insert current manager to @Mgrs
    INSERT INTO @Mgrs(empid, lvl) VALUES(@empid, @lvl);
    SET @lvl += 1;              -- Increment level counter
    -- Get next level manager
    SET @empid = (SELECT mgrid FROM dbo.Employees WHERE empid = @empid);
  END

  RETURN;
END
GO

-- Ancestors of a given node, no limit on levels
SELECT empid, lvl
FROM dbo.Managers(8, NULL) AS M;
GO

-- Ancestors of a Given Node, CTE Solution

-- Ancestors of a given node, CTE Solution
DECLARE @empid AS INT = 8;

WITH Mgrs
AS
(
  SELECT empid, mgrid, empname, 0 AS lvl 
  FROM dbo.Employees
  WHERE empid = @empid

  UNION ALL

  SELECT P.empid, P.mgrid, P.empname, C.lvl + 1
  FROM Mgrs AS C
    INNER JOIN dbo.Employees AS P
      ON C.mgrid = P.empid
)
SELECT empid, mgrid, empname, lvl
FROM Mgrs;
GO

-- Ancestors of a given node, limit 2 levels
SELECT empid, lvl
FROM dbo.Managers(8, 2) AS M;

-- Ancestor that is 2 levels above a given node
SELECT empid
FROM dbo.Managers(8, 2) AS M
WHERE lvl = 2;
GO

-- Ancestors with Level Limit, CTE Solution
DECLARE @empid AS INT = 8, @maxlevels AS INT = 2;

WITH Mgrs
AS
(
  SELECT empid, mgrid, empname, 0 AS lvl 
  FROM dbo.Employees
  WHERE empid = @empid

  UNION ALL

  SELECT P.empid, P.mgrid, P.empname, C.lvl + 1
  FROM Mgrs AS C
    INNER JOIN dbo.Employees AS P
      ON C.mgrid = P.empid
         AND lvl < @maxlevels
)
SELECT empid, mgrid, empname, lvl
FROM Mgrs;
GO

---------------------------------------------------------------------
-- Subtree/Subgraph with Path Enumeration
---------------------------------------------------------------------

-- Creation Script for Function Subordinates3

---------------------------------------------------------------------
-- Function: Subordinates3,
--           Descendants with optional level limit,
--           and path enumeration
--
-- Input   : @root      INT: Manager id
--           @maxlevels INT: Max number of levels to return 
--
-- Output  : @Subs TABLE: id, level and materialized ancestors path
--                        of subordinates of input manager
--                        in all levels <= @maxlevels
--
-- Process : * Insert into @Subs row of input manager
--           * In a loop, while previous insert loaded more than 0 rows
--             and previous level is smaller than @maxlevels:
--             - insert into @Subs next level of subordinates
--             - calculate a materialized ancestors path for each
--               by concatenating current node id to parent's path
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Subordinates3', N'TF') IS NOT NULL DROP FUNCTION dbo.Subordinates3;
GO
CREATE FUNCTION dbo.Subordinates3 (@root AS INT, @maxlevels AS INT = NULL) RETURNS @Subs TABLE
(
  empid INT          NOT NULL PRIMARY KEY NONCLUSTERED,
  lvl   INT          NOT NULL,
  path  VARCHAR(896) NOT NULL,
  UNIQUE CLUSTERED(lvl, empid)        -- Index will be used to filter level
)
AS
BEGIN
  DECLARE @lvl AS INT = 0;            -- Initialize level counter with 0

  -- Insert root node to @Subs
  INSERT INTO @Subs(empid, lvl, path)
    SELECT empid, @lvl, '.' + CAST(empid AS VARCHAR(10)) + '.'
    FROM dbo.Employees WHERE empid = @root;

  WHILE @@rowcount > 0                -- while previous level had rows
    AND (@lvl < @maxlevels            -- and haven't reached level limit
         OR @maxlevels IS NULL)       
  BEGIN
    SET @lvl += 1;                    -- Increment level counter

    -- Insert next level of subordinates to @Subs
    INSERT INTO @Subs(empid, lvl, path)
      SELECT C.empid, @lvl, P.path + CAST(C.empid AS VARCHAR(10)) + '.'
      FROM @Subs AS P                 -- P = Parent
        INNER JOIN dbo.Employees AS C -- C = Child
          ON P.lvl = @lvl - 1         -- Filter parents from previous level
             AND C.mgrid = P.empid;
  END

  RETURN;
END
GO

-- Return descendants of a given node, along with a materialized path
SELECT empid, lvl, path
FROM dbo.Subordinates3(1, NULL) AS S;

-- Return descendants of a given node, sorted and indented
SELECT E.empid, REPLICATE(' | ', lvl) + empname AS empname
FROM dbo.Subordinates3(1, NULL) AS S
  INNER JOIN dbo.Employees AS E
    ON E.empid = S.empid
ORDER BY path;
GO

-- Subtree with Path Enumeration, CTE Solution

-- Descendants of a given node, with Materialized Path, CTE Solution
DECLARE @root AS INT = 1;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl,
    -- Path of root = '.' + empid + '.'
    CAST('.' + CAST(empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX)) AS path
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    -- Path of child = parent's path + child empid + '.'
    CAST(P.path + CAST(C.empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX))
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, REPLICATE(' | ', lvl) + empname AS empname
FROM Subs
ORDER BY path;
GO

---------------------------------------------------------------------
-- Sorting
---------------------------------------------------------------------

-- Sorting Hierarchy by empname, CTE Solution
DECLARE @root AS INT = 1;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl,
    -- Path of root is 1 (binary)
    CAST(CAST(1 AS BINARY(4)) AS VARBINARY(MAX)) AS sort_path
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    -- Path of child = parent's path + child row number (binary)
    P.sort_path + CAST(ROW_NUMBER() OVER(PARTITION BY C.mgrid ORDER BY C.empname) AS BINARY(4))
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid,
  ROW_NUMBER() OVER(ORDER BY sort_path) AS sortval, REPLICATE(' | ', lvl) + empname AS empname
FROM Subs
ORDER BY sortval;
GO

-- Sorting Hierarchy by salary, CTE Solution
DECLARE @root AS INT = 1;

WITH Subs
AS
(
  SELECT empid, empname, salary, 0 AS lvl,
    -- Path of root = 1 (binary)
    CAST(CAST(1 AS BINARY(4)) AS VARBINARY(MAX)) AS sort_path
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, C.salary, P.lvl + 1,
    -- Path of child = parent's path + child row number (binary)
    P.sort_path + CAST(ROW_NUMBER() OVER(PARTITION BY C.mgrid ORDER BY C.salary) AS BINARY(4))
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, salary, ROW_NUMBER() OVER(ORDER BY sort_path) AS sortval,
  REPLICATE(' | ', lvl) + empname AS empname
FROM Subs
ORDER BY sortval;

---------------------------------------------------------------------
-- Cycles
---------------------------------------------------------------------

-- Create a cyclic path
UPDATE dbo.Employees SET mgrid = 14 WHERE empid = 1;
GO

-- Detecting Cycles, CTE Solution
DECLARE @root AS INT = 1;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl,
    CAST('.' + CAST(empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX)) AS path,
    -- Obviously root has no cycle
    0 AS cycle
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    CAST(P.path + CAST(C.empid AS VARCHAR(10)) + '.'
         AS VARCHAR(MAX)),
    -- Cycle detected if parent's path contains child's id
    CASE WHEN P.path LIKE '%.' + CAST(C.empid AS VARCHAR(10)) + '.%' THEN 1 ELSE 0 END
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, empname, cycle, path
FROM Subs;
GO

-- Not Pursuing Cycles, CTE Solution
DECLARE @root AS INT = 1;

WITH Subs AS
(
  SELECT empid, empname, 0 AS lvl,
    CAST('.' + CAST(empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX)) AS path,
    -- Obviously root has no cycle
    0 AS cycle
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    CAST(P.path + CAST(C.empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX)),
    -- Cycle detected if parent's path contains child's id
    CASE WHEN P.path LIKE '%.' + CAST(C.empid AS VARCHAR(10)) + '.%' THEN 1 ELSE 0 END
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
         AND P.cycle = 0 -- do not pursue path for parent with cycle
)
SELECT empid, empname, cycle, path
FROM Subs;
GO

-- Isolating Cyclic Paths, CTE Solution
DECLARE @root AS INT = 1;

WITH Subs AS
(
  SELECT empid, empname, 0 AS lvl,
    CAST('.' + CAST(empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX)) AS path,
    -- Obviously root has no cycle
    0 AS cycle
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    CAST(P.path + CAST(C.empid AS VARCHAR(10)) + '.' AS VARCHAR(MAX)),
    -- Cycle detected if parent's path contains child's id
    CASE WHEN P.path LIKE '%.' + CAST(C.empid AS VARCHAR(10)) + '.%' THEN 1 ELSE 0 END
  FROM Subs AS P
    INNER JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
         AND P.cycle = 0
)
SELECT path FROM Subs WHERE cycle = 1;

-- Fix cyclic path
UPDATE dbo.Employees SET mgrid = NULL WHERE empid = 1;

---------------------------------------------------------------------
-- Materialized Path
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Custom Materialized Path
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Maintaining Data
---------------------------------------------------------------------

-- DDL for Employees with Path
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
  empid   INT          NOT NULL,
  mgrid   INT          NULL    ,
  empname VARCHAR(25)  NOT NULL,
  salary  MONEY        NOT NULL,
  lvl     INT          NOT NULL,
  path    VARCHAR(896) NOT NULL 
);

CREATE UNIQUE CLUSTERED INDEX idx_depth_first ON dbo.Employees(path);
CREATE UNIQUE INDEX idx_breadth_first ON dbo.Employees(lvl, path);
ALTER TABLE dbo.Employees ADD CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED(empid);

ALTER TABLE dbo.Employees
  ADD CONSTRAINT FK_Employees_Employees
    FOREIGN KEY(mgrid) REFERENCES dbo.Employees(empid);
GO
 
---------------------------------------------------------------------
-- Adding Employees who Manage No One (Leaves)
---------------------------------------------------------------------

-- Creation Script for Procedure AddEmp

---------------------------------------------------------------------
-- Stored Procedure: AddEmp,
--   Inserts into the table a new employee who manages no one
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.AddEmp', N'P') IS NOT NULL DROP PROC dbo.AddEmp;
GO
CREATE PROC dbo.AddEmp
  @empid   INT,
  @mgrid   INT,
  @empname VARCHAR(25),
  @salary  MONEY
AS

SET NOCOUNT ON;

-- Handle case where the new employee has no manager (root)
IF @mgrid IS NULL
  INSERT INTO dbo.Employees(empid, mgrid, empname, salary, lvl, path)
    VALUES(@empid, @mgrid, @empname, @salary,
      0, '.' + CAST(@empid AS VARCHAR(10)) + '.');--IMO concat('.', @empid, '.') should have been used here.
-- Handle subordinate case (non-root)
ELSE
  INSERT INTO dbo.Employees(empid, mgrid, empname, salary, lvl, path)
    SELECT @empid, @mgrid, @empname, @salary, lvl + 1, path + CAST(@empid AS VARCHAR(10)) + '.' --again, use concat here concat(path, @empid, '.')
    FROM dbo.Employees
    WHERE empid = @mgrid;
GO

-- Sample Data for Employees with Path
EXEC dbo.AddEmp
  @empid = 1, @mgrid = NULL, @empname = 'David', @salary = $10000.00;
EXEC dbo.AddEmp
  @empid = 2, @mgrid = 1, @empname = 'Eitan', @salary = $7000.00;
EXEC dbo.AddEmp
  @empid = 3, @mgrid = 1, @empname = 'Ina', @salary = $7500.00;
EXEC dbo.AddEmp
  @empid = 4, @mgrid = 2, @empname = 'Seraph', @salary = $5000.00;
EXEC dbo.AddEmp
  @empid = 5, @mgrid = 2, @empname = 'Jiru', @salary = $5500.00;
EXEC dbo.AddEmp
  @empid = 6, @mgrid = 2, @empname = 'Steve', @salary = $4500.00;
EXEC dbo.AddEmp
  @empid = 7, @mgrid = 3, @empname = 'Aaron', @salary = $5000.00;
EXEC dbo.AddEmp
  @empid = 8, @mgrid = 5, @empname = 'Lilach', @salary = $3500.00;
EXEC dbo.AddEmp
  @empid = 9, @mgrid = 7, @empname = 'Rita', @salary = $3000.00;
EXEC dbo.AddEmp
  @empid = 10, @mgrid = 5, @empname = 'Sean', @salary = $3000.00;
EXEC dbo.AddEmp
  @empid = 11, @mgrid = 7, @empname = 'Gabriel', @salary = $3000.00;
EXEC dbo.AddEmp
  @empid = 12, @mgrid = 9, @empname = 'Emilia', @salary = $2000.00;
EXEC dbo.AddEmp
  @empid = 13, @mgrid = 9, @empname = 'Michael', @salary = $2000.00;
EXEC dbo.AddEmp
  @empid = 14, @mgrid = 9, @empname = 'Didi', @salary = $1500.00;
GO

-- Examine data after load
SELECT empid, mgrid, empname, salary, lvl, path
FROM dbo.Employees
ORDER BY path;

---------------------------------------------------------------------
-- Moving a Subtree
---------------------------------------------------------------------

-- Creation Script for Procedure MoveSubtree

---------------------------------------------------------------------
-- Stored Procedure: MoveSubtree,
--   Moves a whole subtree of a given root to a new location
--   under a given manager
---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.MoveSubtree', N'P') IS NOT NULL DROP PROC dbo.MoveSubtree;
GO
CREATE PROC dbo.MoveSubtree
  @root  INT,
  @mgrid INT
AS

SET NOCOUNT ON;

BEGIN TRAN;
  -- Update level and path of all employees in the subtree (E)
  -- Set level = 
  --   current level + new manager's level - old manager's level
  -- Set path = 
  --   in current path remove old manager's path 
  --   and substitute with new manager's path
  UPDATE E
    SET lvl  = E.lvl + NM.lvl - OM.lvl,
        path = STUFF(E.path, 1, LEN(OM.path), NM.path)
  FROM dbo.Employees AS E          -- E = Employees    (subtree)
    INNER JOIN dbo.Employees AS R  -- R = Root         (one row)
      ON R.empid = @root
         AND E.path LIKE R.path + '%'
    INNER JOIN dbo.Employees AS OM -- OM = Old Manager (one row)
      ON OM.empid = R.mgrid
    INNER JOIN dbo.Employees AS NM -- NM = New Manager (one row)
      ON NM.empid = @mgrid;
  
  -- Update root's new manager
  UPDATE dbo.Employees SET mgrid = @mgrid WHERE empid = @root;
COMMIT TRAN;
GO

-- Before moving subtree
SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
FROM dbo.Employees
ORDER BY path;

-- Move Subtree
BEGIN TRAN;

  EXEC dbo.MoveSubtree
  @root  = 7,
  @mgrid = 10;

  -- After moving subtree
  SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
  FROM dbo.Employees
  ORDER BY path;

ROLLBACK TRAN; -- rollback used in order not to apply the change

---------------------------------------------------------------------
-- Removing a Subtree
---------------------------------------------------------------------

-- Before deleteting subtree
SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
FROM dbo.Employees
ORDER BY path;

-- Delete Subtree
BEGIN TRAN;

  DELETE FROM dbo.Employees
  WHERE path LIKE 
    (SELECT M.path + '%'
     FROM dbo.Employees as M
     WHERE M.empid = 7);

  -- After deleting subtree
  SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
  FROM dbo.Employees
  ORDER BY path;

ROLLBACK TRAN; -- rollback used in order not to apply the change

---------------------------------------------------------------------
-- Querying Materialized Path
---------------------------------------------------------------------

-- Subtree of a given root
SELECT REPLICATE(' | ', E.lvl - M.lvl) + E.empname
FROM dbo.Employees AS E
  INNER JOIN dbo.Employees AS M
    ON M.empid = 3 -- root
       AND E.path LIKE M.path + '%'
ORDER BY E.path;

-- Subtree of a given root, excluding root
SELECT REPLICATE(' | ', E.lvl - M.lvl - 1) + E.empname
FROM dbo.Employees AS E
  INNER JOIN dbo.Employees AS M
    ON M.empid = 3
       AND E.path LIKE M.path + '_%'
ORDER BY E.path;

-- Leaf nodes under a given root
SELECT E.empid, E.empname
FROM dbo.Employees AS E
  INNER JOIN dbo.Employees AS M
    ON M.empid = 3
       AND E.path LIKE M.path + '%'
WHERE NOT EXISTS
  (SELECT * 
   FROM dbo.Employees AS E2
   WHERE E2.mgrid = E.empid);

-- Subtree of a given root, limit number of levels
SELECT REPLICATE(' | ', E.lvl - M.lvl) + E.empname
FROM dbo.Employees AS E
  INNER JOIN dbo.Employees AS M
    ON M.empid = 3
       AND E.path LIKE M.path + '%'
WHERE E.lvl - M.lvl <= 2
ORDER BY E.path;

-- Nodes that are n levels under a given root
SELECT E.empid, E.empname
FROM dbo.Employees AS E
  INNER JOIN dbo.Employees AS M
    ON M.empid = 3
       AND E.path LIKE M.path + '%'
WHERE E.lvl - M.lvl = 2;

-- Ancestors of a given node (requires a table scan)
SELECT REPLICATE(' | ', M.lvl) + M.empname
FROM dbo.Employees AS E
  INNER JOIN dbo.Employees AS M
    ON E.empid = 14
       AND E.path LIKE M.path + '%'
ORDER BY E.path;

-- Creation Script for Function SplitPath
IF OBJECT_ID(N'dbo.SplitPath', N'IF') IS NOT NULL DROP FUNCTION dbo.SplitPath;
GO
CREATE FUNCTION dbo.SplitPath(@empid AS INT) RETURNS TABLE
AS
RETURN
  SELECT ROW_NUMBER() OVER(ORDER BY n) AS pos,
    CAST(SUBSTRING(path, n + 1, CHARINDEX('.', path, n + 1) - n - 1) AS INT) AS empid
  FROM dbo.Employees
    INNER JOIN TSQLV3.dbo.Nums
      ON empid = @empid
         AND n < LEN(path)
         AND SUBSTRING(path, n, 1) = '.';
GO

-- Test SplitPath function
SELECT pos, empid FROM dbo.SplitPath(14);

-- Getting ancestors using SplitPath function
SELECT REPLICATE(' | ', lvl) + empname
FROM dbo.SplitPath(14) AS SP
  INNER JOIN dbo.Employees AS E
    ON E.empid = SP.empid
ORDER BY path;

-- Presentation
SELECT REPLICATE(' | ', lvl) + empname
FROM dbo.Employees
ORDER BY path;

---------------------------------------------------------------------
-- Materialized Path with the HIERARCHYID Datatype
---------------------------------------------------------------------

IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL,
  hid     HIERARCHYID NOT NULL,
  lvl AS hid.GetLevel() PERSISTED,
  empname VARCHAR(25) NOT NULL,
  salary  MONEY       NOT NULL
);

CREATE UNIQUE CLUSTERED INDEX idx_depth_first ON dbo.Employees(hid);
CREATE UNIQUE INDEX idx_breadth_first ON dbo.Employees(lvl, hid);
ALTER TABLE dbo.Employees ADD CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED(empid);
GO

---------------------------------------------------------------------
-- Maintaining Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Adding Employees
---------------------------------------------------------------------

--------------------------------------------------------------------- 
-- Stored Procedure: AddEmp, 
--   Inserts into the table a new employee who manages no one 
--------------------------------------------------------------------- 
IF OBJECT_ID(N'dbo.AddEmp', N'P') IS NOT NULL DROP PROC dbo.AddEmp;
GO
CREATE PROC dbo.AddEmp
  @empid   AS INT,
  @mgrid   AS INT,
  @empname AS VARCHAR(25),
  @salary  AS MONEY
AS

DECLARE
  @hid            AS HIERARCHYID,
  @mgr_hid        AS HIERARCHYID,
  @last_child_hid AS HIERARCHYID;

BEGIN TRAN;

  IF @mgrid IS NULL
    SET @hid = hierarchyid::GetRoot();
  ELSE
  BEGIN
    SET @mgr_hid = (SELECT hid FROM dbo.Employees WITH (UPDLOCK) WHERE empid = @mgrid);
    SET @last_child_hid = (SELECT MAX(hid) FROM dbo.Employees
                           WHERE hid.GetAncestor(1) = @mgr_hid);
    SET @hid = @mgr_hid.GetDescendant(@last_child_hid, NULL);
  END

  INSERT INTO dbo.Employees(empid, hid, empname, salary)
    VALUES(@empid, @hid, @empname, @salary);
  
COMMIT TRAN;
GO

EXEC dbo.AddEmp @empid =  1, @mgrid = NULL, @empname = 'David'  , @salary = $10000.00;
EXEC dbo.AddEmp @empid =  2, @mgrid =    1, @empname = 'Eitan'  , @salary = $7000.00;
EXEC dbo.AddEmp @empid =  3, @mgrid =    1, @empname = 'Ina'    , @salary = $7500.00;
EXEC dbo.AddEmp @empid =  4, @mgrid =    2, @empname = 'Seraph' , @salary = $5000.00;
EXEC dbo.AddEmp @empid =  5, @mgrid =    2, @empname = 'Jiru'   , @salary = $5500.00;
EXEC dbo.AddEmp @empid =  6, @mgrid =    2, @empname = 'Steve'  , @salary = $4500.00;
EXEC dbo.AddEmp @empid =  7, @mgrid =    3, @empname = 'Aaron'  , @salary = $5000.00;
EXEC dbo.AddEmp @empid =  8, @mgrid =    5, @empname = 'Lilach' , @salary = $3500.00;
EXEC dbo.AddEmp @empid =  9, @mgrid =    7, @empname = 'Rita'   , @salary = $3000.00;
EXEC dbo.AddEmp @empid = 10, @mgrid =    5, @empname = 'Sean'   , @salary = $3000.00;
EXEC dbo.AddEmp @empid = 11, @mgrid =    7, @empname = 'Gabriel', @salary = $3000.00;
EXEC dbo.AddEmp @empid = 12, @mgrid =    9, @empname = 'Emilia' , @salary = $2000.00;
EXEC dbo.AddEmp @empid = 13, @mgrid =    9, @empname = 'Michael', @salary = $2000.00;
EXEC dbo.AddEmp @empid = 14, @mgrid =    9, @empname = 'Didi'   , @salary = $1500.00;
GO

SELECT hid, hid.ToString() AS path, lvl, empid, empname, salary
FROM dbo.Employees
ORDER BY hid;

---------------------------------------------------------------------
-- Moving a Subtree
---------------------------------------------------------------------

SELECT CAST('/1/1/2/3/2/' AS HIERARCHYID).GetReparentedValue('/1/1/', '/2/1/4/').ToString();

--------------------------------------------------------------------- 
-- Stored Procedure: MoveSubtree, 
--   Moves a whole subtree of a given root to a new location 
--   under a given manager 
--------------------------------------------------------------------- 
IF OBJECT_ID(N'dbo.MoveSubtree', N'P') IS NOT NULL DROP PROC dbo.MoveSubtree;
GO
CREATE PROC dbo.MoveSubtree
  @empid     AS INT,
  @new_mgrid AS INT
AS

DECLARE 
  @old_root    AS HIERARCHYID,
  @new_root    AS HIERARCHYID,
  @new_mgr_hid AS HIERARCHYID;

BEGIN TRAN;

  SET @new_mgr_hid = (SELECT hid FROM dbo.Employees WITH (UPDLOCK)
                      WHERE empid = @new_mgrid);
  SET @old_root = (SELECT hid FROM dbo.Employees
                   WHERE empid = @empid);

  -- First, get a new hid for the subtree root employee that moves
  SET @new_root = @new_mgr_hid.GetDescendant
    ((SELECT MAX(hid)
      FROM dbo.Employees
      WHERE hid.GetAncestor(1) = @new_mgr_hid),
     NULL);

  -- Next, reparent all descendants of employee that moves
  UPDATE dbo.Employees
    SET hid = hid.GetReparentedValue(@old_root, @new_root)
  WHERE hid.IsDescendantOf(@old_root) = 1;

COMMIT TRAN;
GO

SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, hid.ToString() AS path
FROM dbo.Employees
ORDER BY hid;

BEGIN TRAN;

  EXEC dbo.MoveSubtree
    @empid    = 5,
    @new_mgrid = 9;

  SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, hid.ToString() AS path
  FROM dbo.Employees
  ORDER BY hid;

ROLLBACK TRAN
GO

---------------------------------------------------------------------
-- Querying
---------------------------------------------------------------------

-- Subgraph/Descendants
SELECT E.empid, E.empname
FROM dbo.Employees AS M
  INNER JOIN dbo.Employees AS E
    ON M.empid = 3
       AND E.hid.IsDescendantOf(M.hid) = 1
WHERE E.lvl - M.lvl <= 3;

-- Ancestors/Path

SELECT M.empid, M.empname
FROM dbo.Employees AS M
  INNER JOIN dbo.Employees AS E
    ON E.empid = 14
       AND E.hid.IsDescendantOf(M.hid) = 1;

-- Direct Subordinates
SELECT E.empid, E.empname
FROM dbo.Employees AS M
  INNER JOIN dbo.Employees AS E
    ON M.empid = 2
       AND E.hid.GetAncestor(1) = M.hid;

-- Leaf nodes
SELECT empid, empname
FROM dbo.Employees AS M
WHERE NOT EXISTS
  (SELECT * FROM dbo.Employees AS E
   WHERE E.hid.GetAncestor(1) = M.hid);

-- Presentation/sorting
SELECT REPLICATE(' | ', lvl) + empname AS empname, hid.ToString() AS path
FROM dbo.Employees
ORDER BY hid;

---------------------------------------------------------------------
-- Further Aspects of Working with HIERARCHYID
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Normalizing HIERARCHYID Values
---------------------------------------------------------------------

--------------------------------------------------------------------- 
-- Stored Procedure: AddEmp, 
--   Inserts into the table a new employee who manages no one
--------------------------------------------------------------------- 
IF OBJECT_ID(N'dbo.AddEmp', N'P') IS NOT NULL DROP PROC dbo.AddEmp;
GO
CREATE PROC dbo.AddEmp
  @empid      AS INT,
  @mgrid      AS INT,
  @leftempid  AS INT,
  @rightempid AS INT,  
  @empname    AS VARCHAR(25),
  @salary     AS MONEY = 1000
AS

DECLARE @hid AS HIERARCHYID;

IF @mgrid IS NULL
  SET @hid = hierarchyid::GetRoot();
ELSE
  SET @hid = (SELECT hid FROM dbo.Employees WHERE empid = @mgrid).GetDescendant
    ( (SELECT hid FROM dbo.Employees WHERE empid = @leftempid),
      (SELECT hid FROM dbo.Employees WHERE empid = @rightempid) );

INSERT INTO dbo.Employees(empid, hid, empname, salary)
  VALUES(@empid, @hid, @empname, @salary);
GO

TRUNCATE TABLE dbo.Employees;

EXEC dbo.AddEmp @empid =  1, @mgrid = NULL, @leftempid = NULL, @rightempid = NULL, @empname = 'A';
EXEC dbo.AddEmp @empid =  2, @mgrid =    1, @leftempid = NULL, @rightempid = NULL, @empname = 'B';
EXEC dbo.AddEmp @empid =  3, @mgrid =    1, @leftempid =    2, @rightempid = NULL, @empname = 'C';
EXEC dbo.AddEmp @empid =  4, @mgrid =    1, @leftempid =    2, @rightempid =    3, @empname = 'D';
EXEC dbo.AddEmp @empid =  5, @mgrid =    1, @leftempid =    4, @rightempid =    3, @empname = 'E';
EXEC dbo.AddEmp @empid =  6, @mgrid =    1, @leftempid =    4, @rightempid =    5, @empname = 'F';
EXEC dbo.AddEmp @empid =  7, @mgrid =    1, @leftempid =    6, @rightempid =    5, @empname = 'G';
EXEC dbo.AddEmp @empid =  8, @mgrid =    1, @leftempid =    6, @rightempid =    7, @empname = 'H';
EXEC dbo.AddEmp @empid =  9, @mgrid =    8, @leftempid = NULL, @rightempid = NULL, @empname = 'I';
EXEC dbo.AddEmp @empid = 10, @mgrid =    8, @leftempid =    9, @rightempid = NULL, @empname = 'J';
EXEC dbo.AddEmp @empid = 11, @mgrid =    8, @leftempid =    9, @rightempid =   10, @empname = 'K';
EXEC dbo.AddEmp @empid = 12, @mgrid =    8, @leftempid =   11, @rightempid =   10, @empname = 'J';
EXEC dbo.AddEmp @empid = 13, @mgrid =    8, @leftempid =   11, @rightempid =   12, @empname = 'L';
EXEC dbo.AddEmp @empid = 14, @mgrid =    8, @leftempid =   13, @rightempid =   12, @empname = 'M';
EXEC dbo.AddEmp @empid = 15, @mgrid =    8, @leftempid =   13, @rightempid =   14, @empname = 'N';
EXEC dbo.AddEmp @empid = 16, @mgrid =    8, @leftempid =   15, @rightempid =   14, @empname = 'O';
EXEC dbo.AddEmp @empid = 17, @mgrid =    8, @leftempid =   15, @rightempid =   16, @empname = 'P';
EXEC dbo.AddEmp @empid = 18, @mgrid =    8, @leftempid =   17, @rightempid =   16, @empname = 'Q';
EXEC dbo.AddEmp @empid = 19, @mgrid =    8, @leftempid =   17, @rightempid =   18, @empname = 'E';
EXEC dbo.AddEmp @empid = 20, @mgrid =    8, @leftempid =   19, @rightempid =   18, @empname = 'S';
EXEC dbo.AddEmp @empid = 21, @mgrid =    8, @leftempid =   19, @rightempid =   20, @empname = 'T';
GO

-- Data before normalization
SELECT empid, REPLICATE(' | ', lvl) + empname AS emp, hid, hid.ToString() AS path
FROM dbo.Employees
ORDER BY hid;

-- Normalize
WITH EmpsRN AS
(
  SELECT empid, hid, ROW_NUMBER() OVER(PARTITION BY hid.GetAncestor(1) ORDER BY hid) AS rownum
  FROM dbo.Employees
),
EmpPaths AS
(
  SELECT empid, hid, CAST('/' AS VARCHAR(900)) AS path
  FROM dbo.Employees
  WHERE hid = hierarchyid::GetRoot()
  
  UNION ALL
  
  SELECT C.empid, C.hid, CAST(P.path + CAST(C.rownum AS VARCHAR(20)) + '/' AS VARCHAR(900))
  FROM EmpPaths AS P
    INNER JOIN EmpsRN AS C
      ON C.hid.GetAncestor(1) = P.hid
)
UPDATE E
  SET hid = CAST(EP.path AS HIERARCHYID)
FROM dbo.Employees AS E
  INNER JOIN EmpPaths AS EP
    ON E.empid = EP.empid;

-- Data after normalization
SELECT empid, REPLICATE(' | ', lvl) + empname AS emp, hid, hid.ToString() AS path
FROM dbo.Employees
ORDER BY hid;

---------------------------------------------------------------------
-- Convert parent-child representation to new hierarchyid
---------------------------------------------------------------------

-- create and populate the EmployeesOld table
IF OBJECT_ID(N'dbo.EmployeesOld', N'U') IS NOT NULL DROP TABLE dbo.EmployeesOld;
IF OBJECT_ID(N'dbo.EmployeesNew', N'U') IS NOT NULL DROP TABLE dbo.EmployeesNew;
GO
CREATE TABLE dbo.EmployeesOld
(
  empid   INT                   CONSTRAINT PK_EmployeesOld PRIMARY KEY,
  mgrid   INT              NULL CONSTRAINT FK_EmpsOld_EmpsOld REFERENCES dbo.EmployeesOld,
  empname VARCHAR(25)  NOT NULL,
  salary  MONEY        NOT NULL
);
CREATE UNIQUE INDEX idx_unc_mgrid_empid ON dbo.EmployeesOld(mgrid, empid);

INSERT INTO dbo.EmployeesOld(empid, mgrid, empname, salary) VALUES
  (1,  NULL, 'David',  $10000.00),
  (2,  1,    'Eitan',   $7000.00),
  (3,  1,    'Ina',     $7500.00),
  (4,  2,    'Seraph',  $5000.00),
  (5,  2,    'Jiru',    $5500.00),
  (6,  2,    'Steve',   $4500.00),
  (7,  3,    'Aaron',   $5000.00),
  (8,  5,    'Lilach',  $3500.00),
  (9,  7,    'Rita',    $3000.00),
  (10, 5,    'Sean',    $3000.00),
  (11, 7,    'Gabriel', $3000.00),
  (12, 9,    'Emilia' , $2000.00),
  (13, 9,    'Michael', $2000.00),
  (14, 9,    'Didi',    $1500.00);
GO

-- create the EmployeesNew table
CREATE TABLE dbo.EmployeesNew
(
  empid   INT         NOT NULL,
  hid     HIERARCHYID NOT NULL,
  lvl AS hid.GetLevel() PERSISTED,
  empname VARCHAR(25) NOT NULL,
  salary  MONEY       NOT NULL
);
GO

-- convert data
WITH EmpsRN
AS
(
  SELECT empid, mgrid, empname, salary,
    ROW_NUMBER() OVER(PARTITION BY mgrid ORDER BY empid) AS rn
  FROM dbo.EmployeesOld
),
EmpPaths AS
(
  SELECT empid, mgrid, empname, salary,
    CAST('/' AS VARCHAR(900)) AS cpath
  FROM dbo.EmployeesOld
  WHERE mgrid IS NULL
  
  UNION ALL
  
  SELECT C.empid, C.mgrid, C.empname, C.salary,
    CAST(cpath + CAST(C.rn AS VARCHAR(20)) + '/' AS VARCHAR(900))
  FROM EmpPaths AS P
    INNER JOIN EmpsRN AS C
      ON C.mgrid = P.empid
)
INSERT INTO dbo.EmployeesNew WITH (TABLOCK) (empid, empname, salary, hid)
  SELECT empid, empname, salary, CAST(cpath AS HIERARCHYID) AS hid
  FROM EmpPaths;

-- create indexes
CREATE UNIQUE CLUSTERED INDEX idx_depth_first ON dbo.EmployeesNew(hid);
CREATE UNIQUE INDEX idx_breadth_first ON dbo.EmployeesNew(lvl, hid);
ALTER TABLE dbo.EmployeesNew ADD CONSTRAINT PK_EmployeesNew PRIMARY KEY NONCLUSTERED(empid);

-- query data  
SELECT REPLICATE(' | ', lvl) + empname AS empname, hid.ToString() AS path
FROM dbo.EmployeesNew
ORDER BY hid;

---------------------------------------------------------------------
-- Sorting Separated Lists of Values
---------------------------------------------------------------------

IF OBJECT_ID(N'dbo.IPs', N'U') IS NOT NULL DROP TABLE dbo.IPs;
GO
-- Creation script for table IPs
CREATE TABLE dbo.IPs
(
  ip varchar(15) NOT NULL,
  CONSTRAINT PK_IPs PRIMARY KEY(ip),
  -- CHECK constraint that validates IPs
  CONSTRAINT CHK_IP_valid CHECK
  (
      -- 3 periods and no empty octets
      ip LIKE '_%._%._%._%'
    AND
      -- not 4 periods or more
      ip NOT LIKE '%.%.%.%.%'
    AND
      -- no characters other than digits and periods
      ip NOT LIKE '%[^0-9.]%'
    AND
      -- not more than 3 digits per octet
      ip NOT LIKE '%[0-9][0-9][0-9][0-9]%'
    AND
      -- NOT 300 - 999
      ip NOT LIKE '%[3-9][0-9][0-9]%'
    AND
      -- NOT 260 - 299
      ip NOT LIKE '%2[6-9][0-9]%'
    AND
      -- NOT 256 - 259
      ip NOT LIKE '%25[6-9]%'
  )
);
GO

-- Sample data
INSERT INTO dbo.IPs(ip) VALUES
  ('131.107.2.201'),
  ('131.33.2.201'),
  ('131.33.2.202'),
  ('3.107.2.4'),
  ('3.107.3.169'),
  ('3.107.104.172'),
  ('22.107.202.123'),
  ('22.20.2.77'),
  ('22.156.9.91'),
  ('22.156.89.32');
GO

-- IP Patterns
IF OBJECT_ID(N'dbo.IPPatterns', N'V') IS NOT NULL DROP VIEW dbo.IPPatterns;
GO
CREATE VIEW dbo.IPPatterns
AS

SELECT
  REPLICATE('_', N1.n) + '.' + REPLICATE('_', N2.n) + '.'
    + REPLICATE('_', N3.n) + '.' + REPLICATE('_', N4.n) AS pattern,
  N1.n AS l1, N2.n AS l2, N3.n AS l3, N4.n AS l4,
  1 AS s1, N1.n+2 AS s2, N1.n+N2.n+3 AS s3, N1.n+N2.n+N3.n+4 AS s4
FROM TSQLV3.dbo.Nums AS N1 CROSS JOIN TSQLV3.dbo.Nums AS N2
  CROSS JOIN TSQLV3.dbo.Nums AS N3 CROSS JOIN TSQLV3.dbo.Nums AS N4
WHERE N1.n <= 3 AND N2.n <= 3 AND N3.n <= 3 AND N4.n <= 3;
GO

SELECT pattern, l1, l2, l3, l4, s1, s2, s3, s4 FROM dbo.IPPatterns;

-- Sort IPs, solution 1
SELECT ip
FROM dbo.IPs
  INNER JOIN dbo.IPPatterns
    ON ip LIKE pattern
ORDER BY
  CAST(SUBSTRING(ip, s1, l1) AS TINYINT),
  CAST(SUBSTRING(ip, s2, l2) AS TINYINT),
  CAST(SUBSTRING(ip, s3, l3) AS TINYINT),
  CAST(SUBSTRING(ip, s4, l4) AS TINYINT);

-- Sort IPs, solution 2
SELECT ip
FROM dbo.IPs
ORDER BY CAST('/' + ip + '/' AS HIERARCHYID);

-- Generic form of problem
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
GO
CREATE TABLE dbo.T1
(
  id  INT          NOT NULL IDENTITY PRIMARY KEY,
  val VARCHAR(500) NOT NULL
);

INSERT INTO dbo.T1(val) VALUES
  ('100'),
  ('7,4,250'),
  ('22,40,5,60,4,100,300,478,19710212'),
  ('22,40,5,60,4,99,300,478,19710212'),
  ('22,40,5,60,4,99,300,478,9999999'),
  ('10,30,40,50,20,30,40'),
  ('7,4,250'),
  ('-1'),
  ('-2'),
  ('-11'),
  ('-22'),
  ('-123'),
  ('-321'),
  ('22,40,5,60,4,-100,300,478,19710212'),
  ('22,40,5,60,4,-99,300,478,19710212');

SELECT id, val
FROM dbo.T1
ORDER BY CAST('/' + REPLACE(val, ',', '/') + '/' AS HIERARCHYID);

---------------------------------------------------------------------
-- Nested Sets
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Assigning Left and Right Values 
---------------------------------------------------------------------

-- Producing Binary Sort Paths Representing Nested Sets Relationships

-- Create index to speed sorting siblings by empname, empid
CREATE UNIQUE INDEX idx_unc_mgrid_empname_empid ON dbo.Employees(mgrid, empname, empid);
GO

DECLARE @root AS INT = 1;

-- CTE with two numbers: 1 and 2
WITH TwoNums AS
(
  SELECT n FROM (VALUES(1),(2)) AS D(n)
),
-- CTE with two binary sort paths for each node:
--   One smaller than descendants sort paths
--   One greater than descendants sort paths
SortPath AS
(
  SELECT empid, 0 AS lvl, n, CAST(CAST(n AS BINARY(4)) AS VARBINARY(MAX)) AS sort_path
  FROM dbo.Employees CROSS JOIN TwoNums
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, P.lvl + 1, TN.n, 
    P.sort_path + CAST(
      (-1 + ROW_NUMBER() OVER(PARTITION BY C.mgrid
                              -- *** determines order of siblings ***
                              ORDER BY C.empname, C.empid)) / 2 * 2 + TN.n
      AS BINARY(4))
  FROM SortPath AS P
    INNER JOIN dbo.Employees AS C
      ON P.n = 1
         AND C.mgrid = P.empid
    CROSS JOIN TwoNums AS TN
)
SELECT empid, lvl, n, sort_path FROM SortPath
ORDER BY sort_path;
GO

-- CTE Code That Creates Nested Sets Relationships
DECLARE @root AS INT = 1; 
 
-- CTE with two numbers: 1 and 2 
WITH TwoNums AS 
( 
  SELECT n FROM (VALUES(1),(2)) AS D(n)
), 
-- CTE with two binary sort paths for each node: 
--   One smaller than descendants sort paths 
--   One greater than descendants sort paths 
SortPath AS 
( 
  SELECT empid, 0 AS lvl, n, CAST(CAST(n AS BINARY(4)) AS VARBINARY(MAX)) AS sort_path 
  FROM dbo.Employees CROSS JOIN TwoNums 
  WHERE empid = @root 
 
  UNION ALL 
 
  SELECT C.empid, P.lvl + 1, TN.n,  
    P.sort_path + CAST( 
      (-1 + ROW_NUMBER() OVER(PARTITION BY C.mgrid 
                              -- *** determines order of siblings *** 
                              ORDER BY C.empname, C.empid)) / 2 * 2 + TN.n 
      AS BINARY(4)) 
  FROM SortPath AS P 
    INNER JOIN dbo.Employees AS C 
      ON P.n = 1 
         AND C.mgrid = P.empid 
    CROSS JOIN TwoNums AS TN 
), 
-- CTE with Row Numbers Representing sort_path Order 
Sort AS 
( 
  SELECT empid, lvl, ROW_NUMBER() OVER(ORDER BY sort_path) AS sortval 
  FROM SortPath 
), 
-- CTE with Left and Right Values Representing 
-- Nested Sets Relationships 
NestedSets AS 
( 
  SELECT empid, lvl, MIN(sortval) AS lft, MAX(sortval) AS rgt 
  FROM Sort 
  GROUP BY empid, lvl 
) 
SELECT empid, lvl, lft, rgt FROM NestedSets 
ORDER BY lft; 
GO

-- Materializing Nested Sets Relationships in a Table 
DECLARE @root AS INT = 1;
 
WITH TwoNums AS 
( 
  SELECT n FROM (VALUES(1),(2)) AS D(n)
), 
SortPath AS 
( 
  SELECT empid, 0 AS lvl, n, CAST(CAST(n AS BINARY(4)) AS VARBINARY(MAX)) AS sort_path 
  FROM dbo.Employees CROSS JOIN TwoNums 
  WHERE empid = @root 
 
  UNION ALL 
 
  SELECT C.empid, P.lvl + 1, TN.n,  
    P.sort_path + CAST( 
      (-1 + ROW_NUMBER() OVER(PARTITION BY C.mgrid 
                              -- *** determines order of siblings *** 
                              ORDER BY C.empname, C.empid)) / 2 * 2 + TN.n 
      AS BINARY(4)) 
  FROM SortPath AS P 
    INNER JOIN dbo.Employees AS C 
      ON P.n = 1 
         AND C.mgrid = P.empid 
    CROSS JOIN TwoNums AS TN 
), 
Sort AS 
( 
  SELECT empid, lvl, ROW_NUMBER() OVER(ORDER BY sort_path) AS sortval 
  FROM SortPath 
), 
NestedSets AS 
( 
  SELECT empid, lvl, MIN(sortval) AS lft, MAX(sortval) AS rgt 
  FROM Sort 
  GROUP BY empid, lvl 
) 
SELECT E.empid, E.empname, E.salary, NS.lvl, NS.lft, NS.rgt 
INTO dbo.EmployeesNS 
FROM NestedSets AS NS 
  INNER JOIN dbo.Employees AS E 
    ON E.empid = NS.empid; 
 
CREATE UNIQUE CLUSTERED INDEX idx_uc_lft ON dbo.EmployeesNS(lft);
ALTER TABLE dbo.EmployeesNS ADD PRIMARY KEY NONCLUSTERED(empid);
GO

---------------------------------------------------------------------
-- Querying
---------------------------------------------------------------------

-- Descendants of a given root
SELECT C.empid, REPLICATE(' | ', C.lvl - P.lvl) + C.empname AS empname 
FROM dbo.EmployeesNS AS P 
  INNER JOIN dbo.EmployeesNS AS C 
    ON P.empid = 3 
       AND C.lft BETWEEN P.lft AND P.rgt
ORDER BY C.lft;

-- Descendants of a given root, limiting 2 levels
SELECT C.empid, REPLICATE(' | ', C.lvl - P.lvl) + C.empname AS empname
FROM dbo.EmployeesNS AS P
  INNER JOIN dbo.EmployeesNS AS C
    ON P.empid = 3
       AND C.lft BETWEEN P.lft AND P.rgt
WHERE C.lvl - P.lvl <= 2 
ORDER BY C.lft;

-- Leaf nodes under a given root
SELECT C.empid, C.empname
FROM dbo.EmployeesNS AS P
  INNER JOIN dbo.EmployeesNS AS C
    ON P.empid = 3
       AND C.lft BETWEEN P.lft AND P.rgt
WHERE C.rgt - C.lft = 1;

-- Count of subordinates of each node
SELECT empid, (rgt - lft - 1) / 2 AS cnt, REPLICATE(' | ', lvl) + empname AS empname
FROM dbo.EmployeesNS
ORDER BY lft;

-- Ancestors of a given node
SELECT P.empid, P.empname, P.lvl
FROM dbo.EmployeesNS AS P
  INNER JOIN dbo.EmployeesNS AS C
    ON C.empid = 14
       AND C.lft BETWEEN P.lft AND P.rgt;
GO

-- Cleanup
DROP TABLE dbo.EmployeesNS;
GO

---------------------------------------------------------------------
-- Transitive Closure
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Directed Acyclic Graph (DAG)
---------------------------------------------------------------------

-- Transitive Closure of BOM (DAG)
WITH BOMTC AS
(
  -- Return all first-level containment relationships
  SELECT assemblyid, partid
  FROM dbo.BOM
  WHERE assemblyid IS NOT NULL

  UNION ALL

  -- Return next-level containment relationships
  SELECT P.assemblyid, C.partid
  FROM BOMTC AS P
    INNER JOIN dbo.BOM AS C
      ON C.assemblyid = P.partid
)
-- Return distinct pairs that have
-- transitive containment relationships
SELECT DISTINCT assemblyid, partid
FROM BOMTC;
GO

-- Listing 11-4: Creation Script for the BOMTC UDF
IF OBJECT_ID(N'dbo.BOMTC', N'TF') IS NOT NULL DROP FUNCTION dbo.BOMTC;
GO
CREATE FUNCTION BOMTC() RETURNS @BOMTC TABLE
(
  assemblyid INT NOT NULL,
  partid     INT NOT NULL,
  PRIMARY KEY (assemblyid, partid)
)
AS
BEGIN
  INSERT INTO @BOMTC(assemblyid, partid)
    SELECT assemblyid, partid
    FROM dbo.BOM
    WHERE assemblyid IS NOT NULL

  WHILE @@rowcount > 0
    INSERT INTO @BOMTC(assemblyid, partid)
      SELECT P.assemblyid, C.partid
      FROM @BOMTC AS P
        INNER JOIN dbo.BOM AS C
          ON C.assemblyid = P.partid
      WHERE NOT EXISTS
        (SELECT * FROM @BOMTC AS P2
         WHERE P2.assemblyid = P.assemblyid
         AND P2.partid = C.partid);

  RETURN;
END
GO

-- Use the BOMTC UDF
SELECT assemblyid, partid FROM BOMTC();
GO

-- All Paths in BOM
WITH BOMPaths AS
(
  SELECT assemblyid, partid, 1 AS distance, -- distance in first level is 1
    -- path in first level is .assemblyid.partid.
    '.' + CAST(assemblyid AS VARCHAR(MAX)) +
    '.' + CAST(partid     AS VARCHAR(MAX)) + '.' AS path
  FROM dbo.BOM
  WHERE assemblyid IS NOT NULL

  UNION ALL

  SELECT P.assemblyid, C.partid,
    -- distance in next level is parent's distance + 1
    P.distance + 1,
    -- path in next level is parent_path.child_partid.
    P.path + CAST(C.partid AS VARCHAR(MAX)) + '.'
  FROM BOMPaths AS P
    INNER JOIN dbo.BOM AS C
      ON C.assemblyid = P.partid
)
-- Return all paths
SELECT assemblyid, partid, distance, path
FROM BOMPaths;

-- Shortest Paths in BOM
WITH BOMPaths AS -- All paths
(
  SELECT assemblyid, partid, 1 AS distance,
    '.' + CAST(assemblyid AS VARCHAR(MAX)) +
    '.' + CAST(partid     AS VARCHAR(MAX)) + '.' AS path
  FROM dbo.BOM
  WHERE assemblyid IS NOT NULL

  UNION ALL

  SELECT P.assemblyid, C.partid, P.distance + 1,
    P.path + CAST(C.partid AS VARCHAR(MAX)) + '.'
  FROM BOMPaths AS P
    INNER JOIN dbo.BOM AS C
      ON C.assemblyid = P.partid
),
BOMRnk AS -- Rank paths
(
  SELECT *, RANK() OVER(PARTITION BY assemblyid, partid ORDER BY distance) AS rnk
  FROM BOMPaths
)
-- Shortest path for each pair
SELECT assemblyid, partid, distance, path
FROM BOMRnk
WHERE rnk = 1;
GO

---------------------------------------------------------------------
-- Undirected Cyclic Graph
---------------------------------------------------------------------

-- Transitive Closure of Roads (Undirected Cyclic Graph)
WITH Roads2 AS -- Two rows for each pair (f-->t, t-->f)
(
  SELECT city1 AS from_city, city2 AS to_city FROM dbo.Roads
  UNION ALL
  SELECT city2, city1 FROM dbo.Roads
),
RoadPaths AS
(
  -- Return all first-level reachability pairs
  SELECT from_city, to_city,
    -- path is needed to identify cycles
    CAST('.' + from_city + '.' + to_city + '.' AS VARCHAR(MAX)) AS path
  FROM Roads2

  UNION ALL

  -- Return next-level reachability pairs
  SELECT F.from_city, T.to_city, CAST(F.path + T.to_city + '.' AS VARCHAR(MAX))
  FROM RoadPaths AS F
    INNER JOIN Roads2 AS T
      -- if to_city appears in from_city's path, cycle detected
      ON CASE WHEN F.path LIKE '%.' + T.to_city + '.%'
              THEN 1 ELSE 0 END = 0
         AND F.to_city = T.from_city
)
-- Return Transitive Closure of Roads
SELECT DISTINCT from_city, to_city
FROM RoadPaths;
GO

--ramneek: this is my attempt at version transitive closure for roads
--create a transitive closure. But first create a directed graph which would include cycles which we can handle while traversing the data
;with cte as
(
	select city1 as fromCity, city2 as toCity
	from dbo.roads
	union 
	select city2, city1
	from dbo.roads
)
select *
into #DirectedData
from cte

--this will fail even with a high MAXRECURSION limit due to cycles in paths. Now to detect cycles in a recursive CTE, we have to make use of a 'Path' derived column
--as we can't access data from more than one level/depth prior to current level. 
;with RoadsTC as
(
	select fromCity, toCity,  cast('.' + fromCity + '.' +  toCity + '.' as nvarchar(max)) as path, 1 as lvl
	from #DirectedData

	union all

	select RoadsTC.fromCity, linkage.toCity, cast(RoadsTC.path + linkage.toCity + '.' as nvarchar(max)) as path, RoadsTC.lvl + 1 as lvl
	from #DirectedData as linkage inner join RoadsTC on RoadsTC.toCity = linkage.fromCity
	and not (path like + '%.' + linkage.toCity + '.%' )

),
pathCosts as
(
	select *
	--, min(lvl) over (partition by fromCity, toCity )
	--, row_number() over (partition by fromCity, toCity order by lvl) as rn
	, rank() over (partition by fromCity, toCity order by lvl) as rn
	from RoadsTC
)
select *
from pathCosts 
where rn=1
order by fromCity, toCity
OPTION (MAXRECURSION 10000)
go

--ramneekm:end

-- Creation Script for the RoadsTC UDF
IF OBJECT_ID(N'dbo.RoadsTC', N'TF') IS NOT NULL DROP FUNCTION dbo.RoadsTC;
GO
CREATE FUNCTION dbo.RoadsTC() RETURNS @RoadsTC TABLE
(
  from_city VARCHAR(3) NOT NULL,
  to_city   VARCHAR(3) NOT NULL,
  PRIMARY KEY (from_city, to_city)
)
AS
BEGIN
  DECLARE @added as INT;

  INSERT INTO @RoadsTC(from_city, to_city)
    SELECT city1, city2 FROM dbo.Roads;

  SET @added = @@rowcount;

  INSERT INTO @RoadsTC
    SELECT city2, city1 FROM dbo.Roads

  SET @added = @added + @@rowcount;

  WHILE @added > 0 BEGIN

    INSERT INTO @RoadsTC
      SELECT DISTINCT TC.from_city, R.city2
      FROM @RoadsTC AS TC
        INNER JOIN dbo.Roads AS R
          ON R.city1 = TC.to_city
      WHERE NOT EXISTS
        (SELECT * FROM @RoadsTC AS TC2
         WHERE TC2.from_city = TC.from_city
           AND TC2.to_city = R.city2)
        AND TC.from_city <> R.city2;

    SET @added = @@rowcount;

    INSERT INTO @RoadsTC
      SELECT DISTINCT TC.from_city, R.city1
      FROM @RoadsTC AS TC
        INNER JOIN dbo.Roads AS R
          ON R.city2 = TC.to_city
      WHERE NOT EXISTS
        (SELECT * FROM @RoadsTC AS TC2
         WHERE TC2.from_city = TC.from_city
           AND TC2.to_city = R.city1)
        AND TC.from_city <> R.city1;

    SET @added = @added + @@rowcount;
  END
  RETURN;
END
GO

-- Use the RoadsTC UDF
SELECT from_city, to_city FROM dbo.RoadsTC();
GO

--ramneek: my version(s) of tbe above query

create or alter function pathsTC_with_problem () 
returns @minPathsTC table 
(
	fromCity nvarchar(50) not null,
	toCity nvarchar(50) not null,
	path nvarchar(max) not null,
	lvl int not null
)
begin 
	
	insert into @minPathsTC (fromCity, toCity, path, lvl)
		select DirectedData.fromCity, DirectedData.toCity,  cast('.' + fromCity + '.' +  toCity + '.' as nvarchar(max)) as path, 1 as lvl
		from (select city1 as fromCity, city2 as toCity
					from dbo.roads
					union 
					select city2, city1
					from dbo.roads) as DirectedData;

		while @@ROWCOUNT > 0
		begin
			insert into @minPathsTC (fromCity, toCity, path, lvl)
				select RoadsTC.fromCity, linkage.toCity, cast(RoadsTC.path + linkage.toCity + '.' as nvarchar(max)) as path, RoadsTC.lvl + 1 as lvl
				from (select city1 as fromCity, city2 as toCity from dbo.roads union select city2, city1 from dbo.roads) 
					as linkage inner join @minPathsTC as RoadsTC on RoadsTC.toCity = linkage.fromCity
					and not (path like + '%.' + linkage.toCity + '.%' ) --condition 1:  circular path check
					and not exists (select 1 from @minPathsTC as b where b.fromCity = RoadsTC.fromCity and b.toCity=linkage.toCity and b.lvl=RoadsTC.lvl + 1 );--condition 2
			--we are checking if a same cost already path exists in the table before adding new data. but the problem is that there would also be same cost paths in the 
			--data we are trying to add using this SELECT statement (data that is not in the table. Hence our check would fail.)

			--the issue is that instead of joining with with minPathsTC staging table, add a rownumber column to data that is being added (partition by fromCity, toCity order by lvl)
			--, just like in recursive CTE solution above, and then only select rn=1 rows to be added into minPathsTC. 
			
			--Try this as well: Now because it is breadth first search, we can assume that is a path (fromCity, toCity) already exists, then that would be a lower (or equal cost path). 
			--Hence, remove the predicate: [and b.lvl=RoadsTC.lvl + 1]. Even if we were to use this predicate, change it to [and b.lvl <= RoadsTC.lvl + 1 ]
			
		end

		return;
end
go

create or alter function pathsTC_subquery () 
returns @minPathsTC table 
(
	fromCity nvarchar(50) not null,
	toCity nvarchar(50) not null,
	path nvarchar(max) not null,
	lvl int not null
)
begin 
	
	insert into @minPathsTC (fromCity, toCity, path, lvl)
		select DirectedData.fromCity, DirectedData.toCity,  cast('.' + fromCity + '.' +  toCity + '.' as nvarchar(max)) as path, 1 as lvl
		from (select city1 as fromCity, city2 as toCity
					from dbo.roads
					union 
					select city2, city1
					from dbo.roads) as DirectedData;

		while @@ROWCOUNT > 0
		begin
			--new query with fix using nested subqueries
			insert into @minPathsTC (fromCity, toCity, path, lvl)
				select c.fromCity, c.toCity, c.path, c.lvl
				from (
					select b.fromCity, b.toCity, b.path, b.lvl, rank() over(partition by fromCity, toCity order by lvl) as rn--use rank , not row_number
						from(select RoadsTC.fromCity, linkage.toCity, cast(RoadsTC.path + linkage.toCity + '.' as nvarchar(max)) as path, RoadsTC.lvl + 1 as lvl
							from (select city1 as fromCity, city2 as toCity from dbo.roads union select city2, city1 from dbo.roads) 
								as linkage inner join @minPathsTC as RoadsTC on RoadsTC.toCity = linkage.fromCity
								and not (path like + '%.' + linkage.toCity + '.%' ) --condition 1:  circular path check
								and not exists (select 1 from @minPathsTC as b where b.fromCity = RoadsTC.fromCity and b.toCity=linkage.toCity and b.lvl<=RoadsTC.lvl + 1 )--condition 2
						)as b
					)as c
				where rn=1;		
		end

		return;
end
go

create or alter function pathsTC_CTE () 
returns @minPathsTC table 
(
	fromCity nvarchar(50) not null,
	toCity nvarchar(50) not null,
	path nvarchar(max) not null,
	lvl int not null
)
begin 
	
	insert into @minPathsTC (fromCity, toCity, path, lvl)
		select DirectedData.fromCity, DirectedData.toCity,  cast('.' + fromCity + '.' +  toCity + '.' as nvarchar(max)) as path, 1 as lvl
		from (select city1 as fromCity, city2 as toCity
					from dbo.roads
					union 
					select city2, city1
					from dbo.roads) as DirectedData;

		while @@ROWCOUNT > 0
		begin
			--query written using CTE. Exactly same as above subquery version
			;with linkage as
				(select city1 as fromCity, city2 as toCity from dbo.roads union select city2, city1 from dbo.roads)
			,furtherPaths as 
				(select RoadsTC.fromCity, linkage.toCity, cast(RoadsTC.path + linkage.toCity + '.' as nvarchar(max)) as path, RoadsTC.lvl + 1 as lvl
								from linkage inner join @minPathsTC as RoadsTC on RoadsTC.toCity = linkage.fromCity
									and not (path like + '%.' + linkage.toCity + '.%' ) --condition 1:  circular path check
									and not exists (select 1 from @minPathsTC as b where b.fromCity = RoadsTC.fromCity and b.toCity=linkage.toCity and b.lvl<=RoadsTC.lvl + 1 )--condition 2
				)
			,sortByCostFurtherPaths as
				(select furtherPaths.fromCity, furtherPaths.toCity, furtherPaths.path, furtherPaths.lvl, rank() over(partition by fromCity, toCity order by lvl) as rn--use rank , not row_number
						from furtherPaths)
			insert into @minPathsTC (fromCity, toCity, path, lvl)
				select sortByCostFurtherPaths.fromCity, sortByCostFurtherPaths.toCity, sortByCostFurtherPaths.path, sortByCostFurtherPaths.lvl
				from sortByCostFurtherPaths
				where rn=1;
		
		end

		return;
end
go

select *
from pathsTC_subquery()

select *
from pathsTC_CTE()


--end:ramneek

-- All paths and distances in Roads (15262 rows)
;WITH Roads2 AS
(
  SELECT city1 AS from_city, city2 AS to_city, distance FROM dbo.Roads
  UNION ALL
  SELECT city2, city1, distance FROM dbo.Roads
),
RoadPaths AS
(
  SELECT from_city, to_city, distance,
    CAST('.' + from_city + '.' + to_city + '.' AS VARCHAR(MAX)) AS path
  FROM Roads2

  UNION ALL

  SELECT F.from_city, T.to_city, F.distance + T.distance,
    CAST(F.path + T.to_city + '.' AS VARCHAR(MAX))
  FROM RoadPaths AS F
    INNER JOIN Roads2 AS T
      ON CASE WHEN F.path LIKE '%.' + T.to_city + '.%'
              THEN 1 ELSE 0 END = 0
         AND F.to_city = T.from_city
)
-- Return all paths and distances
SELECT from_city, to_city, distance, path
FROM RoadPaths;

-- Shortest paths in Roads
;WITH Roads2 AS
(
  SELECT city1 AS from_city, city2 AS to_city, distance FROM dbo.Roads
  UNION ALL
  SELECT city2, city1, distance FROM dbo.Roads
),
RoadPaths AS
(
  SELECT from_city, to_city, distance,
    CAST('.' + from_city + '.' + to_city + '.' AS VARCHAR(MAX)) AS path
  FROM Roads2

  UNION ALL

  SELECT F.from_city, T.to_city, F.distance + T.distance,
    CAST(F.path + T.to_city + '.' AS VARCHAR(MAX))
  FROM RoadPaths AS F
    INNER JOIN Roads2 AS T
      ON CASE WHEN F.path LIKE '%.' + T.to_city + '.%'
              THEN 1 ELSE 0 END = 0
         AND F.to_city = T.from_city
),
RoadsRnk AS -- Rank paths
(
  SELECT *, RANK() OVER(PARTITION BY from_city, to_city ORDER BY distance) AS rnk
  FROM RoadPaths
)
-- Return shortest paths and distances
SELECT from_city, to_city, distance, path
FROM RoadsRnk
WHERE rnk = 1;
GO

-- Load Shortest Road Paths Into a Table
;WITH Roads2 AS
(
  SELECT city1 AS from_city, city2 AS to_city, distance FROM dbo.Roads
  UNION ALL
  SELECT city2, city1, distance FROM dbo.Roads
),
RoadPaths AS
(
  SELECT from_city, to_city, distance,
    CAST('.' + from_city + '.' + to_city + '.' AS VARCHAR(MAX)) AS path
  FROM Roads2

  UNION ALL

  SELECT F.from_city, T.to_city, F.distance + T.distance,
    CAST(F.path + T.to_city + '.' AS VARCHAR(MAX))
  FROM RoadPaths AS F
    INNER JOIN Roads2 AS T
      ON CASE WHEN F.path LIKE '%.' + T.to_city + '.%'
              THEN 1 ELSE 0 END = 0
         AND F.to_city = T.from_city
),
RoadsRnk AS -- Rank paths
(
  SELECT *, RANK() OVER(PARTITION BY from_city, to_city ORDER BY distance) AS rnk
  FROM RoadPaths
)
-- Return shortest paths and distances
SELECT from_city, to_city, distance, path
INTO dbo.RoadPaths
FROM RoadsRnk
WHERE rnk = 1;

CREATE UNIQUE CLUSTERED INDEX idx_uc_from_city_to_city
  ON dbo.RoadPaths(from_city, to_city);
GO

-- Return shortest path between Los Angeles and New York
SELECT from_city, to_city, distance, path FROM dbo.RoadPaths 
WHERE from_city = 'LAX' AND to_city = 'JFK';
GO

-- Creation Script for the RoadsTC UDF
IF OBJECT_ID(N'dbo.RoadsTC', N'TF') IS NOT NULL DROP FUNCTION dbo.RoadsTC;
GO
CREATE FUNCTION dbo.RoadsTC() RETURNS @RoadsTC TABLE
(
  uniquifier INT          NOT NULL IDENTITY,
  from_city  VARCHAR(3)   NOT NULL,
  to_city    VARCHAR(3)   NOT NULL,
  distance   INT          NOT NULL,
  route      VARCHAR(MAX) NOT NULL,
  PRIMARY KEY (from_city, to_city, uniquifier)
)
AS
BEGIN
  DECLARE @added AS INT;

  INSERT INTO @RoadsTC
    SELECT city1 AS from_city, city2 AS to_city, distance, '.' + city1 + '.' + city2 + '.'
    FROM dbo.Roads;

  SET @added = @@rowcount;

  INSERT INTO @RoadsTC
    SELECT city2, city1, distance, '.' + city2 + '.' + city1 + '.'
    FROM dbo.Roads;

  SET @added = @added + @@rowcount;

  WHILE @added > 0 BEGIN
    INSERT INTO @RoadsTC
      SELECT DISTINCT TC.from_city, R.city2, TC.distance + R.distance, TC.route + city2 + '.'
      FROM @RoadsTC AS TC
        INNER JOIN dbo.Roads AS R
          ON R.city1 = TC.to_city
      WHERE NOT EXISTS
        (SELECT * FROM @RoadsTC AS TC2
         WHERE TC2.from_city = TC.from_city
           AND TC2.to_city = R.city2
           AND TC2.distance <= TC.distance + R.distance)
        AND TC.from_city <> R.city2;

    SET @added = @@rowcount;

    INSERT INTO @RoadsTC
      SELECT DISTINCT TC.from_city, R.city1, TC.distance + R.distance, TC.route + city1 + '.'
      FROM @RoadsTC AS TC
        INNER JOIN dbo.Roads AS R
          ON R.city2 = TC.to_city
      WHERE NOT EXISTS
        (SELECT * FROM @RoadsTC AS TC2
         WHERE TC2.from_city = TC.from_city
           AND TC2.to_city = R.city1
           AND TC2.distance <= TC.distance + R.distance)
        AND TC.from_city <> R.city1;

    SET @added = @added + @@rowcount;
  END
  RETURN;
END
GO

-- Return shortest paths and distances
SELECT from_city, to_city, distance, route
FROM (SELECT from_city, to_city, distance, route,
        RANK() OVER (PARTITION BY from_city, to_city ORDER BY distance) AS rnk
      FROM dbo.RoadsTC() AS F) AS RTC
WHERE rnk = 1;
GO

-- Cleanup
DROP TABLE dbo.RoadPaths;
GO