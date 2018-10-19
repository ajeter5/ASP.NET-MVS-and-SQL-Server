USE MVCDatabase
GO

SELECT
	   C.FirstName+' '+C.LastName AS CustomerName
	 , CO.AddedDate AS DateOrdered
	 , OP.ItemCount AS NumberOfItemsOrdered
FROM dbo.Customer C
	 INNER JOIN dbo.CustomerOrder CO ON C.Id = CO.Id
	 INNER JOIN
(
	SELECT
		   CustomerOrderId
		 , COUNT(1) AS ItemCount
	FROM dbo.OrderProduct
	GROUP BY
			 CustomerOrderId
) AS OP ON OP.CustomerOrderId = CO.Id;