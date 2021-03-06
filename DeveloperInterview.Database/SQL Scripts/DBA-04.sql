--DBA-04: Create a script to list all Customers with no Orders (must use a JOIN in the answer)

--Script: DBA-04
--Author: Austin Jeter 
--Date: 2018-08-15
--Description:
--This script returns all Customers with no Orders

USE [MVCDatabase]

SELECT Cust.[Id]
      ,Cust.[FirstName]
      ,Cust.[LastName]
	  ,CustOrder.Id
  FROM [MVCDatabase].[dbo].[Customer] AS Cust
  LEFT JOIN [MVCDatabase].[dbo].[CustomerOrder] AS CustOrder
  ON Cust.Id = CustOrder.CustomerId
  WHERE CustOrder.Id IS NULL
  ORDER BY Cust.Id 

GO