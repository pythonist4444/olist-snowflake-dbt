import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from dotenv import load_dotenv
from pathlib import Path
from datetime import datetime, timezone

load_dotenv()

# ── Config ────────────────────────────────────────────────────────────────────
SNOWFLAKE_CONFIG = {
    "account":   os.getenv("SNOWFLAKE_ACCOUNT"),
    "user":      os.getenv("SNOWFLAKE_USER"),
    "password":  os.getenv("SNOWFLAKE_PASSWORD"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
    "database":  os.getenv("SNOWFLAKE_DATABASE"),
    "schema":    os.getenv("SNOWFLAKE_SCHEMA"),
}

DATA_DIR = Path(__file__).parent.parent / "data" / "raw"

# Maps CSV filename → Snowflake table name
CSV_TABLE_MAP = {
    "olist_orders_dataset.csv":                    "ORDERS",
    "olist_order_items_dataset.csv":               "ORDER_ITEMS",
    "olist_order_payments_dataset.csv":            "ORDER_PAYMENTS",
    "olist_order_reviews_dataset.csv":             "ORDER_REVIEWS",
    "olist_customers_dataset.csv":                 "CUSTOMERS",
    "olist_sellers_dataset.csv":                   "SELLERS",
    "olist_products_dataset.csv":                  "PRODUCTS",
    "olist_geolocation_dataset.csv":               "GEOLOCATION",
    "product_category_name_translation.csv":       "PRODUCT_CATEGORY_NAME_TRANSLATION",
}

# ── Helpers ───────────────────────────────────────────────────────────────────
def get_connection():
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    print(f"✅ Connected to Snowflake — {SNOWFLAKE_CONFIG['account']}")
    return conn


def snowflake_type(dtype) -> str:
    """Map a pandas dtype to a Snowflake column type."""
    if pd.api.types.is_integer_dtype(dtype):
        return "NUMBER"
    if pd.api.types.is_float_dtype(dtype):
        return "FLOAT"
    return "VARCHAR"


def create_table(cursor, table_name: str, df: pd.DataFrame):
    """Drop and recreate the table based on the DataFrame schema."""
    cols = ",\n  ".join(
        f'"{col.upper()}" {snowflake_type(dtype)}'
        for col, dtype in df.dtypes.items()
    )
    ddl = f"""
    CREATE OR REPLACE TABLE {table_name} (
      {cols},
      _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
    );
    """
    cursor.execute(ddl)
    print(f"   ↳ Table {table_name} created")


def load_csv(conn, csv_path: Path, table_name: str):
    print(f"\n📂 Loading {csv_path.name} → {table_name}")

    df = pd.read_csv(csv_path, dtype=str)  # load everything as str first
    df.columns = [c.upper() for c in df.columns]

    # Add audit timestamp
    # df["_LOADED_AT"] = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    print(f"   ↳ {len(df):,} rows · {len(df.columns)} columns")

    with conn.cursor() as cur:
        cur.execute(f"USE SCHEMA {SNOWFLAKE_CONFIG['database']}.{SNOWFLAKE_CONFIG['schema']}")
        create_table(cur, table_name, df)

    success, nchunks, nrows, _ = write_pandas(
        conn,
        df,
        table_name,
        database=SNOWFLAKE_CONFIG["database"],
        schema=SNOWFLAKE_CONFIG["schema"],
        auto_create_table=False,
        overwrite=False,
    )

    if success:
        print(f"   ✅ {nrows:,} rows written in {nchunks} chunk(s)")
    else:
        print(f"   ❌ Load failed for {table_name}")


def verify_counts(conn):
    """Print row counts for all loaded tables."""
    print("\n── Verification ─────────────────────────────────────────")
    with conn.cursor() as cur:
        for table in CSV_TABLE_MAP.values():
            try:
                cur.execute(
                    f"SELECT COUNT(*) FROM {SNOWFLAKE_CONFIG['database']}"
                    f".{SNOWFLAKE_CONFIG['schema']}.{table}"
                )
                count = cur.fetchone()[0]
                print(f"   {table:<45} {count:>10,} rows")
            except Exception as e:
                print(f"   {table:<45} ERROR: {e}")


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    print("=" * 60)
    print("  Olist → Snowflake RAW ingestion")
    print(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    # Validate data directory
    if not DATA_DIR.exists():
        raise FileNotFoundError(f"Data directory not found: {DATA_DIR}")

    conn = get_connection()

    try:
        for csv_file, table_name in CSV_TABLE_MAP.items():
            csv_path = DATA_DIR / csv_file
            if not csv_path.exists():
                print(f"\n⚠️  Skipping {csv_file} — file not found")
                continue
            load_csv(conn, csv_path, table_name)

        verify_counts(conn)

    finally:
        conn.close()
        print("\n🔒 Connection closed")
        print("=" * 60)


if __name__ == "__main__":
    main()