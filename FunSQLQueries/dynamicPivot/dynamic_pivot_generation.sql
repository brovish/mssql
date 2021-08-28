--if you pivot and then unpivot using these files, the number of rows should remain the same as when you started. But if there are null values in 
--column that is being aggregated (column whose values are spread under the new columns), then those rows would be lost on unpivot.
--for example, lab_results have 983,063 rows and after pivot and then unpivot, we are left with 983,043 rows as there are 20 rows in orginial dataset
--which, alhough they have a value for labm_code, have a null value for labr_value.


DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
SET @columns = N'';
SELECT @columns += N',' + QUOTENAME(CODE_VALUE)
  FROM (select CODE_VALUE
from CODES
where CODE_DOMAIN = N'c_h_texture') AS x;
--SELECT @columns 

SET @columns = N'';
SELECT @columns += N',' + QUOTENAME(labm_code) 
		--@columns += concat(',', '[',labm_code, ']')--do not manually quote and use quotename instead
  FROM (select distinct labm_code
from LAB_RESULTS) AS x;
--SELECT @columns 

--we are using stuff to replace remove the first occurence of the , in the cols string. The same can be done with substring:
--select IIF(len(@columns)>0, SUBSTRING(@columns,2,len(@columns)), null)
--	   ,STUFF(@columns, 1, 1, '')

SET @sql = N'
SELECT [agency_code], [proj_code], [s_id], [o_id], [h_no], [samp_no], [labr_no], ' + STUFF(@columns, 1, 1, '') + '
FROM
(
  select hr.[agency_code]
	  ,hr.[proj_code]
	  --,hr.[h_texture]
	  ,hr.[s_id]
	  ,hr.[o_id]
	  ,hr.[h_no]
    --,hr.[h_soil_water_stat]
	 ,lr.[samp_no]
   ,lr.labr_no
   ,lr.labm_code
   ,lr.labr_value
	 --,lm.LABM_NAME, lm.LABM_SHORT_NAME, LABM_UNITS,LABMT_CODE
from HORIZONS as hr inner join [NatSoil].[dbo].[LAB_RESULTS] as lr
	on hr.agency_code = lr.agency_code and hr.proj_code = lr.proj_code and hr.s_id = lr.s_id
	and hr.o_id = lr.o_id and hr.h_no = lr.h_no
inner join LAB_METHODS as lm on lm.LABM_CODE = lr.labm_code
) AS j
PIVOT
(
  MAX(labr_value) FOR labm_code IN ('
  + STUFF(@columns, 1, 1, '')
  + ')
) AS p;';
PRINT @sql;

begin tran
declare @sql1 nvarchar(max) = 
    N'use [NAtSoil]; 
      exec (''create or alter view Test as ' + @sql + ''')';

exec (@sql1);
commit tran