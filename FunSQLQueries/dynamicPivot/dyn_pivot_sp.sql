use master;
go
if object_id('dbo.sp_dynPivot', N'P') is not null drop proc dbo.sp_dynPivot;
go

create or alter proc dbo.sp_dynPivot
	@query as nvarchar(max),--table or view to be queried
	@on_rows as nvarchar(max),	
	@on_col as nvarchar(max),
	@agg_func as nvarchar(max) = N'MAX',
	@agg_col as nvarchar(max)
as
	begin try
		--validate the input
		if @query is null or @on_rows is null or @on_col is null or @agg_func is null or @agg_col is null
			throw 50001, 'Invalid input paramaeters.', 1;

		--input validation for sql-injection, etc. goes here. The problem it is difficult to validate against sql-injection

		declare @sql as nvarchar(max), 
				@cols as nvarchar(max) = N'', 
				@newline as nvarchar(2) = nchar(13) + nchar(10);

		if coalesce(object_id(@query, N'u'), object_id(@query, N'v')) is not null
			set @query = N'select * from ' + @query;--should have used concat

		--now since this is the base table query, it has to be made a derived table query so that it goes in the FROM section of pivot template. Also provide an ALIAS for it
		set @query = N'(' + @query + ') as baseTableQuery';

		--if the user passes '*' in @agg_col parameter, use column number '1' for aggregation
		if @agg_col = N'*'
			set @agg_col = N'1';

		--now construct the comma separate list of quoted column values from the @on_col column
		--set @sql = N'declare @col_values as nvarchar(max) = N''''; select @col_values += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @query + ') as distinctPivotColValues;'; 
		set @sql = N'print concat(''The values are:'', @col_values) ;select @col_values += concat('','',  quotename(pivotColVal) )
						from (select distinct ' + @on_col + ' as pivotColVal
								from ' + @query + ') as distinctPivotColValues;'; 
								
		print @sql;--this generated sql statement is correct. But the @col_values output parameter is returned null??
		exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) = N'' '' output', @col_values = @cols output
		select @cols, 'works 1';

		--declare @col_values_outerscope As NVARCHAR(MAX)= N'';
		--set @sql = N'print concat(''The values are:'''+ @cols + ') ;select '+ @cols +' += concat('','',  quotename(pivotColVal) )
		--				from (select distinct ' + @on_col + ' as pivotColVal
		--						from ' + @query + ') as distinctPivotColValues;'; 

		set @sql = N'select '+ @cols +' += concat('','',  quotename(pivotColVal) )
				from (select distinct ' + @on_col + ' as pivotColVal
						from ' + @query + ') as distinctPivotColValues;'; 
								
		print @sql;--this generated sql statement is correct. But the @col_values output parameter is returned null??
		--exec sp_executesql @stmt= @sql
		select @cols, 'works 2';


		--  SET @sql =
		--		N'SET @col_values = '                                + @newline +
		--		N'  STUFF('                                          + @newline +
		--		N'    (SELECT N'',['' + '
		--				 + 'CAST(pivot_col AS sysname) + '
		--				 + 'N'']'' AS [text()]'                      + @newline +
		--		N'     FROM (SELECT DISTINCT('
		--				 + @on_col + N') AS pivot_col'              + @newline +
		--		N'           FROM' + @query + N') AS DistinctCols'   + @newline +
		--		N'     ORDER BY pivot_col'+ @newline +
		--		N'     FOR XML PATH('''')),'+ @newline +
		--		N'    1, 1, N'''');'
		
		--print @sql;--this generated sql statement is correct. But the @col_values output parameter is returned null??
		--exec sp_executesql @stmt= @sql, @params = N'@col_values as nvarchar(max) output', @col_values = @cols output
		--select @cols;

		--select 1;
	end try	
	begin catch
	  ;THROW;
	end catch
go

exec dbo.sp_dynPivot 
	@query = N'TSQLV3.Sales.Orders',
	@on_rows = N'custid',
	@on_col = N'year(orderdate)',
	@agg_func = N'max',
	@agg_col = N'val'

--select @col_values += concat(',',  quotename(pivotColVal) )
--						from (select distinct year(orderdate) as pivotColVal
--								from (select * from TSQLV3.Sales.Orders) as baseTableQuery) as distinctPivotColValues;

--select concat(',',  quotename(pivotColVal) )
--						from (select distinct year(orderdate) as pivotColVal
--								from (select * from TSQLV3.Sales.Orders) as baseTableQuery) as distinctPivotColValues

--								declare @col_values as nvarchar(max) = N''; select @col_values += concat(',',  quotename(pivotColVal) )
--						from (select distinct year(orderdate) as pivotColVal
--								from (select * from TSQLV3.Sales.Orders) as baseTableQuery) as distinctPivotColValues;
--								select @col_values