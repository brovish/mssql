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
	t9.CurrentValue,
	t20.RowID,
	t21.ParentID,
	t22.CurrentValue,
	t23.RowID,
	t24.ParentID,
	t25.CurrentValue,
	t26.RowID,
	t27.ParentID,
	t28.CurrentValue,
	(SELECT t12.ParentID FROM Test2 AS t12, Test3 AS t13 WHERE t12.ParentID = t13.RowID AND t12.RowID = t1.ParentID AND t13.RowID = t1.ParentID) AS ColNew,
	(SELECT t12.ParentID FROM Test3 AS t12, Test4 AS t13 WHERE t12.ParentID = t13.RowID AND t12.RowID = t1.ParentID AND t13.RowID = t1.ParentID) AS ColNew2,
	(SELECT t12.ParentID FROM Test4 AS t12, Test5 AS t13 WHERE t12.ParentID = t13.RowID AND t12.RowID = t1.ParentID AND t13.RowID = t1.ParentID) AS ColNew3,
	(SELECT t12.ParentID FROM Test5 AS t12, Test6 AS t13 WHERE t12.ParentID = t13.RowID AND t12.RowID = t1.ParentID AND t13.RowID = t1.ParentID) AS ColNew4,
	(SELECT t12.ParentID FROM Test6 AS t12, Test7 AS t13 WHERE t12.ParentID = t13.RowID AND t12.RowID = t1.ParentID AND t13.RowID = t1.ParentID) AS ColNew5,
	(SELECT t12.ParentID FROM Test7 AS t12, Test8 AS t13 WHERE t12.ParentID = t13.RowID AND t12.RowID = t1.ParentID AND t13.RowID = t1.ParentID) AS ColNew6
FROM Test AS t1
JOIN Test2 AS t2 ON t1.ParentID = t2.RowID OR t2.ParentID = t1.RowID
JOIN Test3 AS t3 ON t2.ParentID = t3.RowID
JOIN Test4 AS t4 ON t4.ParentID = t3.RowID OR t4.ParentID = t3.RowID 
JOIN Test5 AS t5 ON t4.ParentID = t5.RowID OR t5.ParentID = t4.RowID
JOIN Test6 AS t6 ON t5.ParentID = t6.RowID 
JOIN Test7 AS t7 ON t6.ParentID = t7.RowID 
JOIN Test8 AS t8 ON t7.ParentID = t8.RowID
JOIN Test9 AS t9 ON t8.ParentID = t9.RowID
CROSS APPLY (SELECT * FROM Test1 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t20
CROSS APPLY (SELECT * FROM Test2 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t21
CROSS APPLY (SELECT * FROM Test3 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t22
CROSS APPLY (SELECT * FROM Test4 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t23
CROSS APPLY (SELECT * FROM Test5 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t24
CROSS APPLY (SELECT * FROM Test6 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t25
CROSS APPLY (SELECT * FROM Test7 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t26
CROSS APPLY (SELECT * FROM Test8 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t27
CROSS APPLY (SELECT * FROM Test9 AS t10 WHERE t10.CurrentValue LIKE t1.CurrentValue) AS t28
ORDER BY 4, 5, 6, 2, 3, 10, 14, 12, 11, 7
OPTION(RECOMPILE)
END