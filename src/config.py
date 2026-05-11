from pathlib import Path

PYTHONDONTWRITEBYTECODE=1

# --------------------------------------------------
# Base Project Paths
# --------------------------------------------------

base_dir = Path(__file__).resolve().parent.parent

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
fact_transaction_file = output_dir / "fact_transaction.csv"

# --------------------------------------------------
# SQL Server Configuration
# --------------------------------------------------

sql_server = "localhost"
sql_database = "method"
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
    "unit_price",
    "transaction_ts"
]

#SQL Connection 
srvr = "Riz-Music"
db = "method"
driver = "ODBC Driver 17 for SQL Server"

conn_str = (
    f"Driver={driver};"
    f"Server={srvr};"
    f"Database={db};"
    "Trusted_Connection=yes;" # For Windows Authentication
)
#conn = pyodbc.connect(conn_str)
#cursor = conn.cursor()
#cursor.execute("SELECT Getdate();")
#row = cursor.fetchone()
#print(row[0])

# critical_tests = [
    # "store_id",
    # "product_sku",
    # "unit_price",
    # "transaction_ts"
# ]