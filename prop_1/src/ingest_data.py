import json
import logging
import pandas as pd

from config import (
    transactions_file,
    product_catalog_file,
    store_metadata_file
)

# Configure Logger
logger = logging.getLogger(__name__)

# Load transactions CSV file into pandas DataFrame.
def load_transactions():
    try:
        logger.info("Loading transactions data...")
        df = pd.read_csv(transactions_file)
        logger.info(f"Transactions loaded successfully: {len(df)} rows")
        return df

    except Exception as e:
        logger.error(f"Failed to load transactions file: {e}")
        raise

# Load store metadata CSV file into pandas DataFrame.
def load_store_metadata():
    try:
        logger.info("Loading store metadata...")
        df = pd.read_csv(store_metadata_file)
        logger.info(f"Store metadata loaded successfully: {len(df)} rows")
        return df

    except Exception as e:
        logger.error(f"Failed to load store metadata file: {e}")
        raise

# Load nested JSON product catalog and flatten supplier fields.
def load_product_catalog():
    try:
        logger.info("Loading product catalog...")
        with open(product_catalog_file, "r") as file:
            products = json.load(file)

        # Flatten nested supplier object
        flattened_products = []
        for product in products:
            flattened_product = {
                "product_sku": product.get("sku"),
                "product_name": product.get("product_name"),
                "product_category": product.get("category"),
                "supplier_id": product.get("supplier", {}).get("id"),
                "supplier_name": product.get("supplier", {}).get("name"),
                "supplier_country": product.get("supplier", {}).get("country")
            }
            flattened_products.append(flattened_product)

        df = pd.DataFrame(flattened_products)
        logger.info(f"Product catalog loaded successfully: {len(df)} rows")
        return df

    except Exception as e:
        logger.error(f"Failed to load product catalog file: {e}")
        raise

# Load all source datasets.
def load_all_data():
    transactions_df = load_transactions()
    # rename columns 
    transactions_df = transactions_df.rename(columns={"quantity": "transaction_quantity", "unit_price": "transaction_unit_price", "region": "transaction_region"})
    
    stores_df = load_store_metadata()
    # rename columns 
    stores_df = stores_df.rename(columns={"city": "store_city", "state": "store_state", "opened_date": "store_opened_date"})
    
    products_df = load_product_catalog()
    return transactions_df, stores_df, products_df
