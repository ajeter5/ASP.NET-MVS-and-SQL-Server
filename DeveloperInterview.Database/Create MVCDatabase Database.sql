USE [master]
GO

CREATE DATABASE [MVCDatabase]
GO

USE [MVCDatabase]
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'OrderProduct', N'COLUMN',N'ProductRating'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderProduct', @level2type=N'COLUMN',@level2name=N'ProductRating'
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderProduct]') AND type in (N'U'))
ALTER TABLE [dbo].[OrderProduct] DROP CONSTRAINT IF EXISTS [FK_OrderProduct_Product]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderProduct]') AND type in (N'U'))
ALTER TABLE [dbo].[OrderProduct] DROP CONSTRAINT IF EXISTS [FK_OrderProduct_CustomerOrder]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomerOrder]') AND type in (N'U'))
ALTER TABLE [dbo].[CustomerOrder] DROP CONSTRAINT IF EXISTS [FK_CustomerId]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomerOrder]') AND type in (N'U'))
ALTER TABLE [dbo].[CustomerOrder] DROP CONSTRAINT IF EXISTS [DF__CustomerO__Notes__17036CC0]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customer]') AND type in (N'U'))
ALTER TABLE [dbo].[Customer] DROP CONSTRAINT IF EXISTS [DF_Customer_AddedDate]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 8/18/2018 6:04:04 PM ******/
DROP TABLE IF EXISTS [dbo].[Product]
GO
/****** Object:  Table [dbo].[OrderProduct]    Script Date: 8/18/2018 6:04:04 PM ******/
DROP TABLE IF EXISTS [dbo].[OrderProduct]
GO
/****** Object:  Table [dbo].[CustomerOrder]    Script Date: 8/18/2018 6:04:04 PM ******/
DROP TABLE IF EXISTS [dbo].[CustomerOrder]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 8/18/2018 6:04:04 PM ******/
DROP TABLE IF EXISTS [dbo].[Customer]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 8/18/2018 6:04:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customer]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Customer](
	[Id] [int] NOT NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[LastName] [nvarchar](75) NOT NULL,
	[AddedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[CustomerOrder]    Script Date: 8/18/2018 6:04:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomerOrder]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CustomerOrder](
	[Id] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[AddedDate] [datetime] NOT NULL,
	[Notes] [varchar](max) NOT NULL,
 CONSTRAINT [PK_CustomerOrder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[OrderProduct]    Script Date: 8/18/2018 6:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderProduct]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OrderProduct](
	[Id] [int] NOT NULL,
	[CustomerOrderId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[ProductRating] [int] NULL,
 CONSTRAINT [PK_OrderProduct] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Product]    Script Date: 8/18/2018 6:04:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Product]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Product](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](75) NOT NULL,
	[Price] [decimal](18, 6) NOT NULL,
	[AddedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Customer_AddedDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_AddedDate]  DEFAULT (getdate()) FOR [AddedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__CustomerO__Notes__17036CC0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CustomerOrder] ADD  DEFAULT ('None') FOR [Notes]
END
GO
