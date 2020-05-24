# commands for both windows and linux host for SQL Server docker containers on MDSN:
# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-docker?view=sql-server-ver15#customcontainer

#Block1: The following is used for building the image
FROM mcr.microsoft.com/mssql/server:2019-latest

# Create work directory
RUN mkdir -p /usr/work
WORKDIR /usr/work

# Copy all scripts into working directory
COPY . /usr/work/

##no need to copy the databasebackups folder as the above COPY command copies files as well as directories
#COPY ./database_backups/ /usr/work/database_backups/

# Grant permissions for the import-data script to be executable
# RUN chown -R /usr/work/import-data.sh
USER root
RUN chmod +x /usr/work/create_volume.sh
RUN chmod +x /usr/work/import-data.sh

EXPOSE 1433

#Block2: The following is used for running the image
#the program/script that we want to execute when the image is run. This program/script has to 
#be copied into the image as shown above. This is what is executed when [docker run] command
CMD /bin/bash ./entrypoint.sh

##in the terminal window build the image and tag it mssql:dev You can also put this in a ps1 file
#docker build -t mssql:dev .

##and then run the "mssql:dev" image to build a container "sql2019" linking with volume created outside on the host:
##if you have not created a external volume (step1.cmd), remove the option "-v sql_volume:/var/opt/mssql" from below.
##For debugging, run container without -d option. TODO: u can run the same image twice but each container must
##expose itself on a different port and if using volumes, they can't both use same volume when both are running
##at the same time. "sql_volume" here is a data volume container that gets created, i think, on Linux VM that is the actual host that is used for 
##docker containers for windows. But you can share folders as volumes from you windows machine as well. e.g. [-v c:/temp:/var/opt/mssql/secrets]
# docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=passw0rd1!" -e "TZ=Australia/Sydney"  --name sql2019 -p 1401:1433 -v sql_volume:/var/opt/mssql -d mssql:dev
#docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<YourStrong!Passw0rd>" -p 1433:1433 -v c:/sqlsrv/data:/var/opt/mssql/data -v c:/sqlsrv/log:/var/opt/mssql/log -v c:/sqlsrv/secrets:/var/opt/mssql/secrets -d mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04

##if you did not remove the -d option, you can still checkout the generated message in errorlog: 
#docker exec -it sql2019 "bash"
#cat /var/opt/mssql/log/errorlog