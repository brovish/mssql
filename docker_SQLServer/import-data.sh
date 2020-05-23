# wait for the SQL Server to come up
sleep 15s

#run the setup script to create the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "passw0rd1!" -i ./database_scripts/PerformanceV3.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "passw0rd1!" -i ./database_scripts/TSQLV3.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "passw0rd1!" -i ./database_scripts/TSQLV4.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "passw0rd1!" -i ./database_scripts/SQLCookbook_DbCreation.sql


#RestoreBackups.sql would be used to restore backups
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "passw0rd1!" -i RestoreBackups.sql

# # import the data from the csv file
# /opt/mssql-tools/bin/bcp heroes.dbo.HeroValue in "/usr/work/heroes.csv" -c -t',' -S localhost -U SA -P "Password1!" -d heroes