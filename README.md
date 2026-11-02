# Advanced E-Commerce Analytics | Python + MySQL + Power BI

An end-to-end portfolio project analyzing e-commerce sales, product profitability, customer activity, acquisition channels, geography, discounts, returns, cancellations, devices, and payment methods.

## Project at a glance
- **Dataset:** 15,000 synthetic order records
- **Period:** 2024-01-01 to 2025-12-31
- **Tools:** Python (Pandas, NumPy), MySQL 8.0+, Power BI
- **Files:** CSV dataset and MySQL schema/analysis queries
- **Important:** This is synthetic sample data created for portfolio demonstration, not real customer or company data.

## Business questions
1. How are revenue and profit changing month over month?
2. Which categories and products contribute most to revenue and profit?
3. Which acquisition channels generate sales relative to marketing spend?
4. Which countries and regions perform best?
5. How much revenue is associated with returned and cancelled orders?
6. How do device and payment preferences vary?
7. What are the order and customer trends over time?

## Dataset columns
`Order_ID`, `Order_Date`, `Customer_ID`, `Country`, `Region`, `Category`, `Product`, `Quantity`, `Unit_Price`, `Gross_Sales`, `Discount_Rate`, `Discount_Amount`, `Net_Sales`, `Unit_Cost`, `COGS`, `Shipping_Cost`, `Marketing_Spend`, `Profit`, `Payment_Method`, `Acquisition_Channel`, `Campaign`, `Device`, `Order_Status`, `Return_Flag`, `Cancel_Flag`, `Sessions`.

## Suggested workflow
1. Import `data/ecommerce_analytics_dataset.csv` into MySQL using MySQL Workbench's **Table Data Import Wizard**, selecting `ecommerce_orders` as the target table after running the `CREATE TABLE` script.
2. Run `sql/ecommerce_analytics_queries.sql` in MySQL Workbench. Execute the database/table setup first, import the CSV, then run validation queries, analysis queries, and views.
3. Use Power BI **Get Data → MySQL database** (or import the CSV for a no-connector setup). Connect to `ecommerce_analytics_db` and load `vw_ecommerce_order_detail`, `vw_ecommerce_monthly`, and `vw_ecommerce_channel`, or load the base table.
4. Create a date table and relationships where appropriate. Add slicers for date, country, category, acquisition channel, device, and order status.
5. Validate totals between Power BI and SQL before publishing screenshots.

## Power BI report pages
1. **Executive Overview** — Revenue, Profit, Orders, Customers, Return Rate, Cancellation Rate; monthly revenue/profit trend.
2. **Sales & Profitability** — Category and product performance, profit margin, discount analysis.
3. **Marketing & Channel ROI** — Revenue, marketing spend, revenue-to-spend ratio, campaign and channel ranking.
4. **Customer & Geography** — unique customers, revenue by country/region, customer purchase trends.
5. **Order Quality** — returned/cancelled orders, status mix, device and payment analysis.

## Core metric definitions
- **Realized Revenue:** Net sales from orders not marked Returned or Cancelled.
- **Realized Profit:** profit from orders not marked Returned or Cancelled.
- **Return Rate:** returned order records / all order records.
- **Cancellation Rate:** cancelled order records / all order records.
- **Revenue-to-Spend Ratio:** realized revenue / marketing spend. This is **not** a causal or platform-attributed ROAS measure; spend is synthetic order-level sample data.
- **Profit Margin:** realized profit / realized revenue.

## Business insights
Run the SQL analysis queries and use the actual output to write evidence-based findings. Do not claim a category, country, or channel is the best performer until you verify the query results. Use this format:
- **Finding:** [metric and period from the report]
- **Why it matters:** [commercial interpretation]
- **Recommended action:** [specific next step]
- **Measure success by:** [KPI to monitor]

## Python extension
Use Pandas to profile the CSV, check missing values and duplicates, calculate KPI summaries, and export cleaned data. Keep the SQL and Power BI totals aligned. Python is included as the data preparation/QA layer in this starter package; the included files are the dataset and SQL queries.

## Repository structure
```text
ecommerce-analytics-portfolio/
├── data/
│   └── ecommerce_analytics_dataset.csv
├── sql/
│   └── ecommerce_analytics_queries.sql
├── python/
│   └── (add your Python profiling/cleaning script here)
├── powerbi/
│   └── (add your .pbix file here)
├── screenshots/
│   └── (add exported dashboard page images here)
└── README.md
```

## Limitations
- Data is synthetic and designed for practice, not forecasting or real-world causal conclusions.
- `Marketing_Spend` is generated per order record. Treat channel efficiency as a demonstration metric, not a true ad-platform attribution result.
- `Profit` is an illustrative row-level estimate based on realized sales less cost of goods, shipping, and marketing spend.

## Author
Add your name, portfolio link, and LinkedIn profile here.
