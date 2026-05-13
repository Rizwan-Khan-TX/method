Create PROCEDURE [dw].[load_fact_transaction]
@Debug Bit=0
AS
Begin
    -- Logging: Procedure Start
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_fact_transaction', 'Proc Starting', 1, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;
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
	drop table if exists #Src
	--create temp table
	;With D as (
		Select	transaction_id,
				coalesce(s.store_key,0) store_key,
				coalesce(p.product_key,0) product_key,
				transaction_quantity quantity,
				transaction_unit_price unit_price,
				transaction_quantity*transaction_unit_price total_cost,
				transaction_ts transaction_date,
				transaction_region,
				0 data_src,
				ROW_NUMBER() over (partition by transaction_id order by transaction_id) RN
				,0  __$operation -- (1=deleted, 2=inserted, 4=post update) --using 1 as a mock value
		From	stg_transactions_raw t
		Left Join
				dw.dim_store s
		ON		s.store_id=t.store_id
		Left Join
				dw.dim_product p
		ON		p.product_sku=t.product_sku)
	Select	*,
			dq_reason=Replace(Case When IsNull(transaction_id,'')='' then 'NULL_OR_EMPTY_TRANSACTION_ID::' Else '' End+' '+
			Case when RN>1 then 'DUPLICATE_TRANSACTION_ID::' Else '' End+
			Case when IsNull(quantity,0)<1 then 'NULL_OR_EMPTY_TRANSACTION_QUANTITY::' Else '' End+
			Case when IsNull(unit_price,0)<1 then 'NULL_OR_EMPTY_TRANSACTION_UNIT_PRICE::' Else '' End+
			Case when store_key=0 then 'INVALID_STORE_ID::' Else '' End+
			Case when product_key=0 then 'INVALID_PRODUCT_SKU::' Else '' End+' '+
			Case When ISDATE(transaction_date)=0 then 'INVALID_TRANSACTION_TIMESTAMP::' Else '' End+' ',' ',' ')
	Into	#Src
	from	D

	--soft delete
	Update	TGT
	Set		is_deleted=1,
			record_change_date=getdate()
	From	#Src
	Inner Join
			dw.fact_transaction TGT
	ON		TGT.transaction_Id=#Src.transaction_Id
			and RN=1
			and __$operation in (1)

	--update
	Update	TGT
	Set		store_key			=#Src.store_key,
			product_key			=#Src.product_key,
			quantity			=#Src.quantity,
			unit_price			=#Src.unit_price,
			transaction_date	=Try_Convert(DateTime,#Src.transaction_date),
			transaction_region	=#Src.transaction_region,
			dq_reason			=#Src.dq_reason,
			is_deleted			=0,
			record_change_date	=getdate(),
			record_status		=CASE when #Src.dq_reason='' then 1 Else 3 End --3 is rejected record
	From	#Src
	Inner Join
			dw.fact_transaction TGT
	ON		TGT.transaction_Id=#Src.transaction_Id
			and RN=1
			and __$operation not in (1)
	Where	checksum(concat(Tgt.store_key,Tgt.product_key,Tgt.quantity, Tgt.unit_price, Tgt.transaction_date, Tgt.transaction_region, Tgt.dq_reason))
			<>
			checksum(concat(#Src.store_key,#Src.product_key,#Src.quantity, #Src.unit_price, #Src.transaction_date, #Src.transaction_region, #Src.dq_reason))

	--insert
	Insert	dw.fact_transaction
	(		transaction_id,
			store_key,
			product_key,
			quantity,
			unit_price,
			transaction_date,
			transaction_region,
			data_src,
			is_deleted,
			dq_reason,
			record_change_date,
			record_status)
	Select	#Src.transaction_id,
			#Src.store_key,
			#Src.product_key,
			#Src.quantity,
			#Src.unit_price,
			Try_Convert(DateTime,#Src.transaction_date),
			#Src.transaction_region,
			0,
			0,
			#Src.dq_reason,
			Getdate(),
			CASE when #Src.dq_reason='' then 1 Else 3 End --3 is rejected record
	From	#Src
	Left Join
			dw.fact_transaction TGT
	ON		TGT.transaction_Id=#Src.transaction_Id
	Where	TGT.transaction_Id is Null
			and __$operation not in (2,4)
    ---- Logging: Procedure End
    --INSERT deng.Procedure_Log
    --SELECT 'DW.load_fact_transaction', 'Proc Ending', 2, GETDATE(), PROGRAM_NAME() Prog_Name, SYSTEM_USER Usr_Name;

END;
