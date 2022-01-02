/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_SalesTerritory_TerritoryID
GO
ALTER TABLE Sales.SalesTerritory SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_ShipMethod_ShipMethodID
GO
ALTER TABLE Purchasing.ShipMethod SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_SalesPerson_SalesPersonID
GO
ALTER TABLE Sales.SalesPerson SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_Customer_CustomerID
GO
ALTER TABLE Sales.Customer SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_CurrencyRate_CurrencyRateID
GO
ALTER TABLE Sales.CurrencyRate SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_CreditCard_CreditCardID
GO
ALTER TABLE Sales.CreditCard SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_Address_BillToAddressID
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT FK_SalesOrderHeader_Address_ShipToAddressID
GO
ALTER TABLE Person.Address SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_RevisionNumber
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_OrderDate
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_Status
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_OnlineOrderFlag
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_SubTotal
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_TaxAmt
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_Freight
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_rowguid
GO
ALTER TABLE Sales.SalesOrderHeader
	DROP CONSTRAINT DF_SalesOrderHeader_ModifiedDate
GO
CREATE TABLE Sales.Tmp_SalesOrderHeader
	(
	SalesOrderID int NOT NULL IDENTITY (1, 1) NOT FOR REPLICATION,
	RevisionNumber tinyint NOT NULL,
	OrderDate datetime NOT NULL,
	DueDate datetime NOT NULL,
	ShipDate datetime NULL,
	Status tinyint NOT NULL,
	OnlineOrderFlag dbo.Flag NOT NULL,
	SalesOrderNumber  AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID],(0)),N'*** ERROR ***')),
	PurchaseOrderNumber dbo.OrderNumber NULL,
	AccountNumber dbo.AccountNumber NULL,
	CustomerID int NOT NULL,
	SalesPersonID int NULL,
	TerritoryID int NULL,
	BillToAddressID int NOT NULL,
	ShipToAddressID int NOT NULL,
	ShipMethodID int NOT NULL,
	CreditCardID int NULL,
	CreditCardApprovalCode varchar(15) NULL,
	CurrencyRateID int NULL,
	SubTotal money NOT NULL,
	TaxAmt money NOT NULL,
	Freight money NOT NULL,
	TotalDue  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
	Comment nvarchar(128) NULL,
	rowguid uniqueidentifier NOT NULL ROWGUIDCOL,
	ModifiedDate datetime NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader SET (LOCK_ESCALATION = TABLE)
GO
DECLARE @v sql_variant 
SET @v = N'General sales order information.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', NULL, NULL
GO
DECLARE @v sql_variant 
SET @v = N'Primary key.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'SalesOrderID'
GO
DECLARE @v sql_variant 
SET @v = N'Incremental number to track changes to the sales order over time.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'RevisionNumber'
GO
DECLARE @v sql_variant 
SET @v = N'Dates the sales order was created.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'OrderDate'
GO
DECLARE @v sql_variant 
SET @v = N'Date the order is due to the customer.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'DueDate'
GO
DECLARE @v sql_variant 
SET @v = N'Date the order was shipped to the customer.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'ShipDate'
GO
DECLARE @v sql_variant 
SET @v = N'Order current status. 1 = In process; 2 = Approved; 3 = Backordered; 4 = Rejected; 5 = Shipped; 6 = Cancelled'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'Status'
GO
DECLARE @v sql_variant 
SET @v = N'0 = Order placed by sales person. 1 = Order placed online by customer.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'OnlineOrderFlag'
GO
DECLARE @v sql_variant 
SET @v = N'Unique sales order identification number.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'SalesOrderNumber'
GO
DECLARE @v sql_variant 
SET @v = N'Customer purchase order number reference. '
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'PurchaseOrderNumber'
GO
DECLARE @v sql_variant 
SET @v = N'Financial accounting number reference.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'AccountNumber'
GO
DECLARE @v sql_variant 
SET @v = N'Customer identification number. Foreign key to Customer.BusinessEntityID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'CustomerID'
GO
DECLARE @v sql_variant 
SET @v = N'Sales person who created the sales order. Foreign key to SalesPerson.BusinessEntityID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'SalesPersonID'
GO
DECLARE @v sql_variant 
SET @v = N'Territory in which the sale was made. Foreign key to SalesTerritory.SalesTerritoryID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'TerritoryID'
GO
DECLARE @v sql_variant 
SET @v = N'Customer billing address. Foreign key to Address.AddressID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'BillToAddressID'
GO
DECLARE @v sql_variant 
SET @v = N'Customer shipping address. Foreign key to Address.AddressID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'ShipToAddressID'
GO
DECLARE @v sql_variant 
SET @v = N'Shipping method. Foreign key to ShipMethod.ShipMethodID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'ShipMethodID'
GO
DECLARE @v sql_variant 
SET @v = N'Credit card identification number. Foreign key to CreditCard.CreditCardID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'CreditCardID'
GO
DECLARE @v sql_variant 
SET @v = N'Approval code provided by the credit card company.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'CreditCardApprovalCode'
GO
DECLARE @v sql_variant 
SET @v = N'Currency exchange rate used. Foreign key to CurrencyRate.CurrencyRateID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'CurrencyRateID'
GO
DECLARE @v sql_variant 
SET @v = N'Sales subtotal. Computed as SUM(SalesOrderDetail.LineTotal)for the appropriate SalesOrderID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'SubTotal'
GO
DECLARE @v sql_variant 
SET @v = N'Tax amount.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'TaxAmt'
GO
DECLARE @v sql_variant 
SET @v = N'Shipping cost.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'Freight'
GO
DECLARE @v sql_variant 
SET @v = N'Total due from customer. Computed as Subtotal + TaxAmt + Freight.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'TotalDue'
GO
DECLARE @v sql_variant 
SET @v = N'Sales representative comments.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'Comment'
GO
DECLARE @v sql_variant 
SET @v = N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'rowguid'
GO
DECLARE @v sql_variant 
SET @v = N'Date and time the record was last updated.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'Tmp_SalesOrderHeader', N'COLUMN', N'ModifiedDate'
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_RevisionNumber DEFAULT ((0)) FOR RevisionNumber
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_OrderDate DEFAULT (getdate()) FOR OrderDate
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_Status DEFAULT ((1)) FOR Status
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_OnlineOrderFlag DEFAULT ((1)) FOR OnlineOrderFlag
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_SubTotal DEFAULT ((0.00)) FOR SubTotal
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_TaxAmt DEFAULT ((0.00)) FOR TaxAmt
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_Freight DEFAULT ((0.00)) FOR Freight
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_rowguid DEFAULT (newid()) FOR rowguid
GO
ALTER TABLE Sales.Tmp_SalesOrderHeader ADD CONSTRAINT
	DF_SalesOrderHeader_ModifiedDate DEFAULT (getdate()) FOR ModifiedDate
GO
SET IDENTITY_INSERT Sales.Tmp_SalesOrderHeader ON
GO
IF EXISTS(SELECT * FROM Sales.SalesOrderHeader)
	 EXEC('INSERT INTO Sales.Tmp_SalesOrderHeader (SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate)
		SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, PurchaseOrderNumber, CONVERT(nvarchar(15), AccountNumber), CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate FROM Sales.SalesOrderHeader WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT Sales.Tmp_SalesOrderHeader OFF
GO
ALTER TABLE Sales.SalesOrderHeaderSalesReason
	DROP CONSTRAINT FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID
GO
ALTER TABLE Sales.SalesOrderDetail
	DROP CONSTRAINT FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID
GO
DROP TABLE Sales.SalesOrderHeader
GO
EXECUTE sp_rename N'Sales.Tmp_SalesOrderHeader', N'SalesOrderHeader', 'OBJECT' 
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	PK_SalesOrderHeader_SalesOrderID PRIMARY KEY CLUSTERED 
	(
	SalesOrderID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
DECLARE @v sql_variant 
SET @v = N'Clustered index created by a primary key constraint.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'PK_SalesOrderHeader_SalesOrderID'
GO
CREATE UNIQUE NONCLUSTERED INDEX AK_SalesOrderHeader_rowguid ON Sales.SalesOrderHeader
	(
	rowguid
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Unique nonclustered index. Used to support replication samples.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'INDEX', N'AK_SalesOrderHeader_rowguid'
GO
CREATE UNIQUE NONCLUSTERED INDEX AK_SalesOrderHeader_SalesOrderNumber ON Sales.SalesOrderHeader
	(
	SalesOrderNumber
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Unique nonclustered index.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'INDEX', N'AK_SalesOrderHeader_SalesOrderNumber'
GO
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_CustomerID ON Sales.SalesOrderHeader
	(
	CustomerID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Nonclustered index.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'INDEX', N'IX_SalesOrderHeader_CustomerID'
GO
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_SalesPersonID ON Sales.SalesOrderHeader
	(
	SalesPersonID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Nonclustered index.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'INDEX', N'IX_SalesOrderHeader_SalesPersonID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	CK_SalesOrderHeader_Status CHECK (([Status]>=(0) AND [Status]<=(8)))
GO
DECLARE @v sql_variant 
SET @v = N'Check constraint [Status] BETWEEN (0) AND (8)'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'CK_SalesOrderHeader_Status'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	CK_SalesOrderHeader_DueDate CHECK (([DueDate]>=[OrderDate]))
GO
DECLARE @v sql_variant 
SET @v = N'Check constraint [DueDate] >= [OrderDate]'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'CK_SalesOrderHeader_DueDate'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	CK_SalesOrderHeader_ShipDate CHECK (([ShipDate]>=[OrderDate] OR [ShipDate] IS NULL))
GO
DECLARE @v sql_variant 
SET @v = N'Check constraint [ShipDate] >= [OrderDate] OR [ShipDate] IS NULL'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'CK_SalesOrderHeader_ShipDate'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	CK_SalesOrderHeader_SubTotal CHECK (([SubTotal]>=(0.00)))
GO
DECLARE @v sql_variant 
SET @v = N'Check constraint [SubTotal] >= (0.00)'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'CK_SalesOrderHeader_SubTotal'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	CK_SalesOrderHeader_TaxAmt CHECK (([TaxAmt]>=(0.00)))
GO
DECLARE @v sql_variant 
SET @v = N'Check constraint [TaxAmt] >= (0.00)'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'CK_SalesOrderHeader_TaxAmt'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	CK_SalesOrderHeader_Freight CHECK (([Freight]>=(0.00)))
GO
DECLARE @v sql_variant 
SET @v = N'Check constraint [Freight] >= (0.00)'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'CK_SalesOrderHeader_Freight'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_Address_BillToAddressID FOREIGN KEY
	(
	BillToAddressID
	) REFERENCES Person.Address
	(
	AddressID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing Address.AddressID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_Address_BillToAddressID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_Address_ShipToAddressID FOREIGN KEY
	(
	ShipToAddressID
	) REFERENCES Person.Address
	(
	AddressID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing Address.AddressID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_Address_ShipToAddressID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_CreditCard_CreditCardID FOREIGN KEY
	(
	CreditCardID
	) REFERENCES Sales.CreditCard
	(
	CreditCardID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing CreditCard.CreditCardID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_CreditCard_CreditCardID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_CurrencyRate_CurrencyRateID FOREIGN KEY
	(
	CurrencyRateID
	) REFERENCES Sales.CurrencyRate
	(
	CurrencyRateID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing CurrencyRate.CurrencyRateID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_CurrencyRate_CurrencyRateID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_Customer_CustomerID FOREIGN KEY
	(
	CustomerID
	) REFERENCES Sales.Customer
	(
	CustomerID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing Customer.CustomerID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_Customer_CustomerID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_SalesPerson_SalesPersonID FOREIGN KEY
	(
	SalesPersonID
	) REFERENCES Sales.SalesPerson
	(
	BusinessEntityID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing SalesPerson.SalesPersonID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_SalesPerson_SalesPersonID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_ShipMethod_ShipMethodID FOREIGN KEY
	(
	ShipMethodID
	) REFERENCES Purchasing.ShipMethod
	(
	ShipMethodID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing ShipMethod.ShipMethodID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_ShipMethod_ShipMethodID'
GO
ALTER TABLE Sales.SalesOrderHeader ADD CONSTRAINT
	FK_SalesOrderHeader_SalesTerritory_TerritoryID FOREIGN KEY
	(
	TerritoryID
	) REFERENCES Sales.SalesTerritory
	(
	TerritoryID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing SalesTerritory.TerritoryID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'CONSTRAINT', N'FK_SalesOrderHeader_SalesTerritory_TerritoryID'
GO
CREATE TRIGGER [Sales].[uSalesOrderHeader] ON Sales.SalesOrderHeader 
AFTER UPDATE NOT FOR REPLICATION AS 
BEGIN
DECLARE @Count int;
SET @Count = @@ROWCOUNT;
IF @Count = 0 
RETURN;
SET NOCOUNT ON;
BEGIN TRY
IF NOT UPDATE([Status])
BEGIN
UPDATE [Sales].[SalesOrderHeader]
SET [Sales].[SalesOrderHeader].[RevisionNumber] = 
[Sales].[SalesOrderHeader].[RevisionNumber] + 1
WHERE [Sales].[SalesOrderHeader].[SalesOrderID] IN 
(SELECT inserted.[SalesOrderID] FROM inserted);
END;
IF UPDATE([SubTotal])
BEGIN
DECLARE @StartDate datetime,
@EndDate datetime
SET @StartDate = [dbo].[ufnGetAccountingStartDate]();
SET @EndDate = [dbo].[ufnGetAccountingEndDate]();
UPDATE [Sales].[SalesPerson]
SET [Sales].[SalesPerson].[SalesYTD] = 
(SELECT SUM([Sales].[SalesOrderHeader].[SubTotal])
FROM [Sales].[SalesOrderHeader] 
WHERE [Sales].[SalesPerson].[BusinessEntityID] = [Sales].[SalesOrderHeader].[SalesPersonID]
AND ([Sales].[SalesOrderHeader].[Status] = 5) -- Shipped
AND [Sales].[SalesOrderHeader].[OrderDate] BETWEEN @StartDate AND @EndDate)
WHERE [Sales].[SalesPerson].[BusinessEntityID] 
IN (SELECT DISTINCT inserted.[SalesPersonID] FROM inserted 
WHERE inserted.[OrderDate] BETWEEN @StartDate AND @EndDate);
UPDATE [Sales].[SalesTerritory]
SET [Sales].[SalesTerritory].[SalesYTD] = 
(SELECT SUM([Sales].[SalesOrderHeader].[SubTotal])
FROM [Sales].[SalesOrderHeader] 
WHERE [Sales].[SalesTerritory].[TerritoryID] = [Sales].[SalesOrderHeader].[TerritoryID]
AND ([Sales].[SalesOrderHeader].[Status] = 5) -- Shipped
AND [Sales].[SalesOrderHeader].[OrderDate] BETWEEN @StartDate AND @EndDate)
WHERE [Sales].[SalesTerritory].[TerritoryID] 
IN (SELECT DISTINCT inserted.[TerritoryID] FROM inserted 
WHERE inserted.[OrderDate] BETWEEN @StartDate AND @EndDate);
END;
END TRY
BEGIN CATCH
EXECUTE [dbo].[uspPrintError];
IF @@TRANCOUNT > 0
BEGIN
ROLLBACK TRANSACTION;
END
EXECUTE [dbo].[uspLogError];
END CATCH;
END;
GO
DECLARE @v sql_variant 
SET @v = N'AFTER UPDATE trigger that updates the RevisionNumber and ModifiedDate columns in the SalesOrderHeader table.Updates the SalesYTD column in the SalesPerson and SalesTerritory tables.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeader', N'TRIGGER', N'uSalesOrderHeader'
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderDetail ADD CONSTRAINT
	FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID FOREIGN KEY
	(
	SalesOrderID
	) REFERENCES Sales.SalesOrderHeader
	(
	SalesOrderID
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing SalesOrderHeader.PurchaseOrderID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderDetail', N'CONSTRAINT', N'FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID'
GO
ALTER TABLE Sales.SalesOrderDetail SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE Sales.SalesOrderHeaderSalesReason ADD CONSTRAINT
	FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID FOREIGN KEY
	(
	SalesOrderID
	) REFERENCES Sales.SalesOrderHeader
	(
	SalesOrderID
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
DECLARE @v sql_variant 
SET @v = N'Foreign key constraint referencing SalesOrderHeader.SalesOrderID.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'Sales', N'TABLE', N'SalesOrderHeaderSalesReason', N'CONSTRAINT', N'FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID'
GO
ALTER TABLE Sales.SalesOrderHeaderSalesReason SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
