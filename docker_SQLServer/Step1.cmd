REM This needs to be done outside the docker image build process, on the host. If the host was Linux, write a sh script to do same 
REM When u run the docker image to create a container, you map a directory inside the container to a volume. Now all files in that
REM directory are persisted. The dir in the example below "/var/opt/mssql" is the one used my linux to store db files (both user and 
REM system dbs). Hence 
REM docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=passw0rd1!" --name sql2019 -p 1401:1433 -d mssql:dev -v sql_volume:/var/opt/mssql
docker volume create sql_volume
