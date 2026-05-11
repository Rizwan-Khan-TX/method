DECLARE @json_product_catalog NVARCHAR(MAX);
SELECT @json_product_catalog =BulkColumn
FROM OPENROWSET(BULK 'C:\Users\rijib\OneDrive\Documents\GitHub\method\data\product_catalog.json', SINGLE_CLOB) AS j;

SELECT *
FROM OPENJSON(@json_product_catalog)
WITH (
    sku NVARCHAR(100) '$.sku',
    product_name NVARCHAR(100)  '$.product_name',
	category NVARCHAR(100)  '$.category',
	supplier_id  NVARCHAR(MAX)  '$.supplier.id',
	supplier_name  NVARCHAR(MAX)  '$.supplier.name',
	supplier_country  NVARCHAR(MAX)  '$.supplier.country'
);

SELECT *
FROM OPENROWSET(
    BULK 'C:\Users\rijib\OneDrive\Documents\GitHub\method\data\store_metadata.csv', 
	FIRSTROW = 2,            -- Skips the header row
	FORMATFILE = 'C:\Users\rijib\OneDrive\Documents\GitHub\method\data\store_metadata_format.xml'
) AS FileData;

SELECT *
FROM OPENROWSET(
    BULK 'C:\Users\rijib\OneDrive\Documents\GitHub\method\data\transactions.csv', 
	FIRSTROW = 2,            -- Skips the header row
	FORMATFILE = 'C:\Users\rijib\OneDrive\Documents\GitHub\method\data\transaction_format.xml'
) AS FileData;

