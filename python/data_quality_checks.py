from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

customers = pd.read_csv(RAW_DATA_DIR / "customers.csv")
orders = pd.read_csv(RAW_DATA_DIR / "orders.csv")
stores = pd.read_csv(RAW_DATA_DIR / "stores.csv")
order_items = pd.read_csv(RAW_DATA_DIR / "order_items.csv")
products = pd.read_csv(RAW_DATA_DIR / "products.csv")
categories = pd.read_csv(RAW_DATA_DIR / "categories.csv")
suppliers = pd.read_csv(RAW_DATA_DIR / "suppliers.csv")

def check_foreign_key(child_df, child_column, parent_df, parent_column):
    invalid_rows = child_df[
        ~child_df[child_column].isin(parent_df[parent_column])
    ]

    if len(invalid_rows) == 0:
        status = "PASS"
    else:
        status = "FAIL"

    print(
        f"{status}: {child_column} → {parent_column} "
        f"({len(invalid_rows)} invalid rows)"
    )

check_foreign_key(
    orders,
    "customer_id",
    customers,
    "customer_id",
   
)

check_foreign_key(
    orders,
    "store_id",
    stores,
    "store_id"
)

check_foreign_key(
    order_items,
    "order_id",
    orders,
    "order_id"
)

check_foreign_key(
    order_items,
    "product_id",
    products,
    "product_id"
)

check_foreign_key(
    products,
    "category_id",
    categories,
    "category_id"
)

check_foreign_key(
    products,
    "supplier_id",
    suppliers,
    "supplier_id"
)