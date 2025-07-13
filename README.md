# -RDAMP-Dimensional-Model-PowerBI-
#  Ace Superstore Performance Analysis
This project demonstrates a complete end-to-end retail analytics workflow using a dimensional star schema, SQL transformations, and an interactive Power BI dashboard for Ace Superstore.
It explores product seasonality, discount impact, order value trends, customer profitability, and category performance by region.

##  Project Star Schema
### Star Schema Diagram

<img width="458" height="196" alt="image" src="https://github.com/user-attachments/assets/cfd5d914-050d-47a3-bc3c-f8d191667fab" />


##    Purpose of Each Table
###   fact_sales
Captures all transactional data, including total sales, total cost, profit, discount amounts, and quantity. All dimension keys link to this table to enable multi-angle analysis.

###   dim_customer
Holds unique customer IDs and maps customers to segments if used.

###   dim_product
Lists unique products and links each to its category.

###   dim_category
Defines product categories for product profitability insights.

###   dim_location
Includes cities, postal codes, regions, and countries to analyze sales and profit by geography.

###   dim_date
Breaks down order dates into year, month, and quarter for time-based analysis.

###   dim_segment
Stores customer segments to support segmentation and customer order patterns.

###   dim_order_mode
Distinguishes between Online and In-Store sales channels.

###  SQL Setup Instructions
####  Clone the Repository
Begin by cloning this repository to my local machine.

####  Open MySQL Workbench
Launch MySQL Workbench and connect to your database server.

####  Run the SQL Script
Open and execute the script:
Ace_Superstore_Star_Schema_Final.sql
This script will:

Create all necessary dimension and fact tables

Insert the cleaned data

Generate five pre-defined SQL views for reporting and analysis

####  Verify Setup
After execution, confirm that all tables and views have been successfully created by running:
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

##  Power BI Connection Steps

Below are the steps involved I use in connectig the MySQL to Powerbi:

I opened the Power BI Desktop.

Click Home > Get Data > MySQL Database.

Enter your MySQL server name and database. For local development, I use localhost:127.0.0.1.3306.

Authenticated with my MySQL user credentials.

Select the views:

vw_product_seasonality

vw_discount_impact_analysis

vw_customer_order_patterns

vw_channel_margin_report

vw_region_category_rankings

Clicked Load to import your clean, ready-to-query data model into Power BI.

##  Dashboard Insights 

<img width="1311" height="729" alt="image" src="https://github.com/user-attachments/assets/eb97fb30-aa82-4b8c-a590-e371e52ad586" />


