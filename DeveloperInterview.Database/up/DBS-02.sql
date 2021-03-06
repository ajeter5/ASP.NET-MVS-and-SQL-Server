--DBS-02: Create a script to establish a foreign key relationship between dbo.Customer and dbo.CustomerOrder

--Script: DBS-02
--Author: Austin Jeter
--Date: 2018-08-15
--Description:
--This script creates a foreign key relationship between Customer.Id and CustomerOrder.CustomerId

USE [CRC.DeveloperInterview]

BEGIN TRY

	BEGIN TRANSACTION;

	DELETE FROM [CRC.DeveloperInterview].[dbo].[CustomerOrder] 
	WHERE CustomerId NOT IN 
	(SELECT Id FROM [CRC.DeveloperInterview].[dbo].[Customer]) 
  
ALTER TABLE [dbo].[CustomerOrder]
ADD CONSTRAINT FK_CustomerId FOREIGN KEY (CustomerId) REFERENCES dbo.Customer(Id)   

COMMIT TRANSACTION;

END TRY

BEGIN CATCH
	
	ROLLBACK TRANSACTION;
	THROW;

END CATCH

GO