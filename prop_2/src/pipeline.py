import sys
import os

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
#print(parent_dir)
sys.path.append(parent_dir)

import logging
from pathlib import Path

from config import (
    output_dir,
    clean_transactions_file,
    quarantine_file,
    dm_transaction_file
)

from utils import setup_logging
from ingest_data import load_all_data
from validate_data import validate_transactions
from transform_data import transform_transactions
from load_data import load_transaction_df,load_raw_df

def main():
    # Logging Setup
    setup_logging()

    logger = logging.getLogger("__name__")
    logger.info("--START--")
    logger.info(">>>>>>>>>>>>>> Starting retail data pipeline >>>>>>>>>>>>>>>>>>>>>>>")

    # Create Output Directory
    Path(output_dir).mkdir(
        parents=True,
        exist_ok=True
    )

    # load all data get dataframes back
    transactions_df, stores_df, products_df = load_all_data()
    
    # validate transaction
    clean_df, quarantine_df = validate_transactions(
        transactions_df,
        stores_df,
        products_df
    )

    # transforma and join dataframes
    enriched_df = transform_transactions(
        clean_df,
        stores_df,
        products_df
    )

    # convert df to CSVs
    clean_df.to_csv(
        clean_transactions_file,
        index=False
    )
    quarantine_df.to_csv(
        quarantine_file,
        index=False
    )
    enriched_df.to_csv(
        dm_transaction_file,
        index=False
    )

    logger.info(">>>>>>>>>>>>>> CSV outputs generated successfully >>>>>>>>>>>>>>>>>>")

    # Now load dfs to SQL Server
    load_transaction_df(
        clean_df,
        quarantine_df,
        enriched_df
    )

    load_raw_df(
        stores_df,
        'stg_stores_raw'
    )
    
    load_raw_df(
        products_df,
        'stg_products_raw'
    )
    
    load_raw_df(
        transactions_df,
        'stg_transactions_raw'
    )

    logger.info(">>>>>>>>>>>>>> Retail data pipeline completed successfully >>>>>>>>>")
    logger.info("--END--")

if __name__ == "__main__":
    main()