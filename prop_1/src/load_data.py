import logging
from sqlalchemy import create_engine
from config import connection_string

logger = logging.getLogger(__name__)

def load_to_sql_server(clean_df, quarantine_df, enriched_df):
    # --------------------------------------------------
    # Load datasets into SQL Server tables.
    # --------------------------------------------------
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

        logger.info("Loading fact_transaction table...")

        enriched_df.to_sql(
            "fact_transaction",
            engine,
            if_exists="replace",
            index=False
        )

        logger.info("SQL Server load completed successfully.")

    except Exception as e:
        logger.error(f"Failed loading data to SQL Server: {e}")
        raise