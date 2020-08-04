CD \Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn
net stop "SQL Server Agent (MSSQLSERVER)"
net stop MSSQLSERVER
unlodctr MSSQLSERVER
lodctr perf-MSSQLSERVERsqlctr.ini
lodctr sqlctr.ini
net stop "Remote Registry"
net start "Remote Registry"
net stop "Performance Logs & Alerts"
net start "Performance Logs & Alerts"
net start MSSQLSERVER
net start "SQL Server Agent (MSSQLSERVER)"

