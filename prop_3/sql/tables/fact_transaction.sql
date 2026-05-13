Create Table dw.fact_transaction (
	transaction_key		int identity(1,1) Primary Key,
	store_key			int references dw.dim_store(store_key),
	product_key			int references dw.dim_product(product_key),
	quantity			int,
	unit_price			decimal(18,2),
	total_cost			AS (quantity * unit_price),
	transaction_date	datetime,	-- references date lkup table (note: dont want to use date dimension, can talk about it in demo)
	transaction_region	varchar(100), --ideally a lkup table   	
	data_src			int default(0), /*>> references to lkup data_src table, for now we will default to 0*/
	is_deleted			bit default(0),
	record_change_date	datetime default(getdate()),
	record_status		int  /*	1- new record
								0- processed record
								2- incompleted record
								3- rejected record
							 */
);

SET IDENTITY_INSERT dw.fact_transaction ON;
GO
insert dw.fact_transaction (
		transaction_key,
		store_key,			
		product_key,			
		quantity,
		unit_price,
		transaction_date,
		record_status		
	)
Select	0, 0,0,0,0,'1900-01-01',0
SET IDENTITY_INSERT dw.fact_transaction OFF;
GO

