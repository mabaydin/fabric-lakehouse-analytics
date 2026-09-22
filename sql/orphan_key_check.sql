-- Referential-integrity check on the Gold layer (Lakehouse SQL analytics endpoint)
SELECT f.customer_id, COUNT(*) AS rows, SUM(f.revenue) AS revenue
FROM gold_fact_sales f
LEFT JOIN gold_dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL
GROUP BY f.customer_id;

-- Revenue by month and channel
SELECT d.year_month, c.channel, SUM(f.revenue) AS revenue, COUNT(*) AS orders
FROM gold_fact_sales f
JOIN gold_dim_date d     ON f.date_key = d.date_key
JOIN gold_dim_customer c ON f.customer_id = c.customer_id
GROUP BY d.year_month, c.channel
ORDER BY d.year_month, c.channel;
