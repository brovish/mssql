-- This is a good example of the plans that you'll get with a PV...

-- In this particular case, the plan won't really need to change if
-- different amounts of data are requested (it's a very stable plan)
-- so you don't really need to do recompile here. But, if the procedure
-- has a join or any additional (more complicated) things happening
-- against this view then you should consider adding OPTION (RECOMPILE)

-- This also shows (in the showplan) how the estimates are off even
-- though they do correctly eliminate the unnecessary tables.

USE CreditPV;
GO

IF object_id('GetSales') IS NOT NULL
    DROP PROCEDURE GetSales;
GO

CREATE PROCEDURE GetSales
(
    @mindate    datetime
    , @maxdate    datetime
)
AS
SELECT [cpv].* 
FROM [dbo].[ChargePV] AS [cpv]
WHERE [cpv].[charge_dt] >= @mindate
	AND [cpv].[charge_dt] < @maxdate;
GO

SET STATISTICS IO ON;
GO

-- Turn on "Include Actual Execution Plan" and you'll see that
-- SQL gives an estimate of 33/33/33 AND, if you look at all of
-- the estimates then you'll see that they all match exactly...
EXEC GetSales '20140714', '20140715'
EXEC GetSales '20140914', '20140915'
EXEC GetSales '20140715', '20140816'
GO
-- However, if you go to the statistics IO output, you'll see 
-- that no actual I/O occurred on any tables EXCEPT the ones
-- that you're querying. The showplan is a bit misleading but
-- they have to create a plan that will be usable across 
-- executions so they need to display all of the tables even
-- though they eliminate them.

-- To confirm that the cached plan was reused - check out the 
-- usecounts for this proc (one plan with 3 executions)
SELECT [cp].[objtype]
	, [cp].[cacheobjtype]
	, [cp].[size_in_bytes]
	, [cp].[usecounts]
	, [st].[text]
FROM sys.dm_exec_cached_plans AS [cp]
CROSS APPLY sys.dm_exec_sql_text ([cp].[plan_handle]) AS [st]
WHERE [cp].[objtype] IN (N'proc')
	AND [st].[text] LIKE '%ChargePV%'
	AND ([st].[text] NOT LIKE '%syscacheobjects%' 
		OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY [cp].[objtype], [cp].[size_in_bytes];
GO