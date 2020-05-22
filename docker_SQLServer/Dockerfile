FROM mcr.microsoft.com/mssql/server:2019-latest

# Create work directory
RUN mkdir -p /usr/work
WORKDIR /usr/work

# Copy all scripts into working directory
COPY . /usr/work/

# Grant permissions for the import-data script to be executable
RUN  /usr/work/import-data.sh

EXPOSE 1433
CMD /bin/bash ./entrypoint.sh

##in the terminal window build the image and tag it mssql:dev :
#docker build -t mssql:dev .

##and then run the mssql:dev image (TODO: how to create a volume using dockerfile):
# docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=passw0rd1!" --name sql2019 -p 1433:1433 -d mssql:dev