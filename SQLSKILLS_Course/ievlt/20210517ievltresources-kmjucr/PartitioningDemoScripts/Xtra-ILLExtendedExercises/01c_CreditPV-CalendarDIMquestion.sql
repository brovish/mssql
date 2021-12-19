-- Add a Calendar "Dimension" table and join to it...

USE Credit;
go

CREATE TABLE [DIMCalendar]
(
	CID			int				identity,
	CName		varchar(20),
	StartDate	datetime,
	EndDate		datetime
)
go

INSERT [DIMCalendar] VALUES ('June', '20170601', '20170701');
INSERT [DIMCalendar] VALUES ('July', '20170601', '20170701');
INSERT [DIMCalendar] VALUES ('August', '20170601', '20170701');
INSERT [DIMCalendar] VALUES ('September', '20170601', '20170701');
go

-- Will this query use partition elimination?
SET STATISTICS IO ON;
go

SELECT * 
FROM ChargePV as c
	 , DIMCalendar as DC
WHERE c.Charge_dt >= DC.StartDate AND c.Charge_dt < DC.EndDate
	AND  DC.CName = 'June';
GO

-- If for some reason, SQL Server does perform IOs then
-- check to see if the constraints are trusted
-- Also, consider a subquery instead so that the min/max
-- are passed back to the outer query from the subquery