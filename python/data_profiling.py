from pathlib import Path
import pandas as pd


# Project folders
PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


# Find all CSV files in the raw data folder
csv_files = list(RAW_DATA_DIR.glob("*.csv"))


# Profile each CSV file
for file_path in csv_files:
    df = pd.read_csv(file_path)

    print("=" * 60)
    print(file_path.name)
    print("=" * 60)

    # Basic information
    print("Rows:", len(df))
    print("Columns:", len(df.columns))
    print("Duplicate rows:", df.duplicated().sum())

    # Missing values
    print("\nMissing values:")
    print(df.isna().sum())

    # Data types
    print("\nData types:")
    print(df.dtypes)

    # Possible primary keys
    primary_key_candidates = []

    for column in df.columns:
        if df[column].notna().all() and df[column].nunique() == len(df):
            primary_key_candidates.append(column)

    print("\nPossible primary keys:")

    if primary_key_candidates:
        for key in primary_key_candidates:
            print("-", key)
    else:
        print("- No obvious primary key found")

    print()