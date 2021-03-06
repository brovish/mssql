USE [SalesDB]
GO
/****** Object:  Table [dbo].[Sales]    Script Date: 06/14/2006 11:20:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sales](
	[SalesID] [int] IDENTITY(1,1) NOT NULL,
	[SalesPersonID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [SalesPK] PRIMARY KEY CLUSTERED 
(
	[SalesID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [SalesCustomersFK] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [SalesCustomersFK]
GO
ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [SalesEmployeesFK] FOREIGN KEY([SalesPersonID])
REFERENCES [dbo].[Employees] ([EmployeeID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [SalesEmployeesFK]
GO
ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [SalesProductsFK] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [SalesProductsFK]