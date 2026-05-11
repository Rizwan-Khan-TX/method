import logging
import pandas as pd

logger = logging.getLogger(__name__)

def transform_transactions(clean_df, stores_df, products_df):
    """
    Join and enrich clean transaction data.
    """

    logger.info("Starting transformation layer...")

    # --------------------------------------------------
    # Join Store Metadata
    # --------------------------------------------------

    enriched_df = clean_df.merge(
        stores_df,
        on="store_id",
        how="left"
    )

    # --------------------------------------------------
    # Join Product Catalog
    # --------------------------------------------------

    enriched_df = enriched_df.merge(
        products_df,
        left_on="product_sku",
        right_on="sku",
        how="left"
    )

    # --------------------------------------------------
    # Derived Columns
    # --------------------------------------------------

    enriched_df["total_amount"] = (
        enriched_df["quantity"] *
        enriched_df["unit_price"]
    )

    enriched_df["transaction_date"] = pd.to_datetime(
        enriched_df["transaction_ts"]
    ).dt.date

    # --------------------------------------------------
    # Final Output Columns
    # --------------------------------------------------

    final_df = enriched_df[
        [
            "transaction_id",
            "store_name",
            "city",
            "state",
            "region",
            "product_name",
            "category",
            "supplier_country",
            "quantity",
            "unit_price",
            "total_amount",
            "transaction_date"
        ]
    ]

    logger.info(f"Transformation completed: {len(final_df)} rows")

    return final_df