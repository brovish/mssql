USE CompileMemory;

WHILE 1=1
BEGIN

SELECT TOP 1
	t1.RowID,
	t2.ParentID,
	t3.CurrentValue,
	t4.RowID,
	t5.ParentID,
	t6.CurrentValue,
	t7.RowID,
	t8.ParentID,
	t9.CurrentValue
FROM Test AS t1
JOIN Test2 AS t2 ON t1.ParentID = t2.RowID-- OR t2.ParentID = t1.RowID
JOIN Test3 AS t3 ON t2.ParentID = t3.RowID
JOIN Test4 AS t4 ON t4.ParentID = t3.RowID-- OR t4.ParentID = t3.RowID 
JOIN Test5 AS t5 ON t4.ParentID = t5.RowID-- OR t5.ParentID = t4.RowID
JOIN Test6 AS t6 ON t5.ParentID = t6.RowID 
JOIN Test7 AS t7 ON t6.ParentID = t7.RowID 
JOIN Test8 AS t8 ON t7.ParentID = t8.RowID
JOIN Test9 AS t9 ON t8.ParentID = t9.RowID
ORDER BY 4, 5, 6, 2, 3, 7
OPTION(RECOMPILE)
END