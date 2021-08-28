set nocount on;  
  
declare @column_name nvarchar(100), @sql NVARCHAR(MAX)='';
--instead of using a cursor, i could have used the technique used to generate a concatenated column string as done in "dynamic_pivot_generation.sql"
declare unpivot_columns_cursor cursor for   
	select column_name
	from information_schema.columns
	where table_name = 'test';    
	open unpivot_columns_cursor 
	
	fetch next from unpivot_columns_cursor 
	into  @column_name
	WHILE @@FETCH_STATUS = 0  
		BEGIN  
			--exclude the 'group by' key columns over which the initial pivot was done 
			if @column_name not in (select 'agency_code' union select 'proj_code' union select 's_id' union select 'o_id' union select 'h_no' union select 'samp_no' union select 'labr_no')
				set @sql = @sql + N' union select ' + QUOTENAME(@column_name,'''' ) + ', [' + @column_name +'] where [' + @column_name +'] is not null';
			-- Get the next column.  
			FETCH NEXT FROM unpivot_columns_cursor
			INTO @column_name  
		END   
CLOSE unpivot_columns_cursor;  
DEALLOCATE unpivot_columns_cursor;  

print @sql
SELECT @sql= STUFF(@sql, 1, 6, '') 
print @sql

declare @outerSQL NVARCHAR(MAX)='';
set @outerSQL = N'select T.[agency_code], T.[proj_code], T.[s_id], T.[o_id], T.[h_no], T.[samp_no], T.[labr_no], b.[labm_decode], b.[labm_codeValue]
from Test as T
outer apply('+ @sql+') as b(labm_decode, labm_codeValue)'
print @outerSQL
exec(@outerSQL)