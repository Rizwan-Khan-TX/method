# Project Structure
prop_1/
├── data/
├── logs/
├── output/
├── src/
├── tests/
├── README.md
├── DECISIONS.md
└── requirements.txt

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

