--change over time analysis
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

--Calculate the total sales per month
--running total
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM(
	SELECT
	DATETRUNC(year,order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(year,order_date)
)t;

/* Analyze the yearly performance of products by comparing each product's sales
 to both its average sales performance and previous year sales*/
WITH yearly_product_sales AS (
SELECT
YEAR(s.order_date) AS order_year,
p.product_name,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
WHERE YEAR(s.order_date) IS NOT NULL
GROUP BY YEAR(s.order_date), p.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diss_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_diff,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

--Which categories contribute the most to overall sales

SELECT
category,
cat_sales,
SUM(cat_sales) OVER() overall_sales,
CONCAT(ROUND((CAST(cat_sales AS FLOAT) / SUM(cat_sales) OVER())*100, 2), '%') AS contribution
FROM(
SELECT
p.category,
SUM(s.sales_amount) AS cat_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
GROUP BY p.category
)t
ORDER BY contribution DESC
;

WITH cost_range_table AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products
)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM cost_range_table
GROUP BY cost_range
ORDER BY total_products DESC;

WITH customer_category AS(
SELECT
c.customer_key,
SUM(s.sales_amount) AS total_sales,
COUNT(MONTH(s.order_date)) AS number_of_orders,
CASE WHEN SUM(s.sales_amount) > 5000 AND COUNT(MONTH(s.order_date)) >= 12 THEN 'VIP'
	 WHEN SUM(s.sales_amount) <= 5000 AND COUNT(MONTH(s.order_date)) >= 12 THEN 'Regular'
	 ELSE 'NEW'
END AS customer_group
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key =c.customer_key
GROUP BY c.customer_key)

SELECT
customer_group,
COUNT(*) AS no_of_customers
FROM customer_category
GROUP BY customer_group
ORDER BY no_of_customers DESC;