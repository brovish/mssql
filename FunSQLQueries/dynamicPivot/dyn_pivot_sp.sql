use master;
go
if object_id('dbo.sp_dynPivot', N'P') is not null drop proc dbo.sp_dynPivot;
go

--Tatt: 1. Either instantiate the argument variable(@cols) (linked to output parameter) before executing the dynamic SQL (approach 2.2) Or instantiate the output parameter (@col_values) inside the dynamic 
--query (approach 3.2). Instantiating the output parameter where it is declared (outside the dynamic query) does not work (approach 3.3).
--2. Unparameterized query in this case won't work as we want to embed a variable in the dynamic query so that we can concatenate the values in it. Unparameterized query embeds the value of 
--variables in the dynamic query (approach 4.1 and 4.2), not the variable itself.
--3. Printing the sql string before executing it aids in debugging the statement as is. But if the query is parameterized and we want to check the values of variables embedded in the 
--dynamic query, we can embed print statement inside it. Refer approach 3.3
--4. This is vulnerable to SQL injection as the query to be run itself is being formed using the parameter values. If the parameters are used plug-in components into a query, it is then that they help avoid 
--sql injection. So instead of having devs be able to run this to do the pivot, only generate the pivot statement and not execute it in the sp. Maybe, add a OUTPUT parameter to this SP which will hold the generated
--pivot statement. What I did in 'dynamic_pivot_generation.sql' was to create a View with that pivot SQL. For me it is fine, do not give access to others.

create or alter proc dbo.sp_dynPivot
	@base_table as nvarchar(max),--table or view to be queried
	@on_rows as nvarchar(max),--the 'For' column or the GROUP BY key column. The @agg_func works for each unique value for this key for spreading.
	@on_col as nvarchar(max),--the 'Categorical' column. The column whose distict values become the new columns
	@agg_func as nvarchar(max) = N'MAX',
	@agg_col as nvarchar(max)--The 'Data' Column. The col on which we apply the @agg_func to compute the values for newly generated columns.
as
	begin try
		--validate the input
		if @base_table is null or @on_rows is null or @on_col is null or @agg_func is null or @agg_col is null
			throw 50001, 'Invalid input paramaeters.', 1;

		--input validation for sql-injection, etc. goes here. The problem it is difficult to validate against sql-injection

		declare @sql as nvarchar(max), 
				@cols as nvarchar(max),-- = N'', 
				@newline as nvarchar(2) = nchar(13) + nchar(10);

		--Construct a derived table query from the base table so that it goes in the FROM section of pivot template. Also provide an ALIAS for it.
		--I do not think we need to construct a derived table base table query.
		if coalesce(object_id(@base_table, N'u'), object_id(@base_table, N'v')) is not null
			--set @base_table = N'select * from ' + @base_table;--should have used concat
			print 'Found the base table or view';
		else
			throw 50001, 'Invalid input @base_table paramaeter. It should refer to a table or a view.', 1;			
		--set @base_table = N'(' + @base_table + ') as baseTableQuery';

		--if the user passes '*' in @agg_col parameter, use column number '1' for aggregation
		if @agg_col = N'*'
			set @agg_col = N'1';

		--now construct the comma separate list of quoted column values from the @on_col column. Here i try out 3 different approaches in order to 
		--avoid using STUFF to generate the comma separated column list:

		----Approach 1: Use STUFF. Avoid it as it is not very readable. MAybe it is more perfromance. TODO: Benchmark the performance
		--  SET @sql =
		--		N'SET @col_values = '                                + @newline +
		--		N'  STUFF('                                          + @newline +
		--		N'    (SELECT N'',['' + '
		--				 + 'CAST(pivot_col AS sysname) + '
		--				 + 'N'']'' AS [text()]'                      + @newline +
		--		N'     FROM (SELECT DISTINCT('
		--				 + @on_col + N') AS pivot_col'              + @newline +
		--		N'           FROM' + @base_table + N') AS DistinctCols'   + @newline +
		--		N'     ORDER BY pivot_col'+ @newline +
		--		N'     FOR XML PATH('''')),'+ @newline +
		--		N'    1, 1, N'''');'
		
		--print @sql;
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) output', @col_values = @cols output
		--select @cols, 'Works 1';

		--Uncomment each of these approaches on-by-one to see their output. Don't uncomment all at the same time
		----Approach 2: 
		----2.1 Commentary: The Parameter (@col_values) and the Argument (@cols) being passed to it are both not instantiated. So the starting value of @col_value is NULL
		---- and concatenating with NULL results in NULL
		--set @sql = N'select @col_values += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @base_table + ') as distinctPivotColValues;'; 

		--print @sql;--generated sql statement is correct. But the @col_values output parameter is returned null as it was not instantiated (therefore NULL)
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) output', @col_values = @cols output
		--select @cols, 'Does not work 2.1';

		--2.2 Commentary: Lets instantiate the argument being passed (to the OUTPUT parameter) to a empty string. It works because not only would the value of @col_values gets linked to @cols (as is expected)
		--but other way around as well. So instantiating @cols to a value also set that value to @col_values when the dynamic query starts executing
		set @cols = N'';
		set @sql = N'select @col_values += concat('','',  quotename(pivotColVal) )
						from (select distinct ' + @on_col + ' as pivotColVal
								from ' + @base_table + ') as distinctPivotColValues;'; 

		print @sql;
		exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) output', @col_values = @cols output
		select @cols, 'works 2.2';

		----Approach 3:
		----3.1 Commentary: You cannot declare @col_values inside the dynamic query as a variable as it is already declared outside as a OUTPUT parameter
		--set @sql = N'declare @col_values as nvarchar(max) = N''''; select @col_values += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @base_table + ') as distinctPivotColValues;'; 

		--print @sql;
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) output', @col_values = @cols output
		--select @cols, 'Does not work 3.1';

		----3.2 Commentary: This would work as we instantiate the parameter @col_values inside the dynamic query.
		--set @sql = N'set @col_values = N''''; select @col_values += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @base_table + ') as distinctPivotColValues;'; 

		--print @sql;
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) output', @col_values = @cols output
		--select @cols, 'Works 3.2';

		----3.3 Commentary: This does not work even though we instantiate the parameter @col_values when we declare it outside the dynamic query.
		--set @sql = N'select @col_values += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @base_table + ') as distinctPivotColValues;'; 

		--print @sql;--generated sql statement is correct. But the @col_values output parameter is returned null as it was instantiated outside the dynamic query string which for some reason does not work.
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) = N'' ''  output', @col_values = @cols output
		--select @cols, 'Does not work 3.3';

		----If you want to debug the @col_values inside the dynamic query, print it to show that it is NULL
		--set @sql = N'print concat(''The values are:'', @col_values) ;select @col_values += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @base_table + ') as distinctPivotColValues;'; 
								
		--print @sql;--this generated sql statement is correct. But the @col_values output parameter is returned null as it was instantiated outside the dynamic query string which for some reason does not work.
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) = N'' '' output', @col_values = @cols output
		--select @cols, 'Does not work 3.3. Debug the @col_values by printing it when the query is executed. Check the Messages tab for printed output';

		----Approach 4: We can also remove parameterization from the query and directly use @cols in the dynamic query. But it wont work for both uninstantiated and instantiated case.
		----4.1 Commentary: This won't work as @cols is uninstantiated. So concatenating with NULL will result in NULL
		--set @sql = N'select '+ @cols +' += concat('','',  quotename(pivotColVal) )
		--		from (select distinct ' + @on_col + ' as pivotColVal
		--				from ' + @base_table + ') as distinctPivotColValues;'; 
								
		--print @sql;--generated sql statement is wrong as value of @cols is embedded in the query, not the variable itself.
		--exec sp_executesql @stmt= @sql
		--select @cols, 'Does not work 4.1';

		----4.2 Commentary: We can instantiate @cols to empty string but the problem here when @cols is already evaluated to its value before we execute the dynamic query. The print @sql statement shows
		----that the empty string for @cols is embedded in the dynamic query as an value. But we want the @cols variable to be embedded, not its value. Contrast it with @on_col and @base_table variables whose value
		----we want to embed in the query, not the variable themselves (we cold have embed them as variables as well and it would also work). 
		--set @cols = N'';
		--set @sql = N'select '+ @cols +' += concat('','',  quotename(pivotColVal) )
		--		from (select distinct ' + @on_col + ' as pivotColVal
		--				from ' + @base_table + ') as distinctPivotColValues;'; 
								
		--print @sql;--generated sql statement is wrong as value of @cols is embedded in the query, not the variable itself.
		--exec sp_executesql @stmt= @sql
		--select @cols, 'Does not work 4.2';

		--create the pivot query. Instead of STUFF, i could use: IIF(len(@cols)>0, SUBSTRING(@cols,2,len(@cols)), null)
		set @sql = N' select *
						from (select '+ @on_rows+', ' + @agg_col + ', ' + @on_col + ' as categoricalCol from ' + @base_table + ') as B
						pivot (' + @agg_func + '(' + @agg_col+ ') for categoricalCol' + + ' in (' + STUFF(@cols, 1, 1, '') + ')  ) as p';
		print @sql;--the reason i provided an alias for @on_col above was because the @on_col/categorical column could be an computed column. So give it an alias so that we can refer to it in pivot clause below
		exec sp_executesql @stmt=@sql;

		--select 1;
	end try	
	begin catch
	  ;THROW;
	end catch
go

exec dbo.sp_dynPivot 
	@base_table = N'TSQLV3.Sales.OrderValues',
	@on_rows = N'custid',--'For' Column or the 'GROUP BY'key/columns 
	@on_col = N'year(orderdate)',--'Categorical' column. Distinct values of this col become new columns
	@agg_func = N'max',--the aggregate func
	@agg_col = N'val'--'Data' column which is then aggregated

