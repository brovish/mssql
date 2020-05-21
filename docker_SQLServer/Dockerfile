# FROM mcr.microsoft.com/mssql/server:2019-latest
# RUN -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=passw0rd1!" -p 1433:1437 -d mcr.microsoft.com/mssql/server:2019-latest


# docker pull mcr.microsoft.com/mssql/server:2019-latest
##add the volume persistence logic from Klaus blog entry for sqlbits?

#docker volume create sql2019_volume
#docker volume ls
#docker volume inspect sql2019_volume

#docker run -e ‘ACCEPT_EULA=Y’ -e ‘SA_PASSWORD=passw0rd1!’ -p 1433:1437 --name sql2019 -v sql2019_volume:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2019-latest

##if the volume persistence logic works, you would have to restore the db only once. Handle that.
#docker cp "C:/mssqlsrv2019/backup/Adventure Works 2014 Full Database Backup/AdventureWorks2014.bak" sql2019:/var/backups/AdventureWorks2014.bak
##after this you can connect to sql server running in container using localhost:1437 and sa/passw0rd1!
##and then restore the dtabase in the container
#RESTORE DATABASE AdventureWorks2014 FROM DISK = '/var/backups/AdventureWorks2014.bak'
# WITH
# MOVE 'AdventureWorks2014_Data' TO '/var/opt/mssql/data/Adventureworks2014.mdf',
# MOVE 'AdventureWorks2014_Log' TO '/var/opt/mssql/data/Adventureworks2014.ldf'

# docker container ls 
#docker stop sql2019
#docker start sql2019
