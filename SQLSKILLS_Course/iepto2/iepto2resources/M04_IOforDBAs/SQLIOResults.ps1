#=============================================================================
#   File: SQLIOResults.ps1 
#
#   Summary: This script parses the results information from the SQLIO too
#   and creates an Excel workbook with charts for the data.
#
#   Date: March 16, 2010 
#
#   PowerShell Versions:
#         1.0
#         2.0
#-----------------------------------------------------------------------------
#   Copyright (C) 2010 Jonathan M. Kehayias
#   All rights reserved. 
#
#   For more scripts and sample code, check out 
#      http://sqlblog.com/blogs/jonathan_kehayias
#
#   You may alter this code for your own *non-commercial* purposes. You may
#   republish altered code as long as you give due credit. 
#
#
#   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#   PARTICULAR PURPOSE. 
#
#=============================================================================


param(	[Parameter(Mandatory=$TRUE)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FileName)

$filedata = [string]::Join([Environment]::NewLine,(Get-Content $FileName))

$Results = $filedata.Split( [String[]]"sqlio v1.5.SG", [StringSplitOptions]::RemoveEmptyEntries ) | `
		 select @{Name="Threads"; Expression={[int]([regex]::Match($_, "(\d+)?\sthreads\s(reading|writing)").Groups[1].Value)}},`
				@{Name="Operation"; Expression={switch ([regex]::Match($_, "(\d+)?\sthreads\s(reading|writing)").Groups[2].Value)
												{
													"reading" {"Read"} 
													"writing" {"Write"}
												}	}},`
				@{Name="Duration"; Expression={[int]([regex]::Match($_, "for\s(\d+)?\ssecs").Groups[1].Value)}},`
				@{Name="IOSize"; Expression={[int]([regex]::Match($_, "\tusing\s(\d+)?KB\s(sequential|random)").Groups[1].Value)}},`
				@{Name="IOType"; Expression={switch ([regex]::Match($_, "\tusing\s(\d+)?KB\s(sequential|random)").Groups[2].Value)
												{
													"random" {"Random"} 
													"sequential" {"Sequential"}
												}  }},`
				@{Name="PendingIO"; Expression={[int]([regex]::Match($_, "with\s(\d+)?\soutstanding").Groups[1].Value)}},`
				@{Name="FileSize"; Expression={[int]([regex]::Match($_, "\s(\d+)?\sMB\sfor\sfile").Groups[1].Value)}},`
				@{Name="IOPS"; Expression={[decimal]([regex]::Match($_, "IOs\/sec\:\s+(\d+\.\d+)?").Groups[1].Value)}},`
				@{Name="MBs_Sec"; Expression={[decimal]([regex]::Match($_, "MBs\/sec\:\s+(\d+\.\d+)?").Groups[1].Value)}},`
				@{Name="MinLat_ms"; Expression={[int]([regex]::Match($_, "Min.{0,}?\:\s(\d+)?").Groups[1].Value)}},`
				@{Name="AvgLat_ms"; Expression={[int]([regex]::Match($_, "Avg.{0,}?\:\s(\d+)?").Groups[1].Value)}},`
				@{Name="MaxLat_ms"; Expression={[int]([regex]::Match($_, "Max.{0,}?\:\s(\d+)?").Groups[1].Value)}}`
	 | Sort-Object IOSize, IOType, Operation, Threads 

$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $true
$WorkBook = $Excel.WorkBooks.Add()
$WorkBook.WorkSheets.Item(1).Name = "RawData"
$WorkBook.WorkSheets.Item(3).Delete()
$WorkBook.WorkSheets.Item(2).Delete()
$WorkSheet = $WorkBook.WorkSheets.Item("RawData")
$x = 2
$WorkSheet.Cells.Item(1,1) = "Threads"
$WorkSheet.Cells.Item(1,2) = "Operation"
$WorkSheet.Cells.Item(1,3) = "Duration"
$WorkSheet.Cells.Item(1,4) = "IOSize"
$WorkSheet.Cells.Item(1,5) = "IOType"
$WorkSheet.Cells.Item(1,6) = "PendingIO"
$WorkSheet.Cells.Item(1,7) = "FileSize"
$WorkSheet.Cells.Item(1,8) = "IOPS"
$WorkSheet.Cells.Item(1,9) = "MBs/Sec"
$WorkSheet.Cells.Item(1,10) = "Min_Lat(ms)"
$WorkSheet.Cells.Item(1,11) = "Avg_Lat(ms)"
$WorkSheet.Cells.Item(1,12) = "Max_Lat(ms)"
$WorkSheet.Cells.Item(1,13) = "Caption"

$Results | % {
	$WorkSheet.Cells.Item($x,1) = $_.Threads
	$WorkSheet.Cells.Item($x,2) = $_.Operation
	$WorkSheet.Cells.Item($x,3) = $_.Duration
	$WorkSheet.Cells.Item($x,4) = $_.IOSize
	$WorkSheet.Cells.Item($x,5) = $_.IOType
	$WorkSheet.Cells.Item($x,6) = $_.PendingIO
	$WorkSheet.Cells.Item($x,7) = $_.FileSize
	$WorkSheet.Cells.Item($x,8) = $_.IOPS
	$WorkSheet.Cells.Item($x,9) = $_.MBs_Sec
	$WorkSheet.Cells.Item($x,10) = $_.MinLat_ms
	$WorkSheet.Cells.Item($x,11) = $_.AvgLat_ms
	$WorkSheet.Cells.Item($x,12) = $_.MaxLat_ms
	$WorkSheet.Cells.Item($x,13) = [string]$_.IOSize + "KB " + [string]$_.IOType + " " + `
								[string]$_.Operation + " " + [string]$_.Threads + `
								" Threads " + [string]$_.PendingIO + " pending"
	$x++}

$WorkBook.Charts.Add() | Out-Null
$Chart = $WorkBook.ActiveChart
$Chart.SetSourceData($WorkSheet.Range("H1:H$x"))
$Chart.SeriesCollection(1).xValues = $WorkSheet.Range("M2:M$x")
$Chart.SetSourceData($WorkSheet.Range("H1:H$x"))
$Chart.SeriesCollection(1).xValues = $WorkSheet.Range("M2:M$x")
$Chart.Name = "IOPS"

$WorkBook.Charts.Add() | Out-Null
$WorkBook.ActiveChart.SetSourceData($WorkSheet.Range("I1:I$x"))
$Chart = $WorkBook.ActiveChart
$Chart.SeriesCollection(1).xValues = $WorkSheet.Range("M2:M$x")
$Chart.Name = "MBs Sec"



