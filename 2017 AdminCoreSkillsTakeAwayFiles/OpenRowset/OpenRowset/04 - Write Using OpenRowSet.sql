INSERT INTO OPENROWSET('Microsoft.Jet.OLEDB.4.0', 
                       'Excel 8.0;Database=C:\temp\someworksheet.xls;', 
                       'SELECT * FROM [SheetName$]') 
SELECT somecolumns FROM sometable;
