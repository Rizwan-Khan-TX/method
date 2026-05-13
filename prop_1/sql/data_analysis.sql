use method
--**a. Daily revenue by region**
Select	transaction_date=transaction_date,
		region			=transaction_region,
		total_amount	=sum(transaction_total_amount),
		Cnt				=count(*)
from	dm_transaction
Group by
		transaction_date,
		transaction_region

--**b. Top 10 products by total quantity sold**
;With DT as (
	Select	product_sku		=IsNull(product_sku,'missing product sku'),
			product_name	=IsNull(product_name,'missing product'),
			RNK				=Rank() Over ( order by sum(transaction_total_amount) desc),
			total_amount	=sum(transaction_total_amount) 
	from	dm_transaction
	group by
			product_sku,
			product_name)
Select	*	 
from	DT
Where	RNK<11

--**c. Data quality summary by store**
;With A as (
	select	distinct
			store_id	=coalesce(t.store_id,s.store_id),
			store_name	=coalesce(s.store_name,'N/A'),
			t.transaction_id,
			dq_reason
	from	stg_transactions_raw t
	left join
			stg_stores_raw s
	on		t.store_id=s.store_id
	outer apply
			(	Select  string_agg(dq_reason,',')  dq_reason
				From	quarantine_transactions qt
				Where	qt.transaction_id=t.transaction_id) as qt)
Select	store_id,
		store_name,
		total_transactions		=count(transaction_id),
		flagged_transactions	=count(dq_reason),
		flag_rate_pct			=((count(dq_reason)*1.0)/count(transaction_id))*100
From	A
Group By
		store_id,
		store_name		

--Include stores where flag_rate_pct &gt; 10% in a separate view or filter.
Drop view if exists v_Store_Data_Quality
Go
Create view v_Store_Data_Quality
as
With A as (
	select	distinct
			store_id	=coalesce(t.store_id,s.store_id),
			store_name	=coalesce(s.store_name,'N/A'),
			t.transaction_id,
			dq_reason
	from	stg_transactions_raw t
	left join
			stg_stores_raw s
	on		t.store_id=s.store_id
	outer apply
			(	Select  string_agg(dq_reason,',')  dq_reason
				From	quarantine_transactions qt
				Where	qt.transaction_id=t.transaction_id) as qt)
Select	store_id,
		store_name,
		total_transactions		=count(transaction_id),
		flagged_transactions	=count(dq_reason),
		flag_rate_pct			=((count(dq_reason)*1.0)/count(transaction_id))*100
From	A
Group By
		store_id,
		store_name	
Having	(((count(dq_reason)*1.0)/count(transaction_id))*100)>10
;
Go
--- Tests
/*
Include at least the following: - Row count check: 
*/
--	clean + quarantine rows should equal total input rows 
Select	[total_input_rows]	= (Select	count(*) from	stg_transactions_raw),
		[clean_rows]		= (Select	count(*) from	clean_transactions),
		[quarantine_rows]	= (Select	count(*) from	quarantine_transactions)

--	Null check on transaction_id, store_id, unit_price in the clean output 
;With A0 as (
	Select	transaction_id,
			dq_reason='DUPLICATE_TRANSACTION_ID'
	from	stg_transactions_raw 
	Group by
			transaction_id
	Having count(*)>1)
,A as (
	Select	T.transaction_id,
			dq_reason=Replace(
			Case When IsNull(T.transaction_id,'')='' then 'NULL_OR_EMPTY_TRANSACTION_ID' Else '' End+' '+
			Case When IsNull(store_id,'')='' then 'NULL_OR_EMPTY_STORE_ID' Else '' End+' '+
			Case When (Convert(Int,transaction_quantity) is Null or  Convert(Int,transaction_quantity)<0)  then ' NULL_OR_EMPTY_TRANSACTION_QUANTITY' Else '' End+' '+
			Case When IsNull(transaction_unit_price,'')='' then ' NULL_OR_EMPTY_TRANSACTION_UNIT_PRICE' Else '' End+' '+
			Case When ISDATE(transaction_ts)=0 then 'INVALID_TRANSACTION_TIMESTAMP' Else '' End+' ','  ','')
	from	stg_transactions_raw T
	Where	(IsNull(T.transaction_id,'')=''
			or IsNull(store_id,'')=''
			or Convert(Int,transaction_quantity) is Null or  Convert(Int,transaction_quantity)<0 
			or IsNull(transaction_unit_price,'')=''
			or ISDATE(transaction_ts)=0) 
			)
,B as(--- Check stores missing from Store.csv
	Select	T.transaction_id,
			dq_reason	=	'INVALID_STORE_ID'
	from	stg_transactions_raw t
	Left Join
			stg_stores_raw s
	ON		t.store_id=s.store_id
	Where	s.store_id is Null 
	)
,C as(--- Check Products missing from product.csv
	Select	T.transaction_id,
			dq_reason	=	'INVALID_PRODUCT_SKU'
	from	stg_transactions_raw t
	Left Join
			stg_products_raw p
	ON		t.product_sku=p.product_sku
	Where	p.product_sku is Null 
),
Final as (
	Select * from A0
	union
	Select * from A
	Union
	Select * from B
	Union
	Select * from C)
Select	T.*,
		Final.dq_reason
from	stg_transactions_raw T
Cross Apply
(		Select  STRING_AGG(dq_reason,',') dq_reason
		From	Final
		Where Final.transaction_id=T.transaction_id) Final
Where	Final.dq_reason is Not Null
Order by 1
