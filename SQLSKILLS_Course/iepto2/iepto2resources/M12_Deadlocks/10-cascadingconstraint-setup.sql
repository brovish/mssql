USE [DeadlockDemo];
GO
CREATE  TABLE dbo.Parent
        (
        parent_id   INTEGER NOT NULL 
                    PRIMARY KEY,
        );
GO
CREATE  TABLE dbo.Child1
        (
        parent_id   INTEGER NOT NULL 
                    PRIMARY KEY
                    REFERENCES dbo.Parent
                    ON UPDATE CASCADE 
        );
GO
CREATE  TABLE dbo.Child2
        (
        parent_id   INTEGER NOT NULL 
                    PRIMARY KEY
                    REFERENCES dbo.Child1
                    ON UPDATE CASCADE 
        );
GO
INSERT  dbo.Parent VALUES (1);
INSERT  dbo.Parent VALUES (-1);

INSERT  dbo.Child1 (parent_id) VALUES (1);
INSERT  dbo.Child2 (parent_id) VALUES (1);
GO
