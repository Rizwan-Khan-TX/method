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

--- Tests
/*
Include at least the following: - Row count check: 
	clean + quarantine rows should equal total input rows 
	Null check on transaction_id, store_id, unit_price in the clean output 
	Business logic assertion: total_amount == quantity * unit_price for all clean rows
*/