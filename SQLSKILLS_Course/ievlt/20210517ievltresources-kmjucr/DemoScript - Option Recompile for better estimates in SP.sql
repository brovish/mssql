SET STATISTICS IO ON;
go

declare @datevar datetime2 = '20170712' 
SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt] between @datevar and dateadd(dd, 1, @datevar)
GO

CREATE proc testgetdata
	(@datevar datetime2)
as
SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt] between @datevar and dateadd(dd, 1, @datevar)
go


exec testgetdata '20170801'


alter proc testgetdata
	(@datevar datetime2)
as
SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt] between @datevar and dateadd(dd, 1, @datevar)
OPTION (RECOMPILE)
go

convert