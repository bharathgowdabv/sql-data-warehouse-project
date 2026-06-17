CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY p.prd_start_dt,p.prd_key) AS product_key,
	p.prd_id AS product_id,
	p.prd_key AS product_number,
	p.prd_nm AS product_name,
	p.cat_id AS category_id,
	c.CAT AS category,
	c.SUBCAT AS subcategory,
	c.MAINTENANCE AS maintanance,
	p.prd_cost AS cost,
	p.prd_line AS product_line,
	p.prd_start_dt AS start_date
FROM silver.crm_prd_info AS p
LEFT JOIN silver.erp_PX_CAT_G1V2 AS c
ON p.cat_id = c.ID
WHERE p.prd_end_dt IS NULL --FILTER OLD HISTORICAL DATE