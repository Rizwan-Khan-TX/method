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
│   ├── enriched_fact.csv
│   ├── quarantine_transactions.csv
│   └── readme.md (just a placeholder)
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

# requirements
please review requirements.txt to setup your instance, import required libraries/RDBMS

# Run pipeline from root
python src\pipeline.py

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
 ┌──┴──────────────┐
 ▼                 ▼
Clean Data     Quarantine Data
    │
    ▼
Transformation Layer
(join + enrichment)
    │
    ▼
SQL Server Serving Layer

```

