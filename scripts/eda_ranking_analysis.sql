--Which 5 products generate highest revenue
SELECT
*
FROM(
	SELECT
		p.product_name,
		SUM(s.sales_amount) product_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(s.sales_amount) DESC) product_rank 
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
	GROUP BY p.product_name
)t
WHERE product_rank <= 5


--What are the 5 worst performing products in terms of sales
SELECT TOP 5
p.product_name,
SUM(s.sales_amount) product_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY product_revenue

--Find the top 10 customers who have generated the highest revenue

SELECT
*
FROM
(
	SELECT
		c.customer_key,
		c.first_name,
		c.last_name,
		SUM(s.sales_amount) total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(s.sales_amount) DESC) customer_rank
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
	GROUP BY c.customer_key,
			 c.first_name,
			 c.last_name
)t
WHERE customer_rank <= 10

--The 3 customers with fewest orders placed
SELECT
*
FROM
(
	SELECT
		c.customer_key,
		c.first_name,
		c.last_name,
		COUNT(DISTINCT s.order_number) total_orders,
		ROW_NUMBER() OVER(ORDER BY COUNT( DISTINCT s.order_number)) customer_rank
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
	GROUP BY c.customer_key,
			 c.first_name,
			 c.last_name
)t
WHERE customer_rank <= 3