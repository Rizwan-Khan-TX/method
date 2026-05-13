create table dw.dim_supplier (
	supplier_key		int identity(1,1) Primary Key,
	supplier_id			varchar(10),
	supplier_name		varchar(100),
	supplier_country	varchar(100),
	mdm_supplier_key	int,
	data_src			int default(0), /*>> references to lkup data_src table, for now we will default to 0*/
	is_deleted			bit default(0),
	record_change_date	datetime default(getdate()),
	record_status		int  /*	1- new record
								0- processed record
								2- incompleted record
								3- rejected record
							 */
);

SET IDENTITY_INSERT dw.dim_supplier ON;
GO
insert dw.dim_supplier (
		supplier_key,			
		supplier_id,			
		supplier_name,			
		record_status		
	)
Select	0, '0','missing supplier',0	
SET IDENTITY_INSERT dw.dim_supplier OFF;
GO
