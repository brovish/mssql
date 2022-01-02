USE [Credit];
GO

-- Fixed?  If so, why no thread distribution?
SELECT	m.firstname,
		m.lastname,
		c.charge_no,
		DAY(c.charge_dt)+1 AS [forward_charge_dt],
		SUM(c.charge_amt) max_amount
FROM dbo.member m
INNER JOIN dbo.charge c ON
	m.member_no = c.member_no 
WHERE	c.charge_amt > 1000.00 AND
		m.region_no = 2
GROUP BY 
	m.firstname,
	m.lastname,
	c.charge_no,
	c.charge_dt
HAVING MAX(c.charge_amt) > 2000.00;







-- Scroll down only when ready















ALTER WORKLOAD GROUP [default]
WITH
(
     MAX_DOP = 0
) USING [default]
GO


ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- Now do we have thread distribution?
SELECT	m.firstname,
		m.lastname,
		c.charge_no,
		DAY(c.charge_dt)+1 AS [forward_charge_dt],
		SUM(c.charge_amt) max_amount
FROM dbo.member m
INNER JOIN dbo.charge c ON
	m.member_no = c.member_no 
WHERE	c.charge_amt > 1000.00 AND
		m.region_no = 2
GROUP BY 
	m.firstname,
	m.lastname,
	c.charge_no,
	c.charge_dt
HAVING MAX(c.charge_amt) > 2000.00;
