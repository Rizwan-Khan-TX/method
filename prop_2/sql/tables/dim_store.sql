Create Table dw.dim_store (
	store_key			int identity(1,1) Primary Key,
	store_id			varchar(10),
	store_name			varchar(100),
	store_city			varchar(100),	-- ideally references lkup table that holds city/state&zip
	store_state			varchar(10),	-- ideally references lkup table that holds city/state&zip
	store_opened_date	datetime	,	-- references date lkup table (note: dont want to use date dimension, can talk about it in demo)
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

SET IDENTITY_INSERT dw.dim_store ON;
GO
insert dw.dim_store (
		store_key,			
		store_id,			
		store_name,			
		record_status		
	)
Select	0, '0','missing store',0	
SET IDENTITY_INSERT dw.dim_store OFF;
GO

