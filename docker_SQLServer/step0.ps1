# download databases from web
# curl -OutFile "wwi.bak" "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"
# mkdir "./database_backups1" 

$dirToCheck = "./database_backups1"
if (Test-Path $dirToCheck )
{
    # nothing to do here
}
else
{
    New-Item -ItemType Directory  -Path "./database_backups1" 
}

$fileToCheck = "./database_backups1/AdventureWorks2017.bak"
if (Test-Path $fileToCheck -PathType leaf)
{
    # nothing to do here
}
else
{
    curl -OutFile "./database_backups1/AdventureWorks2017.bak" "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak"
}
