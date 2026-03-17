E-Commerce Marketplace Analytics Dashboard
🚀 Project Overview

This project is a complete end-to-end data analytics solution designed to analyze an e-commerce marketplace dataset using SQL and Power BI.

The goal was to transform raw transactional data into structured, analysis-ready datasets and build an interactive dashboard that delivers actionable business insights across sales, customers, products, sellers, and logistics.

The dashboard enables stakeholders to:

Monitor revenue trends and growth patterns

Identify top-performing product categories

Analyze customer purchasing behavior

Evaluate delivery performance and efficiency

Understand seller contribution and concentration

Assess the impact of logistics costs on revenue

🧰 Tools & Technologies

SQL (MySQL) → Data cleaning, transformation, joins

Power BI → Data modeling & interactive dashboard development

DAX → KPI creation and calculated measures

Excel / CSV → Raw dataset handling

📂 Dataset

Dataset: Olist E-Commerce Marketplace Dataset

Source: Kaggle

Link: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Dataset Includes:

Orders & order items

Customers

Products

Sellers

Geolocation data

🧹 Data Preparation (SQL)

Performed extensive data cleaning and transformation to ensure data quality and usability:

Handled missing values and null records

Removed duplicate entries

Converted timestamps into usable date formats

Created derived columns (delivery days, revenue, etc.)

Validated inconsistencies (pricing, freight, delivery dates)

Built structured analytical tables for reporting

Final Tables Used:

orders_clean

order_items_clean

products_clean

sellers_clean

dim_customers

geolocation_clean

📊 Dashboard Overview

The Power BI dashboard consists of 5 analytical pages, each focusing on a key business area:

1️⃣ Sales Overview

Total Revenue: $13.59M

Total Orders: ~99K

Average Order Value (AOV): $136.68

Insights:

Revenue shows steady growth over time

A few top categories contribute the majority of sales

Freight cost is a significant component of total revenue

2️⃣ Product Performance

Total Items Sold: 113K

Average Product Price: $120.65

Insights:

Marketplace is dominated by mid-range products

Majority of orders contain a single item

Revenue is concentrated in a few key categories

3️⃣ Customer & Delivery Insights

Total Customers: 96K

Average Delivery Time: 12.5 days

Orders per Customer: 1.03

Delivery Success Rate: ~97%

Insights:

Very low repeat purchase rate (high churn risk)

Most deliveries are completed within 6–10 days

Delivery performance varies across regions

4️⃣ Seller Performance

Total Sellers: 3,095

Average Revenue per Seller: $4.39K

Insights:

Revenue is highly concentrated among top sellers

Seller activity is geographically clustered

Freight cost varies significantly by region

5️⃣ Business Performance

Total Revenue: $13.59M

Total Freight Cost: $2.25M (~17% of revenue)

Insights:

Revenue growth is primarily driven by order volume

Logistics cost scales directly with sales

Marketplace shows consistent and stable growth

📈 Key Business Insights

Generated $13.59M revenue across ~99K orders

Freight cost accounts for ~17% of total revenue

Majority of deliveries completed within 6–10 days

Customer retention is extremely low, indicating growth opportunity

Revenue heavily depends on top sellers and categories


💡 Skills Demonstrated

Data Cleaning & Transformation using SQL

Data Modeling (Star Schema Design)

KPI Development using DAX

Dashboard Design & Data Storytelling

Business Insight Generation & Interpretation

📌 Project Outcome

This project demonstrates the ability to:

Transform raw data into structured analytical datasets

Build scalable and interactive dashboards

Extract actionable insights from complex data

Perform end-to-end marketplace performance analysis

🔮 Future Improvements

Customer segmentation (RFM Analysis)

Profitability analysis by product category

Seller performance scoring model

Delivery delay prediction using ML

📬 Connect With Me

If you found this project insightful or would like to collaborate, feel free to connect!

