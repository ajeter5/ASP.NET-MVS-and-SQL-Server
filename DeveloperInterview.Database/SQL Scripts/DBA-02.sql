--DBA-02: Create a script to list all Products, along with the total number of units sold, 
--sorted by highest total units sold to lowest total units sold
	
--Script: DBA-02
--Author: Austin Jeter 
--Date: 2018-08-15
--Description:
--This script returns all Products with the total number of units sold, sorted from highest to lowest

USE [MVCDatabase]

SELECT Prod.[Id] AS ProductId
      ,Prod.[Name] AS ProductName
	  ,SUM(OrdProd.[Quantity]) AS NumUnitsSold
  FROM [MVCDatabase].[dbo].[Product] AS Prod
  JOIN [MVCDatabase].[dbo].[OrderProduct] AS OrdProd
  ON Prod.Id = OrdProd.ProductId
  GROUP BY Prod.[Id], Prod.[Name] 
  ORDER BY NumUnitsSold DESC

GO