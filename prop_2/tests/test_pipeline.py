import sys
import os

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
#print(parent_dir)
sys.path.append(parent_dir)

import pandas as pd

from src.ingest_data import load_all_data
from src.validate_data import validate_transactions
from src.transform_data import transform_transactions


# --------------------------------------------------
# Load Test Data Once
# --------------------------------------------------

transactions_df, stores_df, products_df = load_all_data()

clean_df, quarantine_df = validate_transactions(
    transactions_df,
    stores_df,
    products_df
)

enriched_df = transform_transactions(
    clean_df,
    stores_df,
    products_df
)


# Test 1
# transactions count validation
def test_transactions_counts():

    distinct_transactions = transactions_df['transaction_id'].nunique()
    distinct_cleaned_transactions = clean_df['transaction_id'].nunique()
    distinct_quarantine_transactions = quarantine_df['transaction_id'].nunique()
    total_output_transactions = (
        distinct_cleaned_transactions +
        distinct_quarantine_transactions
    )

    assert distinct_transactions == total_output_transactions


# Test 2
# Null Checks
def test_no_nulls_in_clean_data():

    critical_fields = [
        "transaction_id",
        "store_id",
        "transaction_unit_price"
    ]

    for field in critical_fields:

        assert clean_df[field].isnull().sum() == 0


# Test 3
# Business Logic Validation
def test_total_amount_calculation():

    calculated_total = (
        enriched_df["transaction_quantity"] *
        enriched_df["transaction_unit_price"]
    )

    assert (
        enriched_df["transaction_total_amount"] ==
        calculated_total
    ).all()


# Test 4
# No Duplicate Transaction IDs
def test_no_duplicate_transaction_ids():

    duplicate_count = clean_df[
        "transaction_id"
    ].duplicated().sum()

    assert duplicate_count == 0

# Test 5
# Does quarantine has dq_reason column?
def test_quarantine_has_dq_reason():
    assert "dq_reason" in quarantine_df.columns