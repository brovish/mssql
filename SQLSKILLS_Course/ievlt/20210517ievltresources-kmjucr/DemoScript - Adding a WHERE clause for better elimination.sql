join salesheaders as sh
	saleslineitems as sl
	
where sh.date >= '20180201' AND sh.date < '20180301'
	AND sl.date >= '20180201' AND sl.date < '20180301'