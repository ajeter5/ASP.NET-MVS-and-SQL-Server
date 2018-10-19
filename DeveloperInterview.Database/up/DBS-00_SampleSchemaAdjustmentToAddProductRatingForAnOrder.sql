IF NOT EXISTS
(
	SELECT
		   1 AS ColumnExists
	FROM sys.columns
	WHERE Name = N'ProductRating'
		  AND Object_ID = OBJECT_ID(N'dbo.OrderProduct')
)
BEGIN
	-- add the column to the table if it doesn't already exist
	ALTER TABLE dbo.OrderProduct
	ADD
				ProductRating INT;

	-- isn't really neccessary, but nice for documentation purposes
	EXEC sp_addextendedproperty
		 @name = N'MS_Description',
		 @value = 'Stores the customer rating for a product in the order',
		 @level0type = N'Schema',
		 @level0name = 'dbo',
		 @level1type = N'Table',
		 @level1name = 'OrderProduct',
		 @level2type = N'Column',
		 @level2name = 'ProductRating';
END;