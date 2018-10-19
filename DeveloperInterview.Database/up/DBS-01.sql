--DBS-01: Identify the current heap table and create a script to introduce a clustered 
--index on that table (we generally create the clustered index on columns titled "Id")

--Script: DBS-01
--Author: Austin Jeter
--Date: 2018-08-15
--Description:
--This script creates a Clustered Index on Product.Id

USE [CRC.DeveloperInterview]

BEGIN TRY

	BEGIN TRANSACTION;

	ALTER TABLE [dbo].[Product] ADD CONSTRAINT [PK_Id] PRIMARY KEY CLUSTERED ([Id] ASC)

COMMIT TRANSACTION;

END TRY

BEGIN CATCH
	
	ROLLBACK TRANSACTION;
	THROW;

END CATCH

GO