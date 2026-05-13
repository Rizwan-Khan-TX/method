DECLARE @json_product_catalog NVARCHAR(MAX);
SELECT @json_product_catalog =BulkColumn
FROM OPENROWSET(BULK 'C:\Users\rijib\OneDrive\Documents\Method\data\product_catalog.json', SINGLE_CLOB) AS j;

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
    BULK 'C:\Users\rijib\OneDrive\Documents\Method\data\store_metadata.csv', 
	FIRSTROW = 2,            -- Skips the header row
	FORMATFILE = 'C:\Users\rijib\OneDrive\Documents\Method\data\store_metadata_format.xml'
) AS FileData;

SELECT *
FROM OPENROWSET(
    BULK 'C:\Users\rijib\OneDrive\Documents\Method\data\transactions.csv', 
	FIRSTROW = 2,            -- Skips the header row
	FORMATFILE = 'C:\Users\rijib\OneDrive\Documents\Method\data\transaction_format.xml'
) AS FileData;

--transaction_id	store_id	store_name	store_city	store_state	store_opened_date produc_sku	product_name	produc_category	supplier_id	supplier_name	supplier_country transaction_quantity	transaction_unit_price	transaction_ts	transaction_region


transaction_id	store_id	product_sku	quantity	unit_price	transaction_ts	region
TXN00303	STR026	SKU0044	13	152	2/7/2024 22:03	SOUTH