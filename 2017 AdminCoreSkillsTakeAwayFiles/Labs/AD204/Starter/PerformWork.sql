USE PPK_Test;
GO

INSERT dbo.Packages (PackageName)
VALUES ('Package ' + CAST((SELECT MAX(PackageID) + 1 FROM dbo.Packages) AS varchar(10)));
GO 10

