import logging
import pandas as pd
from config import critical_fields

logger = logging.getLogger(__name__)

# Validate transaction records and create clean/quarantine data frames
def validate_transactions(transactions_df, stores_df, products_df):
    
    
    logger.info("Starting transaction validation...")
    quarantine_frames = []
    working_df = transactions_df.copy()

    
    # Duplicate Transaction IDs
    duplicate_df = working_df[working_df.duplicated(subset=["transaction_id"], keep=False)].copy()
    if not duplicate_df.empty:
        duplicate_df["dq_reason"] = "DUPLICATE_TRANSACTION_ID"
        quarantine_frames.append(duplicate_df)
        working_df = working_df.drop(duplicate_df.index)
         
    # Null / Empty Checks
    for field in critical_fields:
        invalid_df = working_df[working_df[field].isna() |(working_df[field].astype(str).str.strip() == "")].copy()
        if not invalid_df.empty:
            invalid_df["dq_reason"] = f"NULL_OR_EMPTY_{field.upper()}"
            quarantine_frames.append(invalid_df)
            working_df = working_df.drop(invalid_df.index)
    
 
    # Invalid Timestamp
    parsed_ts = pd.to_datetime(working_df["transaction_ts"],errors="coerce")
    invalid_ts_df = working_df[parsed_ts.isna()].copy()
    if not invalid_ts_df.empty:
        invalid_ts_df["dq_reason"] = "INVALID_TRANSACTION_TIMESTAMP"
        quarantine_frames.append(invalid_ts_df)
        working_df = working_df.drop(invalid_ts_df.index)
         
    # Invalid Store IDs
    valid_store_ids = set(stores_df["store_id"])
    invalid_store_df = working_df[~working_df["store_id"].isin(valid_store_ids)].copy()
    if not invalid_store_df.empty:
        invalid_store_df["dq_reason"] = "INVALID_STORE_ID"
        quarantine_frames.append(invalid_store_df)
        working_df = working_df.drop(invalid_store_df.index)
        
    # Invalid Product SKU
    valid_skus = set(products_df["product_sku"])
    invalid_product_df = working_df[~working_df["product_sku"].isin(valid_skus)].copy()
    if not invalid_product_df.empty:
        invalid_product_df["dq_reason"] = "INVALID_PRODUCT_SKU"
        quarantine_frames.append(invalid_product_df)
        working_df = working_df.drop(invalid_product_df.index)
        
    # Negative Quantity
    negative_qty_df = working_df[working_df["transaction_quantity"] <= 0].copy()
    if not negative_qty_df.empty:
        negative_qty_df["dq_reason"] = "INVALID_QUANTITY"
        quarantine_frames.append(negative_qty_df)
        working_df = working_df.drop(negative_qty_df.index)
        
    # Negative Unit Price
    negative_price_df = working_df[working_df["transaction_unit_price"] <= 0].copy()
    if not negative_price_df.empty:
        negative_price_df["dq_reason"] = "INVALID_UNIT_PRICE"
        quarantine_frames.append(negative_price_df)
        working_df = working_df.drop(negative_price_df.index)

    
    # sort workking_df by transaction_id
    working_df = working_df.sort_values(by='transaction_id')
    
    # create quarantie df and order by transaction_id
    if quarantine_frames:
        quarantine_df = pd.concat(
            quarantine_frames,
            ignore_index=True
        )
    else:
        quarantine_df = pd.DataFrame()
    quarantine_df=quarantine_df.sort_values(by='transaction_id')

    # get count of unique transactions that are in quarantine
    logger.info(f"Clean records: {len(working_df)}")
    logger.info(f"Quarantined records: {len(quarantine_df)}")
    
    # return DFs
    return working_df, quarantine_df