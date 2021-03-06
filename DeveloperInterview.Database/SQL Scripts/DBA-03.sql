--DBA-03: Create a script to list all Customers, along with how much money they've spent, 
--sorted by highest amount spent to lowest amount spent

--Script: DBA-03
--Author: Austin Jeter 
--Date: 2018-08-15
--Description:
--This script returns all Customers with thier total amount spent, ordered from highest to lowest

USE [MVCDatabase]

SELECT Customer.[Id] AS CustomerId
      ,Customer.[FirstName] + ' ' + Customer.[LastName] AS CustomerName
      ,SUM(Prod.Price * OrderProd.Quantity) AS TotalAmountSpent
  FROM [MVCDatabase].[dbo].[Customer] Customer
  INNER JOIN [MVCDatabase].[dbo].[CustomerOrder] AS CustOrder
  ON Customer.Id = CustOrder.CustomerId
  INNER JOIN [MVCDatabase].[dbo].[OrderProduct] AS OrderProd
  ON CustOrder.Id = OrderProd.CustomerOrderId
  INNER JOIN [MVCDatabase].[dbo].[Product] AS Prod
  ON OrderProd.ProductId = Prod.Id
  GROUP BY Customer.[Id] 
      ,Customer.[FirstName] 
      ,Customer.[LastName]
  ORDER BY TotalAmountSpent DESC

  GO