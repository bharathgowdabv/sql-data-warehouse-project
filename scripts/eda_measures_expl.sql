--Find the Total Sales
SELECT
SUM(sales_amount) AS total_sales
FROM gold.fact_sales

--Find how any items are being sold
SELECT
SUM(quantity) AS Total_qantity
FROM gold.fact_sales

--Find the average selling price
SELECT
AVG(price) AS avg_price
FROM gold.fact_sales

--Find the total number of orders
SELECT
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales

--Find the total number of products
SELECT
COUNT(product_id) AS total_products
FROM gold.dim_products

--Find THE total number of Customers
SELECT
COUNT(customer_id) AS total_products
FROM gold.dim_customers

--Find the total number of customers that has placed an order
SELECT
*
FROM gold.