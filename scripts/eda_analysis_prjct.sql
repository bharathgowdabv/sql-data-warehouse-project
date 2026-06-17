--change over time analysis
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

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
)t
