With A as (
SELECT *
FROM OPENROWSET(
    BULK 'C:\Users\rijib\OneDrive\Documents\Method\data\transactions.csv', 
	FIRSTROW = 2,            -- Skips the header row
	FORMATFILE = 'C:\Users\rijib\OneDrive\Documents\Method\data\transaction_format.xml'
) as D
)
Select	* ,'NULL_OR_EMPTY_UNIT_PRICE' rsn
from	A
Where	Unit_price is Null
Union
Select	* ,'DUPLICATE_TRANSACTION_ID' rsn
from	A 
Where	Transaction_id  in (
		Select	Transaction_id 
		from	A
		group by
				Transaction_id
		Having Count(*)>1)
Union
Select	*,'INVALID_TRANSACTION_TIMESTAMP' Rns 
from	A
Where	isdate(transaction_ts)=0
order by 1