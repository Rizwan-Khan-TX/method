import logging
import pandas as pd

logger = logging.getLogger(__name__)

# join and clean transaction data.
def transform_transactions(clean_df, stores_df, products_df):
    
    logger.info("Starting transformation layer...")

    # Join Store Metadata
    enriched_df = clean_df.merge(
        stores_df,
        on="store_id",
        how="left"
    )

    # Join Product Catalog
    enriched_df = enriched_df.merge(
        products_df,
        left_on="product_sku",
        right_on="product_sku",
        how="left"
    )

    # Derived Columns
    enriched_df["transaction_total_amount"] = (
        enriched_df["transaction_quantity"] *
        enriched_df["transaction_unit_price"]
    )

    enriched_df["transaction_date"] = pd.to_datetime(enriched_df["transaction_ts"]).dt.date

    # Final Output Columns
    final_df = enriched_df[
        [
            "transaction_id",
            "store_id",
            "store_name",
            "store_city",
            "store_state",
            "store_opened_date",
            "product_sku",
            "product_name",
            "product_category",
            "supplier_id",
            "supplier_name",
            "supplier_country",
            "transaction_quantity",
            "transaction_unit_price",
            "transaction_region",
            "transaction_total_amount",
            "transaction_date"
        ]
    ]

    logger.info(f"Transformation completed: {len(final_df)} rows")
    return final_df