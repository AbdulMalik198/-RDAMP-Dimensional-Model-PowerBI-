# -RDAMP-Dimensional-Model-PowerBI-
#  Ace Superstore Performance Analysis
This project demonstrates a complete end-to-end retail analytics workflow using a dimensional star schema, SQL transformations, and an interactive Power BI dashboard for Ace Superstore.
It explores product seasonality, discount impact, order value trends, customer profitability, and category performance by region.

##  Project Star Schema
### Star Schema Diagram
https://github.com/AbdulMalik198/-RDAMP-Dimensional-Model-PowerBI-/blob/main/Abdulmalik%20Alegimenlen%20Star%20Schema%20Diagram.png?raw=true

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
