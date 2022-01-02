/*============================================================================
  File:     1b_Baselines_ConfigData_QueryData.sql

  Summary:  This script queries the stored configuration
			data.

  Date:     April 2021

  SQL Server Version: 2005/2008/2008R2/2012/2014/2016/2017/2019
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com

  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [BaselineData];
GO

/*
	Not so useful...
*/
SELECT *
FROM [dbo].[SQLskills_ConfigData]

SELECT *
FROM [dbo].[SQLskills_ConfigData]
WHERE [Name] = 'max degree of parallelism'
ORDER BY [CaptureDate]

SELECT *
FROM [dbo].[SQLskills_ConfigData]
WHERE [Name] = 'cost threshold for parallelism'
ORDER BY [CaptureDate]

/*
	This is convenient
*/
EXEC usp_ConfigChanges


/*
	A better way
*/
;WITH f AS 
(
  SELECT 
	ROW_NUMBER() OVER (PARTITION BY ConfigurationID ORDER BY CaptureDate ASC) AS RowNumber,
	[ConfigurationID] AS [ConfigurationID],
	[Name] AS [Name],
	[Value] AS [Value],
	[ValueInUse] AS [ValueInUse],
	[CaptureDate] AS [CaptureDate]
  FROM [BaselineData].[dbo].[SQLskills_ConfigData]
)
SELECT	[f].[Name] AS [Setting], [f].[CaptureDate] AS [Date], [f].[Value] AS [Previous Value], [f].[ValueInUse] AS [Previous Value In Use], 
	[n].[CaptureDate] AS [Date Changed], [n].[Value] AS [New Value], [n].[ValueInUse] AS [New Value In Use]
FROM [f]
LEFT OUTER JOIN [f] AS [n]
ON [f].[ConfigurationID] = [n].[ConfigurationID]
AND [f].[RowNumber] + 1 = [n].[RowNumber]
WHERE ([f].[Value] <> [n].[Value] OR [f].[ValueInUse] <> [n].[ValueInUse])
ORDER BY [f].[CaptureDate];


/*
	current values against last captured
*/
;WITH [lc] AS 
(
  SELECT 
	ROW_NUMBER() OVER (PARTITION BY [ConfigurationID] ORDER BY [CaptureDate] ASC) AS [RowNumber],
	[ConfigurationID] AS [ConfigurationID],
	[Name] AS [Name],
	[Value] AS [Value],
	[ValueInUse] AS [ValueInUse],
	[CaptureDate] AS [CaptureDate]
  FROM [BaselineData].[dbo].[SQLskills_ConfigData]
  WHERE [CaptureDate] = (SELECT MAX([CaptureDate])
		FROM [BaselineData].[dbo].[SQLskills_ConfigData])
)
SELECT	[lc].[Name] AS [Setting], [lc].[CaptureDate] AS [Date], [lc].[Value] AS [Last Captured Value], 
	[lc].[ValueInUse] AS [Last Captured Value In Use], CURRENT_TIMESTAMP AS [Current Time], 
	[c].[Value] AS [Current Value], [c].[value_in_use] AS [Curret In Use]
FROM [sys].[configurations] AS [c]
LEFT OUTER JOIN [lc]
	ON [lc].[ConfigurationID] = [c].[configuration_id]
WHERE ([lc].[Value] <> [c].[Value] OR [lc].[ValueInUse] <> [c].[value_in_use]);
GO


CREATE PROCEDURE usp_ConfigChanges
AS
BEGIN
	
	/*
		A better way
	*/
	;WITH f AS 
	(
	  SELECT 
		ROW_NUMBER() OVER (PARTITION BY ConfigurationID ORDER BY CaptureDate ASC) AS RowNumber,
		[ConfigurationID] AS [ConfigurationID],
		[Name] AS [Name],
		[Value] AS [Value],
		[ValueInUse] AS [ValueInUse],
		[CaptureDate] AS [CaptureDate]
	  FROM [BaselineData].[dbo].[SQLskills_ConfigData]
	)
	SELECT	[f].[Name] AS [Setting], [f].[CaptureDate] AS [Date], [f].[Value] AS [Previous Value], [f].[ValueInUse] AS [Previous Value In Use], 
		[n].[CaptureDate] AS [Date Changed], [n].[Value] AS [New Value], [n].[ValueInUse] AS [New Value In Use]
	FROM [f]
	LEFT OUTER JOIN [f] AS [n]
	ON [f].[ConfigurationID] = [n].[ConfigurationID]
	AND [f].[RowNumber] + 1 = [n].[RowNumber]
	WHERE ([f].[Value] <> [n].[Value] OR [f].[ValueInUse] <> [n].[ValueInUse])
	ORDER BY [f].[CaptureDate];


	/*
		current values against last captured
	*/
	;WITH [lc] AS 
	(
	  SELECT 
		ROW_NUMBER() OVER (PARTITION BY [ConfigurationID] ORDER BY [CaptureDate] ASC) AS [RowNumber],
		[ConfigurationID] AS [ConfigurationID],
		[Name] AS [Name],
		[Value] AS [Value],
		[ValueInUse] AS [ValueInUse],
		[CaptureDate] AS [CaptureDate]
	  FROM [BaselineData].[dbo].[SQLskills_ConfigData]
	  WHERE [CaptureDate] = (SELECT MAX([CaptureDate])
			FROM [BaselineData].[dbo].[SQLskills_ConfigData])
	)
	SELECT	[lc].[Name] AS [Setting], [lc].[CaptureDate] AS [Date], [lc].[Value] AS [Last Captured Value], 
		[lc].[ValueInUse] AS [Last Captured Value In Use], CURRENT_TIMESTAMP AS [Current Time], 
		[c].[Value] AS [Current Value], [c].[value_in_use] AS [Curret In Use]
	FROM [sys].[configurations] AS [c]
	LEFT OUTER JOIN [lc]
		ON [lc].[ConfigurationID] = [c].[configuration_id]
	WHERE ([lc].[Value] <> [c].[Value] OR [lc].[ValueInUse] <> [c].[value_in_use]);


END

