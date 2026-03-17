SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
USE olist_marketplace;

CREATE TABLE customers_dataset (                       -- creating customer table
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

LOAD DATA INFILE                                       -- loading data into customer table
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Project 6/olist_customers_dataset.csv'
INTO TABLE customers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE orders_dataset (                     -- creating orderd table
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

LOAD DATA INFILE                                 -- loading data into orders table
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Project 6/olist_orders_dataset.csv'
INTO TABLE orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
order_id,
customer_id,
order_status,
@order_purchase_timestamp,
@order_approved_at,
@order_delivered_carrier_date,
@order_delivered_customer_date,
@order_estimated_delivery_date
)
SET
order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
order_approved_at = NULLIF(@order_approved_at, ''),
order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');

CREATE TABLE order_items_dataset (                            -- creating order items table
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

LOAD DATA INFILE                                        -- loading data into order items table
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Project 6/olist_order_items_dataset.csv'
INTO TABLE order_items_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE order_payments_dataset (                         -- creating order payments table
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

LOAD DATA INFILE                                        -- loading data into order payments table
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Project 6/olist_order_payments_dataset.csv'
INTO TABLE order_payments_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE geolocation_dataset (                        -- creating geolocation table
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);

LOAD DATA INFILE                                          -- loading data in geolocation table
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Project 6/olist_geolocation_dataset.csv'
INTO TABLE geolocation_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 
-- cleaning the data now

-- lets work on customers table below

SELECT COUNT(*) FROM customers_dataset;                -- Check Row Count
SELECT                                                 -- Check nulls
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_unique_id IS NULL) AS null_unique_id,
    SUM(customer_state IS NULL) AS null_state
FROM customers_dataset;
SELECT customer_id, COUNT(*)                                 -- Check duplicates
FROM customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;
SELECT customer_unique_id, COUNT(*)     -- check same unique customers appearing multiple times
FROM customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;
CREATE TABLE dim_customers AS          -- create clean customer diamension table
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM customers_dataset;                         -- checking if the customers diamension table worked 

-- Lets clean orders_dataset table --

DESCRIBE orders_dataset;                     -- checking column names
SELECT COUNT(*) FROM orders_dataset;
SELECT order_id, COUNT(*)                       -- checking if there are any duplicate primary keys (same primary key more than once)
FROM orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;
SELECT                                        -- checking null values and replacing them
 SUM(order_id IS NULL) AS null_order_id,
 SUM(customer_id IS NULL) AS null_customer_id,
 SUM(order_status IS NULL) AS null_status,
 SUM(order_purchase_timestamp IS NULL) AS null_timestamp
FROM orders_dataset;
SELECT o.customer_id                        -- (Left Join) checking foreign key integrity by joining orders dataset with customers dataset
FROM orders_dataset o            
LEFT JOIN customers_dataset c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
SELECT *                          -- checking date logic( Delivery date cannot be before purchase date.)
FROM orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp; 
SELECT order_status, COUNT(*)      -- checking order status ( how many delivered or unavailable or shipped or canceledetc..)
FROM orders_dataset
GROUP BY order_status;
SELECT                                            -- Delivery delay analysis 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_delivery_days
FROM orders_dataset
WHERE order_status = 'delivered';

-- lets create clean orders table and derived columns inside it..
CREATE TABLE orders_clean AS                       -- creating new table
SELECT
    order_id,
    customer_id,
    order_status,
    DATE(order_purchase_timestamp) AS order_date,   -- extracting date from timestamp column
    YEAR(order_purchase_timestamp) AS order_year,    -- extracting year from timestamp column
    MONTH(order_purchase_timestamp) AS order_month,    -- extracting month from timestamp column
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days -- creating delivery days column
FROM orders_dataset;
SELECT * FROM orders_clean LIMIT 10;            -- check if the table is created properly or not

-- lets clean the order items dataset table
DESCRIBE order_items_dataset;        -- understand the table structure
SELECT COUNT(*) FROM order_items_dataset;       -- check row count
SELECT                               -- check in the important columns for nulls
    SUM(order_id IS NULL) AS null_order_id,   -- important because links to orders table
    SUM(product_id IS NULL) AS null_product_id,   -- important because links to products table
    SUM(seller_id IS NULL) AS null_seller_id,    -- important because seller dimension
    SUM(price IS NULL) AS null_price,           -- important because revenue depends on it
    SUM(freight_value IS NULL) AS null_freight    -- important because of shipping cost
FROM order_items_dataset;
SELECT order_id, order_item_id, COUNT(*)        -- checking duplicates (order_id alone is NOT unique because one order can have multiple items.)
FROM order_items_dataset   
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
SELECT                           -- price sanity check 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM order_items_dataset;
SELECT                     -- freight sanity check (Freight should always be ≥ 0)
    MIN(freight_value),
    MAX(freight_value),
    AVG(freight_value)
FROM order_items_dataset;
CREATE TABLE order_items_clean AS               -- creating clean order item table
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    price + freight_value AS total_item_value        -- creating new column item value 
FROM order_items_dataset
WHERE
    price >= 0
    AND freight_value >= 0;
    
-- lets work on products_dataset table
DESCRIBE products_dataset;         -- lets inspect the table first 
SELECT COUNT(*) FROM products_dataset;         -- check number of rows first
SELECT                                 -- check for null values
    SUM(product_id IS NULL) AS null_product_id,
    SUM(product_category_name IS NULL) AS null_category,
    SUM(product_name_lenght IS NULL) AS null_name_length,
    SUM(product_description_lenght IS NULL) AS null_description,
    SUM(product_photos_qty IS NULL) AS null_photos
FROM products_dataset;
SELECT product_id, COUNT(*)           -- check duplicate products
FROM products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;
SELECT product_category_name, COUNT(*)       -- check category distribution (This shows which product categories exist)
FROM products_dataset
GROUP BY product_category_name
ORDER BY COUNT(*) DESC;
CREATE TABLE products_clean AS       -- create clean product table
SELECT
    product_id,
    COALESCE(product_category_name, 'unknown') AS product_category_name,
    product_name_lenght AS product_name_length,
    product_description_lenght AS product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products_dataset;

-- lets clean the sellers table
DESCRIBE sellers_dataset;        -- check table structure
SELECT COUNT(*) FROM sellers_dataset;        -- check rows
SELECT                           -- checking nulls
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(seller_city IS NULL) AS null_city,
    SUM(seller_state IS NULL) AS null_state
FROM sellers_dataset; 
SELECT seller_id, COUNT(*)            -- check for duplicates 
FROM sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;
SELECT seller_state, COUNT(*) AS seller_count    -- check seller distribution by state
FROM sellers_dataset
GROUP BY seller_state
ORDER BY seller_count DESC;
CREATE TABLE sellers_clean (                 -- create clean table structure as the primary key was not initially declared in seller table
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);
INSERT INTO sellers_clean       -- inserting data from raw table into clean table
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM sellers_dataset
WHERE seller_id IS NOT NULL;

-- lets clean the geolocation table now 
DESCRIBE geolocation_dataset;      -- check the table structure
SELECT COUNT(*) FROM geolocation_dataset;    -- checking row count
SELECT geolocation_zip_code_prefix, COUNT(*)     -- check duplicate zip codes
FROM geolocation_dataset
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
CREATE TABLE geolocation_clean AS      -- create clean geolocation table
SELECT
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS avg_latitude,
    AVG(geolocation_lng) AS avg_longitude,
    MIN(geolocation_city) AS city,
    MIN(geolocation_state) AS state
FROM geolocation_dataset
GROUP BY geolocation_zip_code_prefix; 

-- LETS WORK ON JOINS NOW --
-- JOIN 1 : Orders table and Customers table. 
-- Reason : Orders contain only the customer_id, but not customer details.
-- Joining allows you to add: customer_city, customer_state, customer_zip_code
-- This enables : Sales by state, Sales by city, Customer distribution analysis
SELECT                    
    o.order_id,        -- We choose columns from both tables
    o.customer_id,       -- Prefix meaning: o → orders table, c → customers table
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state
FROM orders_clean o          -- This is the main table. All orders must appear.
LEFT JOIN dim_customers c       -- Keep all rows from orders + Add matching customer info
ON o.customer_id = c.customer_id    -- This tells SQL how the tables connect
LIMIT 10;                       -- limiting the output to 10 rows

-- JOIN 2 : Orders table and Order items table
-- Reason : Orders table contains order events, but not the products or prices.
-- Order items contain: product_id, seller_id, price, freight_value
-- What this enables : Revenue calculation, Product-level sales, Order value analysis
SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value
FROM orders_clean o
LEFT JOIN order_items_clean oi
ON o.order_id = oi.order_id
LIMIT 10;

-- JOIN 3 : Order items and Products table
-- Reason : Order items know which product was sold, but not its category.
-- Products table contains: product_category_name, product attributes
-- What this enables : Revenue by category, Top product categories, Category distribution
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    p.product_category_name
FROM order_items_clean oi
LEFT JOIN products_clean p
ON oi.product_id = p.product_id
LIMIT 10;

-- JOIN 4 : Order items and Sellers table
-- Reason : Order items contain seller IDs but not location info.
-- Sellers table adds : seller_city, seller_state
-- What this enables : Sales by seller location, Seller performance analysis, Marketplace distribution
SELECT
	oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    s.seller_city,
    s.seller_state
FROM order_items_clean oi
LEFT JOIN sellers_clean s
ON oi.seller_id = s.seller_id
LIMIT 10;

-- JOIN 5 : Sellers and Geolocation
-- Reason : Sellers also have ZIP prefixes.
-- This join adds coordinates for : seller maps, logistics analysis 
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    g.avg_latitude,
    g.avg_longitude
FROM sellers_clean s
LEFT JOIN geolocation_clean g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
LIMIT 10;


