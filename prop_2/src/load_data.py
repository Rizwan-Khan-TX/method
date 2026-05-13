import logging
from sqlalchemy import create_engine
from config import connection_string

logger = logging.getLogger(__name__)

# Load datasets into SQL Server tables.
def load_transaction_df(clean_df, quarantine_df, enriched_df):
    logger.info("Connecting to SQL Server...")
    engine = create_engine(connection_string)
    try:
        logger.info("Loading clean_transactions table...")
        clean_df.to_sql(
            "clean_transactions",
            engine,
            if_exists="replace",
            index=False
        )

        logger.info("Loading quarantine_transactions table...")
        quarantine_df.to_sql(
            "quarantine_transactions",
            engine,
            if_exists="replace",
            index=False
        )

        logger.info("Loading dm_transaction table...")
        enriched_df.to_sql(
            "dm_transaction",
            engine,
            if_exists="replace",
            index=False
        )

        logger.info("SQL Server load completed successfully.")

    except Exception as e:
        logger.error(f"Failed loading data to SQL Server: {e}")
        raise  

def load_raw_df(raw_df,tbl_name):
    logger.info(f"Connecting to SQL Server for :  {tbl_name}...")
    engine = create_engine(connection_string)
    try:
        logger.info(f"Loading raw : {tbl_name}")
        raw_df.to_sql(
            tbl_name,
            engine,
            if_exists="replace",
            index=False
        )

        logger.info(f"Load for :  {tbl_name} completed...")

    except Exception as e:
        logger.error(f"Load failed for : {tbl_name} Server: {e}")
        raise  