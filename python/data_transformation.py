from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]

RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DATA_DIR = PROJECT_ROOT / "data" / "processed"

PROCESSED_DATA_DIR.mkdir(exist_ok=True)

orders = pd.read_csv(RAW_DATA_DIR / "orders.csv")
customers = pd.read_csv(RAW_DATA_DIR / "customers.csv")
order_items = pd.read_csv(RAW_DATA_DIR / "order_items.csv")
promotions = pd.read_csv(RAW_DATA_DIR / "promotions.csv")

orders["order_date"] = pd.to_datetime(orders["order_date"])
customers["signup_date"] = pd.to_datetime(customers["signup_date"])

orders["order_year"] = orders["order_date"].dt.year
orders["order_month"] = orders["order_date"].dt.month
orders["order_quarter"] = orders["order_date"].dt.quarter
orders["order_day_of_week"] = orders["order_date"].dt.day_name()

order_items["line_sales"] = (
    order_items["qty"] * order_items["price"]
)

sales = order_items.merge(
    orders,
    on="order_id",
    how="left"
)

sales = sales.merge(
    promotions,
    on="promotion_id",
    how="left"
)

sales["gross_sales"] = sales["line_sales"]

sales["discount_amount"] = (
    sales["gross_sales"] * sales["discount"] / 100
)

sales["net_sales"] = (
    sales["gross_sales"] - sales["discount_amount"]
)

orders.to_csv(
    PROCESSED_DATA_DIR / "orders_clean.csv",
    index=False
)

customers.to_csv(
    PROCESSED_DATA_DIR / "customers_clean.csv",
    index=False
)

sales.to_csv(
    PROCESSED_DATA_DIR / "sales_clean.csv",
    index=False
)

print()
print("Processed data saved successfully.")