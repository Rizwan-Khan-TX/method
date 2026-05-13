# Project Structure

prop_1/
│
├── data/
│   ├── product_catalog.json
│   ├── store_metadata.csv
│   └── transactions.csv
│
├── logs/
│   └── readme.md (just a placeholder)
│
├── output/
│   ├── clean_transactions.csv
│   ├── dm_transaction.csv
│   ├── quarantine_transactions.csv
│   └── readme.md (just a placeholder)
│
├── sql/
│   ├──procs
│      ├── load_dim_product.sql
│      ├── load_dim_store.sql
│      ├── load_dim_supplier.sql
│      ├── load_fact_transaction.sql
│       
│   ├──tables
│      ├── dim_product.sql
│      ├── dim_store.sql
│      ├── dim_supplier.sql
│      ├── fact_transaction.sql
│      ├── lkup_date.sql
│
├── src/
│   ├── ingest.py
│   ├── load_data.py
│   ├── pipeline.py
│   ├── transform_data.py
│   ├── utils.py
│   └── validate.py
│
├── tests/
│   └── test_pipeline.py
│
├── config.py
├── decisons.md
├── readme.md
└── requirements.txt
<img width="1166" height="942" alt="image" src="https://github.com/user-attachments/assets/4fd8c354-9197-4722-90aa-65d95802c7cc" />

# requirements
please review requirements.txt to setup your instance, import required libraries & install RDBMS

# Run pipeline from root
python src\pipeline.py

# Create SQL tables DB
	execute scripts in `sql\tables` folder on DB {couldnt automate due to time constraints}
# Run SQL store procs from DB 
	{couldnt automate due to time constraints}
	`exec dw.load_dim_store;`
	`exec dw.load_dim_supplier;`
	`exec dw.load_dim_product;`
	`exec dw.load_fact_transaction;`

# Run tests from root
python -m pytest

# Retail Data Pipeline Assessment
## Overview

This project implements a lightweight retail data pipeline that ingests, validates, transforms, and serves retail transaction data from multiple source systems.

The pipeline processes the following source datasets:

- `transactions.csv`
- `product_catalog.json`
- `store_metadata.csv`

The solution was intentionally designed using a modular layered approach to separate:

1. Ingestion
2. Data quality validation
3. Transformation/enrichment
4. Analytical serving
5. load raw data in SQL server
6. create DW (dim/facts) along with SCD2 and soft delete approach
	i. did not reject any records, instead provided `dq_reason` in fact table for DAs to make a call on record usage instead of deciding for them
	ii. in real world I would not create dq_reason column, but instead create a `bitwise` approach with a lkup table to provide text for dq_reason

The implementation focuses on:
- readability
- maintainability
- data quality handling
- operational transparency

rather than heavy framework usage or distributed infrastructure.

---

# Architecture Overview

```text
Source Files
    │
    ▼
Ingestion Layer
(pandas loaders)
    │
    ▼
Validation Layer
- null checks
- duplicate checks
- timestamp validation
- referential integrity checks
- anomaly detection
    │
 ┌──┴──────────────┐──────────────────────┐
 ▼                 ▼                      ▼  
Clean Data     Quarantine Data         RAW Data
    │			   │					  │	
	│			   │                      │
	│			   ▼                      ▼                      
	│          SQL Server             SQL Server(DW)
	│
    ▼
Transformation Layer
(join + enrichment)
    │
    ▼
SQL Server Serving Layer
    │
    ▼
SQL Scripts for Analysis	

```

