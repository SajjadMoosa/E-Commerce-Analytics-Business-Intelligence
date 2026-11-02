-- E-Commerce Analytics Portfolio Project
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS ecommerce_analytics_db;
USE ecommerce_analytics_db;

-- Import ecommerce_analytics_dataset.csv into this table using MySQL Workbench
-- Table Data Import Wizard, or create the table first using the schema below.
DROP TABLE IF EXISTS ecommerce_orders;
CREATE TABLE ecommerce_orders (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Country VARCHAR(80),
    Region VARCHAR(100),
    Category VARCHAR(80),
    Product VARCHAR(120),
    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Gross_Sales DECIMAL(14,2),
    Discount_Rate DECIMAL(5,2),
    Discount_Amount DECIMAL(14,2),
    Net_Sales DECIMAL(14,2),
    Unit_Cost DECIMAL(12,2),
    COGS DECIMAL(14,2),
    Shipping_Cost DECIMAL(12,2),
    Marketing_Spend DECIMAL(14,2),
    Profit DECIMAL(14,2),
    Payment_Method VARCHAR(50),
    Acquisition_Channel VARCHAR(50),
    Campaign VARCHAR(100),
    Device VARCHAR(30),
    Order_Status VARCHAR(30),
    Return_Flag TINYINT,
    Cancel_Flag TINYINT,
    Sessions INT,
    INDEX idx_order_date (Order_Date),
    INDEX idx_customer (Customer_ID),
    INDEX idx_country (Country),
    INDEX idx_channel (Acquisition_Channel),
    INDEX idx_category (Category)
);

-- Validation
SELECT COUNT(*) AS total_rows, MIN(Order_Date) AS first_order, MAX(Order_Date) AS last_order
FROM ecommerce_orders;

-- 1. Executive KPI summary (realized sales exclude returns and cancellations)
SELECT
  ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS realized_revenue,
  ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END),2) AS realized_profit,
  COUNT(*) AS total_order_records,
  COUNT(DISTINCT Customer_ID) AS unique_customers,
  ROUND(100.0*SUM(Return_Flag)/COUNT(*),2) AS return_rate_pct,
  ROUND(100.0*SUM(Cancel_Flag)/COUNT(*),2) AS cancellation_rate_pct
FROM ecommerce_orders;

-- 2. Monthly revenue and profit trend
SELECT DATE_FORMAT(Order_Date,'%Y-%m') AS month,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS revenue,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END),2) AS profit
FROM ecommerce_orders
GROUP BY DATE_FORMAT(Order_Date,'%Y-%m')
ORDER BY month;

-- 3. Category performance
SELECT Category,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS revenue,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END),2) AS profit,
       SUM(Quantity) AS units_sold
FROM ecommerce_orders
GROUP BY Category ORDER BY revenue DESC;

-- 4. Acquisition channel efficiency
SELECT Acquisition_Channel,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS revenue,
       ROUND(SUM(Marketing_Spend),2) AS marketing_spend,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END) /
         NULLIF(SUM(Marketing_Spend),0),2) AS revenue_to_spend_ratio,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END),2) AS profit
FROM ecommerce_orders
GROUP BY Acquisition_Channel ORDER BY revenue DESC;

-- 5. Top 10 products
SELECT Product, Category,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS revenue,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END),2) AS profit,
       SUM(Quantity) AS units
FROM ecommerce_orders
GROUP BY Product, Category ORDER BY revenue DESC LIMIT 10;

-- 6. Geographic performance
SELECT Country, Region,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS revenue,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END),2) AS profit
FROM ecommerce_orders
GROUP BY Country, Region ORDER BY revenue DESC;

-- 7. Customer cohorts: first purchase month and customer count
WITH first_purchase AS (
  SELECT Customer_ID, DATE_FORMAT(MIN(Order_Date),'%Y-%m') AS cohort_month
  FROM ecommerce_orders
  WHERE Order_Status NOT IN ('Returned','Cancelled')
  GROUP BY Customer_ID
)
SELECT cohort_month, COUNT(DISTINCT Customer_ID) AS acquired_customers
FROM first_purchase GROUP BY cohort_month ORDER BY cohort_month;

-- 8. Return/cancellation analysis
SELECT Category, Order_Status, COUNT(*) AS order_count,
       ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY Category),2) AS pct_within_category
FROM ecommerce_orders
GROUP BY Category, Order_Status ORDER BY Category, order_count DESC;

-- 9. Device and payment mix
SELECT Device, Payment_Method, COUNT(*) AS order_count,
       ROUND(SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END),2) AS revenue
FROM ecommerce_orders GROUP BY Device, Payment_Method ORDER BY revenue DESC;

-- 10. Power BI-friendly views
CREATE OR REPLACE VIEW vw_ecommerce_order_detail AS
SELECT *,
       CASE WHEN Order_Status IN ('Returned','Cancelled') THEN 0 ELSE Net_Sales END AS Realized_Revenue,
       CASE WHEN Order_Status IN ('Returned','Cancelled') THEN 0 ELSE Profit END AS Realized_Profit,
       CASE WHEN Marketing_Spend > 0 THEN
          CASE WHEN Order_Status IN ('Returned','Cancelled') THEN 0 ELSE Net_Sales END / Marketing_Spend
       ELSE NULL END AS Revenue_To_Spend_Ratio
FROM ecommerce_orders;

CREATE OR REPLACE VIEW vw_ecommerce_monthly AS
SELECT DATE_FORMAT(Order_Date,'%Y-%m-01') AS Month_Start,
       SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END) AS Revenue,
       SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END) AS Profit,
       COUNT(*) AS Order_Records
FROM ecommerce_orders
GROUP BY DATE_FORMAT(Order_Date,'%Y-%m-01');

CREATE OR REPLACE VIEW vw_ecommerce_channel AS
SELECT Acquisition_Channel,
       SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Net_Sales ELSE 0 END) AS Revenue,
       SUM(Marketing_Spend) AS Marketing_Spend,
       SUM(CASE WHEN Order_Status NOT IN ('Returned','Cancelled') THEN Profit ELSE 0 END) AS Profit
FROM ecommerce_orders GROUP BY Acquisition_Channel;
