-- AD208 Solution File

CREATE TABLE Sales.Test
( Col1 int
);
GO

INSERT Sales.Test (Col1) VALUES (2);
GO

DELETE Sales.Test;
GO

DROP TABLE Sales.Test;
GO

SELECT * FROM sys.fn_get_audit_file('C:\Labs\AD208\Audit\*',NULL,NULL);
GO

SELECT DISTINCT session_server_principal_name
FROM sys.fn_get_audit_file('C:\Labs\AD208\Audit\*',NULL,NULL) AS a
WHERE a.class_type = 'U' 
AND a.schema_name = 'Sales';
GO