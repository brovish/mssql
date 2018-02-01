USE SQLCookbook;

;WITH CTE AS
(SELECT CONCAT(E.ENAME, ' ', E.DEPTNO) AS D
FROM EMP AS E
)
SELECT *
FROM CTE AS C
ORDER BY (SELECT F.value, ROW_NUMBER() OVER(ORDER BY C.D) AS RN FROM string_split(C.D, ' ') AS F ) 

SELECT JOB
FROM EMP AS E
group by JOB
ORDER BY max(sal)

SELECT E.ENAME
FROM EMP AS E
--ORDER BY 1-- THIS IS REFERRING THE COLUMN 1 IN THE SELECT LIST(E.ENAME), NOT THE COLUMN 1 FROM THE UNDERLYING TABLE AS THE OUTPUT OF SELECT IS INPUT OF ORDER BY
--ORDER BY E.JOB-- EVEN IF THE COLUMN IS NOT SELECT LIST WE CAN STILL REFER TO COLUMNS INT ROWSET THAT FORMS THE INPUT TO ORDER BY UNLESS DISTINCT IS USED IN SELECT
--ORDER BY (SELECT NULL)
--ORDER BY (SELECT 234 AS T)--can use any value here to get random records...
--ORDER BY (SELECT NEWID())--have a to use a value that changes each time it is called to get random values for each run AND THERE IS NO ORDER TO VALUES GENERATED
--ORDER BY (SELECT SYSDATETIME())--THERE IS AN IMPLICIT ORDER IN USING DATATIME VALUES. THE ORDER WILL REMAIN SAME FOR EACH RUN. SO THE ROWS FETCHED CANNOT BE GUURANTEED TO BE NOT THE SAME
ORDER BY NEWID()--THERE IS AN IMPLICIT ORDER IN USING DATATIME VALUES. THE ORDER WILL REMAIN SAME FOR EACH RUN. SO THE ROWS FETCHED CANNOT BE GUURANTEED TO BE NOT THE SAME
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

SELECT TOP(5) *
FROM EMP;

SELECT *
FROM EMP AS E
--ORDER BY (SELECT NULL)
ORDER BY (SELECT 234 AS T)--can use any value here to get random records...
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--SELECT 'TT' + NULL
SELECT CONCAT('TT', NULL)

