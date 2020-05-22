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

#Block2: The following is used for building the running the image
#this program/script that we want to run when the image is run. This program/script has to 
#be copied into the image as shown above. This is what is executed when [docker run] command
CMD /bin/bash ./entrypoint.sh

##in the terminal window build the image and tag it mssql:dev :
#docker build -t mssql:dev .

##and then run the mssql:dev image (TODO: how to create a volume using dockerfile):
# docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=passw0rd1!" --name sql2019 -p 1401:1433 -d mssql:dev -v sql_volume:/var/opt/mssql
