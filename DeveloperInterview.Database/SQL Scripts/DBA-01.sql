--DBA-01: Create a script to list all Orders that have no Products

--Script: DBA-01
--Author: Austin Jeter
--Date: 2018-08-15
--Description:
--This script returns all Orders with no Products

USE [MVCDatabase]

SELECT [Id]
      ,[CustomerOrderId]
      ,[ProductId]
      ,[Quantity]
  FROM [MVCDatabase].[dbo].[OrderProduct]
  WHERE Quantity = 0

GO