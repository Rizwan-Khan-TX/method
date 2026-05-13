Create PROCEDURE [dw].[load_dim_product]
@Debug Bit=0
AS
Begin
    -- Logging: Procedure Start
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_dim_product', 'Proc Starting', 1, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;
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
		from	stg_products_raw
		--where	__$operation in (1) -- deleted records
		)
	Update	Tgt
	Set		is_deleted			=1,		--soft delete
			record_change_date	=Getdate(),
			record_status		=1 -- New record
	from	Src
	Inner join
			dw.dim_product Tgt
	ON		Src.product_sku=Tgt.product_sku
	
	-- update existing records
	;With Src as (
		Select	r.*,
				s.supplier_key,
				ROW_NUMBER() Over (partition by product_sku order by product_sku) RN -- or some business rule to get one value per product_sku
		from	stg_products_raw r
		Inner join
				dw.dim_supplier s
		On		r.supplier_id=s.supplier_id
		--where	__$operation in (2,4) -- only get new and post update values
		)
	Update	Tgt
	Set		product_sku			=Src.product_sku,
			product_name		=Src.product_name,
			product_category	=Src.product_category,
			supplier_key		=Src.supplier_key,
			data_src			=0,
			is_deleted			=0,
			record_change_date	=Getdate(),
			record_status		=1 -- New record
	from	Src
	Inner join
			dw.dim_product Tgt
	ON		Src.product_sku=Tgt.product_sku
			And Src.Rn=1
	Where	checksum(concat(Tgt.product_sku,Tgt.product_name,Tgt.product_category, Tgt.supplier_key))
			<>
			checksum(concat(Src.product_sku,Src.product_name,Src.product_category, Src.supplier_key))

	;With Src as (
		Select	r.*,
				s.supplier_key,
				ROW_NUMBER() Over (partition by product_sku order by product_sku) RN -- or some business rule to get one value per product_sku
		from	stg_products_raw r
		Inner join
				dw.dim_supplier s
		On		r.supplier_id=s.supplier_id
		--where	__$operation in (2,4) -- only get new and post update values
		)
	Insert	 dw.dim_product
	(		 product_sku			
			,product_name			
			,product_category			
			,supplier_key			
			,data_src			
			,is_deleted			
			,record_change_date	
			,record_status)
	Select  Src.product_sku,
			Src.product_name,
			Src.product_category,
			Src.supplier_key,
			0,
			0,
			Getdate(),
			1 -- New record
	from	Src
	Left join
			dw.dim_product Tgt
	ON		Src.product_sku=Tgt.product_sku
			And Src.Rn=1
	Where	Tgt.product_sku is Null
		
    ---- Logging: Procedure End
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_dim_product', 'Proc Ending', 2, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;

END;
