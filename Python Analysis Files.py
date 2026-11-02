from pathlib import Path
import pandas as pd

DATA_PATH = Path(__file__).resolve().parents[1] / "data" / "ecommerce_analytics_dataset.csv"
df = pd.read_csv(DATA_PATH, parse_dates=["Order_Date"])

print("=== DATASET PROFILE ===")
print(f"Rows: {len(df):,}")
print(f"Columns: {len(df.columns)}")
print(f"Date range: {df['Order_Date'].min().date()} to {df['Order_Date'].max().date()}")
print(f"Duplicate Order_IDs: {df['Order_ID'].duplicated().sum()}")
print("\nMissing values by column:")
print(df.isna().sum().sort_values(ascending=False).to_string())

valid = ~df["Order_Status"].isin(["Returned", "Cancelled"])
df["Realized_Revenue"] = df["Net_Sales"].where(valid, 0)
df["Realized_Profit"] = df["Profit"].where(valid, 0)
revenue = df["Realized_Revenue"].sum()
profit = df["Realized_Profit"].sum()

print("\n=== EXECUTIVE KPIs ===")
print(f"Realized revenue: ${revenue:,.2f}")
print(f"Realized profit: ${profit:,.2f}")
print(f"Profit margin: {profit / revenue:.2%}" if revenue else "Profit margin: n/a")
print(f"Unique customers: {df['Customer_ID'].nunique():,}")
print(f"Return rate: {df['Return_Flag'].mean():.2%}")
print(f"Cancellation rate: {df['Cancel_Flag'].mean():.2%}")

print("\n=== TOP CATEGORIES BY REALIZED REVENUE ===")
print(df.groupby("Category")["Realized_Revenue"].sum().sort_values(ascending=False).head(6).to_string())

print("\n=== CHANNEL SUMMARY ===")
print(df.groupby("Acquisition_Channel").agg(
    Revenue=("Realized_Revenue", "sum"),
    Marketing_Spend=("Marketing_Spend", "sum"),
    Profit=("Realized_Profit", "sum"),
).sort_values("Revenue", ascending=False).round(2).to_string())
