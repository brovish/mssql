USE CompileMemory;

WHILE 1=1
BEGIN

SELECT TOP 1
	t1.RowID,
	t2.ParentID,
	t3.CurrentValue
FROM Test AS t1
JOIN Test2 AS t2 ON t1.ParentID = t2.RowID-- OR t2.ParentID = t1.RowID
JOIN Test3 AS t3 ON t2.ParentID = t3.RowID
ORDER BY 2, 3
OPTION(RECOMPILE)
END