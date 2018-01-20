USE AdventureWorks2012;

DECLARE @ORDERCOUNT AS INT = (SELECT COUNT(*) from Sales.SalesOrderHeader);

--CROSS APPLY TOOK 4 SECONDS. RUNNING THE QUERYWITH CROSS APPLY TOOK JUST 2 SECONDS. CROSS JOIN TOOK THE SAME AMOUNT OF TIME. TRY WITH CTE APPROACH
SELECT *, OC.ORDERCOUNT
FROM Sales.SalesOrderHeader AS SH INNER JOIN Sales.SalesOrderDetail AS SD ON SD.SalesOrderID = SH.SalesOrderID 
INNER JOIN Production.Product AS PR ON PR.ProductID = SD.ProductID 
INNER JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = PR.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC ON  PC.ProductCategoryID = PSC.ProductCategoryID
CROSS APPLY (SELECT @ORDERCOUNT) AS OC(ORDERCOUNT)





select *
from (values(1)) as a(d) cross apply (select * from (values(12)) as aa(s)) as b

select *
from (values(1),(2)) as a(d) cross apply (select * from (values(12),(13)) as aa(s)) as b

select *
from (values(1)) as a(d) cross apply (select 1 as s where 1=0) as b
