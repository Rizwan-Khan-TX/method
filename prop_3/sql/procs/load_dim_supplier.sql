CREATE PROCEDURE [dw].[load_dim_supplier]
@Debug Bit=0
AS
Begin
    -- Logging: Procedure Start
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_dim_supplier', 'Proc Starting', 1, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;
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
	;With A as (
		Select	distinct 
				supplier_id,
				supplier_name,
				supplier_country 
		from	stg_products_raw
		--where	__$operation in (1) -- deleted records
		)
	,Src as(
		Select	* 
		from	A)
	Update	Tgt
	Set		is_deleted			=1,		--soft delete
			record_change_date	=Getdate(),
			record_status		=1 -- New record
	from	Src
	Inner join
			dw.dim_supplier Tgt
	ON		Src.supplier_id=Tgt.supplier_id

	-- update existing records
	;With A as (
		Select	distinct 
				supplier_id,
				supplier_name,
				supplier_country 
		from	stg_products_raw
		--where	__$operation in (1) -- deleted records
		)
	,Src as(
		Select	*,
				ROW_NUMBER() Over (partition by supplier_id order by supplier_id) RN -- or some business rule to get one value per supplier_id
		from	A
		--where	__$operation in (2,4) -- only get new and post update values
		)
	Update	Tgt
	Set		supplier_id			=Src.supplier_id,
			supplier_name		=Src.supplier_name,
			supplier_country	=Src.supplier_country,
			data_src			=0,
			is_deleted			=0,
			record_change_date	=Getdate(),
			record_status		=1 -- New record
	from	Src
	Inner join
			dw.dim_supplier Tgt
	ON		Src.supplier_id=Tgt.supplier_id
			And Src.Rn=1
	Where	checksum(concat(Tgt.supplier_id,Tgt.supplier_name,Tgt.supplier_country))
			<>
			checksum(concat(Src.supplier_id,Src.supplier_name,Src.supplier_country ))

	;With A as (
		Select	distinct 
				supplier_id,
				supplier_name,
				supplier_country 
		from	stg_products_raw
		--where	__$operation in (1) -- deleted records
		)
	,Src as(
		Select	*,
				ROW_NUMBER() Over (partition by supplier_id order by supplier_id) RN -- or some business rule to get one value per supplier_id
		from	A
		--where	__$operation in (2,4) -- only get new and post update values
		)
	Insert	 dw.dim_supplier
	(		 supplier_id			
			,supplier_name			
			,supplier_country			
			,data_src			
			,is_deleted			
			,record_change_date	
			,record_status)
	Select  Src.supplier_id,
			Src.supplier_name,
			Src.supplier_country,
			0,
			0,
			Getdate(),
			1 -- New record
	from	Src
	Left join
			dw.dim_supplier Tgt
	ON		Src.supplier_id=Tgt.supplier_id
			And Src.Rn=1
	Where	Tgt.supplier_id is Null
		
    ---- Logging: Procedure End
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_dim_supplier', 'Proc Ending', 2, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;

END;
