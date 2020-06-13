create database sql_anti_patterns;
go

use sql_anti_patterns;
go

DROP TABLE IF EXISTS Accounts;
DROP TABLE IF EXISTS BugStatus;
DROP TABLE IF EXISTS Bugs;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Screenshots;
DROP TABLE IF EXISTS Tags;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS BugsProducts;

CREATE TABLE Accounts (
  account_id       bigint not null identity PRIMARY KEY,
  account_name      VARCHAR(20),
  first_name        VARCHAR(20),
  last_name         VARCHAR(20),
  email             VARCHAR(100),
  password_hash     CHAR(64),
  portrait_image    varbinary(MAX),
  hourly_rate       NUMERIC(9,2)
);

CREATE TABLE BugStatus (
  status            VARCHAR(20) PRIMARY KEY
);

CREATE TABLE Bugs (
  bug_id            bigint not null identity PRIMARY KEY,
  date_reported     DATE NOT NULL,
  summary           VARCHAR(80),
  description       VARCHAR(1000),
  resolution        VARCHAR(1000),
  reported_by       BIGINT NOT NULL,
  assigned_to       BIGINT,
  verified_by       BIGINT,
  status            VARCHAR(20) NOT NULL DEFAULT 'NEW',
  priority          VARCHAR(20),
  hours             NUMERIC(9,2),
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (assigned_to) REFERENCES Accounts(account_id),
  FOREIGN KEY (verified_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (status) REFERENCES BugStatus(status)
);


CREATE TABLE Comments (
  comment_id        bigint not null identity PRIMARY KEY,
  bug_id            BIGINT NOT NULL,
  author            BIGINT NOT NULL,
  comment_date      DATETIME NOT NULL,
  comment           TEXT NOT NULL,
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);

CREATE TABLE Screenshots (
  bug_id            BIGINT NOT NULL,
  image_id          BIGINT NOT NULL,
  screenshot_image  varbinary(MAX),
  caption           VARCHAR(100),
  PRIMARY KEY      (bug_id, image_id),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id)
);

CREATE TABLE Tags (
  bug_id            BIGINT NOT NULL,
  tag               VARCHAR(20) NOT NULL,
  PRIMARY KEY      (bug_id, tag),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id)
);

CREATE TABLE Products (
  product_id        bigint not null identity PRIMARY KEY,
  product_name      VARCHAR(50)
);

CREATE TABLE BugsProducts(
  bug_id            BIGINT NOT NULL,
  product_id        BIGINT NOT NULL,
  PRIMARY KEY      (bug_id, product_id),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

--INSERT INTO Accounts () VALUES ();
--INSERT INTO Accounts default VALUES ;

--SET IDENTITY_INSERT Products ON;
--INSERT INTO Products (product_id, product_name) VALUES
--  (1, 'Open RoundFile'),
--  (2, 'Visual TurboBuilder'),
--  (3, 'ReConsider');
--SET IDENTITY_INSERT Products Off;

--SET IDENTITY_INSERT Bugs on;
--INSERT INTO Bugs (bug_id, summary) VALUES
--  (1234, 'crash when I save'),
--  (2345, 'increase performance'),
--  (3456, 'screen goes blank'),
--  (5678, 'unknown conflict between products');
--SET IDENTITY_INSERT Bugs Off;

--INSERT INTO BugsProducts (bug_id, product_id) VALUES
--  (1234, 1),
--  (1234, 3),
--  (3456, 2),
--  (5678, 1),
--  (5678, 3);

--INSERT INTO Comments (comment_id, bug_id, comment) VALUES
--  (6789, 1234, 'It crashes!'),
--  (9876, 2345, 'Great idea!');

------INSERT INTO Tags () VALUES ();
--INSERT INTO Tags default VALUES;
