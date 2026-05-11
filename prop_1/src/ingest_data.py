import json
import logging
import pandas as pd

from config import (
    transactions_file,
    product_catalog_file,
    store_metadata_file
)

# --------------------------------------------------
# Configure Logger
# --------------------------------------------------

logger = logging.getLogger(__name__)

# --------------------------------------------------
# Load Transactions
# --------------------------------------------------

def load_transactions():
    # --------------------------------------------------
    # Load transactions CSV file into pandas DataFrame.
    # --------------------------------------------------

    try:
        logger.info("Loading transactions data...")

        df = pd.read_csv(transactions_file)

        logger.info(f"Transactions loaded successfully: {len(df)} rows")

        return df

    except Exception as e:
        logger.error(f"Failed to load transactions file: {e}")
        raise

# --------------------------------------------------
# Load Store Metadata
# --------------------------------------------------

def load_store_metadata():
    # ----------------------------------------------------
    # Load store metadata CSV file into pandas DataFrame.
    # ----------------------------------------------------
    try:
        logger.info("Loading store metadata...")

        df = pd.read_csv(store_metadata_file)

        logger.info(f"Store metadata loaded successfully: {len(df)} rows")

        return df

    except Exception as e:
        logger.error(f"Failed to load store metadata file: {e}")
        raise

# -------------------------------------------------------------
# Load Product Catalog
# -------------------------------------------------------------

def load_product_catalog():
    # ------------------------------------------------------------- 
    # Load nested JSON product catalog and flatten supplier fields.
    # -------------------------------------------------------------
    try:
        logger.info("Loading product catalog...")

        with open(product_catalog_file, "r") as file:
            products = json.load(file)

        # Flatten nested supplier object
        flattened_products = []

        for product in products:

            flattened_product = {
                "sku": product.get("sku"),
                "product_name": product.get("product_name"),
                "category": product.get("category"),
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

# --------------------------------------------------
# Master Ingestion Function
# --------------------------------------------------

def load_all_data():
    # --------------------------------------------------
    # Load all source datasets.
    # --------------------------------------------------
    transactions_df = load_transactions()
    stores_df = load_store_metadata()
    products_df = load_product_catalog()

    return transactions_df, stores_df, products_df