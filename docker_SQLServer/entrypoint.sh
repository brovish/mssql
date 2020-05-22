#we have to reference the executable/script that we want to run when docker image is run.
#That means we can only import data by running sql scripts after the server is executing. So the following 
#is wrong in wrong order.
# /opt/mssql/bin/sqlservr & /usr/work/import-data.sh
/usr/work/create_volume.sh & /usr/work/import-data.sh & /opt/mssql/bin/sqlservr
