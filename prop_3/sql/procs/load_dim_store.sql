Create PROCEDURE [dw].[load_dim_store]
@Debug Bit=0
AS
Begin
    -- Logging: Procedure Start
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_dim_store', 'Proc Starting', 1, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;
    SET NOCOUNT ON;
    if @Debug =0
    Begin
        SET NOCOUNT ON;
    END
    Else
    Begin
        SET NOCOUNT OFF;
		--add debug code
    END
	--Soft delete
	;With Src as (
		Select	*
		from	stg_stores_raw
		--where	__$operation in (1) -- deleted records
		)
	Update	Tgt
	Set		is_deleted			=1,		--soft delete
			record_change_date	=Getdate(),
			record_status		=1 -- New record
	from	Src
	Inner join
			dw.dim_store Tgt
	ON		Src.store_id=Tgt.store_id
	
	-- update existing records
	;With Src as (
		Select	*,
				ROW_NUMBER() Over (partition by store_id order by store_id) RN -- or some business rule to get one value per store_id
		from	stg_stores_raw
		--where	__$operation in (2,4) -- only get new and post update values
		)
	Update	Tgt
	Set		store_id			=Src.store_id,
			store_name			=Src.store_name,
			store_city			=Src.store_city,
			store_state			=Src.store_state,
			store_opened_date	=Src.store_opened_date,
			data_src			=0,
			is_deleted			=0,
			record_change_date	=Getdate(),
			record_status		=1 -- New record
	from	Src
	Inner join
			dw.dim_store Tgt
	ON		Src.store_id=Tgt.store_id
			And Src.Rn=1
	Where	checksum(concat(Tgt.store_id,Tgt.store_name,Tgt.store_city, Tgt.store_state, Tgt.store_opened_date))
			<>
			checksum(concat(Src.store_id,Src.store_name,Src.store_city, Src.store_state, Src.store_opened_date))

	;With Src as (
		Select	*,
				ROW_NUMBER() Over (partition by store_id order by store_id) RN -- or some business rule to get one value per store_id
		from	stg_stores_raw
		--where	__$operation in (2,4) -- only get new and post update values
		)
	Insert	 dw.dim_store
	(		 store_id			
			,store_name			
			,store_city			
			,store_state			
			,store_opened_date	
			,data_src			
			,is_deleted			
			,record_change_date	
			,record_status)
	Select  Src.store_id,
			Src.store_name,
			Src.store_city,
			Src.store_state,
			Src.store_opened_date,
			0,
			0,
			Getdate(),
			1 -- New record
	from	Src
	Left join
			dw.dim_store Tgt
	ON		Src.store_id=Tgt.store_id
			And Src.Rn=1
	Where	Tgt.store_id is Null
		
    ---- Logging: Procedure End
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_dim_store', 'Proc Ending', 2, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;

END;
