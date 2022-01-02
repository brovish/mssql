USE [Credit];
GO

SELECT	m.firstname,
		m.lastname,
		c.charge_no,
		dbo.add_day_udf(c.charge_dt) AS [forward_charge_dt],
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