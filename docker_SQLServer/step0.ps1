# download databases from web
# curl -OutFile "wwi.bak" "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"
# mkdir "./database_backups" 

#adventure works dbs:https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks
#world wide importers: https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
#contose retail: Contoso_Retail.abf and ContosoRetailDW.bak
$dirToCheck = "./database_backups"
if (Test-Path $dirToCheck )
{
    # nothing to do here
}
else
{
    New-Item -ItemType Directory  -Path "./database_backups" 
}

$fileToCheck = "./database_backups/AdventureWorks2017.bak"
if (Test-Path $fileToCheck -PathType leaf)
{
    # nothing to do here
}
else
{
    curl -OutFile "./database_backups/AdventureWorks2017.bak" "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak"
}