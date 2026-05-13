Create Table dw.dim_product (
	product_key			int identity(1,1) Primary Key,
	product_sku			varchar(10),
	product_name		varchar(100),
	product_category	varchar(100),
	supplier_key		int references dw.dim_supplier(supplier_key),
	data_src			int default(0), /*>> references to lkup data_src table, for now we will default to 0*/
	is_deleted			bit default(0),
	mdm_store_key		int,
	record_change_date	datetime default(getdate()),
	record_status		int  /*	1- new record
								0- processed record
								2- incompleted record
								3- rejected record
							 */
);

SET IDENTITY_INSERT dw.dim_product ON;
GO
insert dw.dim_product (
		product_key,			
		product_sku,			
		product_name,
		supplier_key,
		record_status		
	)
Select	0, '0','missing product',0,0	
SET IDENTITY_INSERT dw.dim_product OFF;
GO