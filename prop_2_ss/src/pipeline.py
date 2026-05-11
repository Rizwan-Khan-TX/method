import sys
import os

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
print(parent_dir)
sys.path.append(parent_dir)

import logging
from pathlib import Path

from config import (
    output_dir,
    clean_transactions_file,
    quarantine_file,
    fact_transaction_file
)

from utils import setup_logging
from ingest_data import load_all_data
from tests.validate_data import validate_transactions
from transform_data import transform_transactions
from load_data import load_to_sql_server


def main():

    # --------------------------------------------------
    # Logging Setup
    # --------------------------------------------------

    setup_logging()

    logger = logging.getLogger("__name__")
    logger.info("--START--")
    logger.info(">>>>>>>>>>>>>> Starting retail data pipeline >>>>>>>>>>>>>>>>>>>>>>>")

    # --------------------------------------------------
    # Create Output Directory
    # --------------------------------------------------

    Path(output_dir).mkdir(
        parents=True,
        exist_ok=True
    )

    # --------------------------------------------------
    # Ingestion Layer
    # --------------------------------------------------

    transactions_df, stores_df, products_df = load_all_data()
    
    # --------------------------------------------------
    # Validation Layer
    # --------------------------------------------------

    clean_df, quarantine_df = validate_transactions(
        transactions_df,
        stores_df,
        products_df
    )

    # --------------------------------------------------
    # Transformation Layer
    # --------------------------------------------------

    enriched_df = transform_transactions(
        clean_df,
        stores_df,
        products_df
    )

    # --------------------------------------------------
    # Save CSV Outputs
    # --------------------------------------------------

    clean_df.to_csv(
        clean_transactions_file,
        index=False
    )

    quarantine_df.to_csv(
        quarantine_file,
        index=False
    )

    enriched_df.to_csv(
        fact_transaction_file,
        index=False
    )

    logger.info(">>>>>>>>>>>>>> CSV outputs generated successfully >>>>>>>>>>>>>>>>>>")

    # --------------------------------------------------
    # Load to SQL Server
    # --------------------------------------------------

    load_to_sql_server(
        clean_df,
        quarantine_df,
        enriched_df
    )

    logger.info(">>>>>>>>>>>>>> Retail data pipeline completed successfully >>>>>>>>>")
    logger.info("--END--")


if __name__ == "__main__":
    main()