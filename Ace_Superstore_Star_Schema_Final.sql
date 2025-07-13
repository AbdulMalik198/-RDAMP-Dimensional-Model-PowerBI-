
-- ================================
-- STAR SCHEMA - ACE SUPERSTORE
-- ================================

-- 1. DIMENSION TABLES

CREATE TABLE dim_segment (
  segment_id INT AUTO_INCREMENT PRIMARY KEY,
  segment_name VARCHAR(100) NOT NULL
);

CREATE TABLE dim_category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL
);

CREATE TABLE dim_order_mode (
  order_mode_id INT AUTO_INCREMENT PRIMARY KEY,
  order_mode_name VARCHAR(50) NOT NULL
);

CREATE TABLE dim_customer (
  customer_id VARCHAR(50) PRIMARY KEY,
  segment_id INT,
  FOREIGN KEY (segment_id) REFERENCES dim_segment(segment_id)
);

CREATE TABLE dim_product (
  product_id VARCHAR(50) PRIMARY KEY,
  product_name VARCHAR(255) NOT NULL,
  category_id INT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
);

CREATE TABLE dim_location (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  city VARCHAR(100) NOT NULL,
  postal_code VARCHAR(20) NOT NULL,
  region VARCHAR(100),
  country VARCHAR(100)
);

CREATE TABLE dim_date (
  date_id INT AUTO_INCREMENT PRIMARY KEY,
  order_date DATE NOT NULL,
  year INT NOT NULL,
  month INT NOT NULL,
  quarter INT NOT NULL
);

-- 2. FACT TABLE

CREATE TABLE fact_sales (
  sales_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id VARCHAR(50) NOT NULL,
  product_id VARCHAR(50) NOT NULL,
  location_id INT NOT NULL,
  date_id INT NOT NULL,
  category_id INT NOT NULL,
  segment_id INT,
  order_mode_id INT NOT NULL,
  total_sales DECIMAL(12,2) NOT NULL,
  total_cost DECIMAL(12,2) NOT NULL,
  profit DECIMAL(12,2) NOT NULL,
  discount_amount DECIMAL(12,2) NOT NULL,
  quantity INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
  FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
  FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
  FOREIGN KEY (segment_id) REFERENCES dim_segment(segment_id),
  FOREIGN KEY (order_mode_id) REFERENCES dim_order_mode(order_mode_id)
);

-- 3. INSERT STATEMENTS (TEMPLATES)

-- Segment
INSERT INTO dim_segment (segment_name)
SELECT DISTINCT TRIM(Segment)
FROM ace_superstore_raw_data
WHERE Segment IS NOT NULL;

-- Category
INSERT INTO dim_category (category_name)
SELECT DISTINCT TRIM(Category)
FROM ace_superstore_raw_data
WHERE Category IS NOT NULL;

-- Order Mode
INSERT INTO dim_order_mode (order_mode_name)
SELECT DISTINCT TRIM(`Order Mode`)
FROM ace_superstore_raw_data
WHERE `Order Mode` IS NOT NULL;

-- Customer
INSERT INTO dim_customer (customer_id)
SELECT DISTINCT TRIM(`Customer ID`)
FROM ace_superstore_raw_data
WHERE `Customer ID` IS NOT NULL;

-- Product
INSERT INTO dim_product (product_id, product_name, category_id)
SELECT DISTINCT
  TRIM(`Product ID`),
  TRIM(`Product Name`),
  dc.category_id
FROM ace_superstore_raw_data raw
JOIN dim_category dc ON TRIM(raw.Category) = dc.category_name
WHERE `Product ID` IS NOT NULL;

-- Location
INSERT INTO dim_location (city, postal_code, region, country)
SELECT DISTINCT
  TRIM(City),
  TRIM(`Postal Code`),
  TRIM(Region),
  'UK'
FROM ace_superstore_raw_data
WHERE City IS NOT NULL;

-- Date
INSERT INTO dim_date (order_date, year, month, quarter)
SELECT DISTINCT
  `Order Date`,
  YEAR(`Order Date`),
  MONTH(`Order Date`),
  QUARTER(`Order Date`)
FROM ace_superstore_raw_data
WHERE `Order Date` IS NOT NULL;

-- FACT SALES
INSERT INTO fact_sales (
  customer_id, product_id, location_id, date_id,
  category_id, segment_id, order_mode_id,
  total_sales, total_cost, profit, discount_amount, quantity
)
SELECT
  TRIM(raw.`Customer ID`),
  TRIM(raw.`Product ID`),
  dl.location_id,
  dd.date_id,
  dc.category_id,
  ds.segment_id,
  dom.order_mode_id,
  (raw.Sales * raw.Quantity),
  (raw.`Cost Price` * raw.Quantity),
  (raw.Sales * raw.Quantity) - (raw.`Cost Price` * raw.Quantity),
  raw.Discount,
  raw.Quantity
FROM ace_superstore_raw_data raw
JOIN dim_location dl ON TRIM(raw.City) = dl.city AND TRIM(raw.`Postal Code`) = dl.postal_code
JOIN dim_date dd ON raw.`Order Date` = dd.order_date
JOIN dim_category dc ON TRIM(raw.Category) = dc.category_name
JOIN dim_product dp ON TRIM(raw.`Product ID`) = dp.product_id
LEFT JOIN dim_segment ds ON TRIM(raw.Segment) = ds.segment_name
JOIN dim_order_mode dom ON TRIM(raw.`Order Mode`) = dom.order_mode_name;

-- 4. VIEWS

CREATE VIEW vw_product_seasonality AS
SELECT
  dp.product_name,
  dd.year,
  dd.month,
  SUM(fs.total_sales) AS total_sales,
  SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_date dd ON fs.date_id = dd.date_id
GROUP BY dp.product_name, dd.year, dd.month
ORDER BY dp.product_name, dd.year, dd.month;

CREATE VIEW vw_discount_impact_analysis AS
SELECT
  dd.year,
  dd.month,
  AVG(fs.discount_amount) AS avg_discount,
  SUM(fs.profit) AS total_profit,
  SUM(fs.total_sales) AS total_sales
FROM fact_sales fs
JOIN dim_date dd ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;

CREATE VIEW vw_customer_order_patterns AS
SELECT
  ds.segment_name,
  COUNT(DISTINCT fs.sales_id) AS total_orders,
  AVG(fs.total_sales) AS avg_order_value,
  SUM(fs.profit) AS total_profit
FROM fact_sales fs
JOIN dim_segment ds ON fs.segment_id = ds.segment_id
GROUP BY ds.segment_name
ORDER BY total_profit DESC;

CREATE VIEW vw_channel_margin_report AS
SELECT
  dom.order_mode_name,
  SUM(fs.total_sales) AS total_sales,
  SUM(fs.total_cost) AS total_cost,
  SUM(fs.profit) AS total_profit,
  (SUM(fs.profit) / SUM(fs.total_sales)) * 100 AS profit_margin_pct
FROM fact_sales fs
JOIN dim_order_mode dom ON fs.order_mode_id = dom.order_mode_id
GROUP BY dom.order_mode_name;

CREATE VIEW vw_region_category_rankings AS
SELECT
  dl.region,
  dc.category_name,
  SUM(fs.total_sales) AS total_sales,
  SUM(fs.total_cost) AS total_cost,
  SUM(fs.profit) AS total_profit,
  (SUM(fs.profit) / SUM(fs.total_sales)) * 100 AS profit_margin_pct
FROM fact_sales fs
JOIN dim_location dl ON fs.location_id = dl.location_id
JOIN dim_category dc ON fs.category_id = dc.category_id
GROUP BY dl.region, dc.category_name
ORDER BY dl.region, profit_margin_pct DESC;
