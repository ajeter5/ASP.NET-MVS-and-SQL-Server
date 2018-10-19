--DBS-03: Create a script to ensure a Customer Order cannot 
--have the same Product specified multiple times in an Order

--Script: DBA-03
--Author: Austin Jeter 
--Date: 2018-08-15
--Description:
--This script deletes orders that have the same Product multiple times

USE [CRC.DeveloperInterview]

BEGIN TRY

	BEGIN TRANSACTION;

	DELETE FROM [CRC.DeveloperInterview].[dbo].[OrderProduct] 
	Where CustomerOrderId in
	(select CustomerOrderId from [CRC.DeveloperInterview].[dbo].[OrderProduct] 
	GROUP BY CustomerOrderId, ProductId
	HAVING COUNT(*) > 1)
	and ProductId in 
	(select ProductId from [CRC.DeveloperInterview].[dbo].[OrderProduct] 
	GROUP BY CustomerOrderId, ProductId
	HAVING COUNT(*) > 1);

	COMMIT TRANSACTION;

END TRY

BEGIN CATCH
	
	ROLLBACK TRANSACTION;
	THROW;

END CATCH

GO