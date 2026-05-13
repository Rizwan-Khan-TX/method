from pathlib import Path

# --------------------------------------------------
# Base Project Paths
# --------------------------------------------------

base_dir = Path(__file__).resolve().parent

data_dir = base_dir / "data"
output_dir = base_dir / "output"
log_dir = base_dir / "logs"

# --------------------------------------------------
# Input Files
# --------------------------------------------------

transactions_file = data_dir / "transactions.csv"
product_catalog_file = data_dir / "product_catalog.json"
store_metadata_file = data_dir / "store_metadata.csv"

# --------------------------------------------------
# Output Files
# --------------------------------------------------

clean_transactions_file = output_dir / "clean_transactions.csv"
quarantine_file = output_dir / "quarantine_transactions.csv"
dm_transaction_file = output_dir / "dm_transaction.csv"

# --------------------------------------------------
# SQL Server Configuration
# --------------------------------------------------

sql_server = "localhost"
sql_database = "method_2"
sql_driver = "ODBC Driver 17 for SQL Server"

# Windows Authentication
connection_string = (
    f"mssql+pyodbc://@{sql_server}/{sql_database}"
    f"?driver={sql_driver.replace(' ', '+')}"
    "&trusted_connection=yes"
)

# --------------------------------------------------
# Logging
# --------------------------------------------------

log_file = log_dir / "pipeline.log"

# --------------------------------------------------
# Critical Fields for DQ Validation
# --------------------------------------------------

critical_fields = [
    "store_id",
    "product_sku",
    "transaction_quantity",
    "transaction_unit_price",
    "transaction_ts"
]
