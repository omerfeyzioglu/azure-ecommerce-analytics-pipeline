USE ecommerce_analytics;
GO
CREATE EXTERNAL TABLE gold.daily_gmv
WITH (LOCATION='gold/daily_gmv/v1/',DATA_SOURCE=west_europe_project_lake,FILE_FORMAT=parquet_snappy)
AS SELECT order_date,CAST(SUM(item_revenue) AS decimal(18,2)) gmv,COUNT_BIG(*) items_sold,
COUNT_BIG(DISTINCT order_id) order_count,COUNT_BIG(DISTINCT customer_unique_id) unique_customers,
CAST(SUM(item_revenue)/NULLIF(COUNT_BIG(DISTINCT order_id),0) AS decimal(18,2)) average_order_value
FROM silver.orders_enriched WHERE order_status<>'canceled' GROUP BY order_date;
GO
CREATE EXTERNAL TABLE gold.category_performance
WITH (LOCATION='gold/category_performance/v1/',DATA_SOURCE=west_europe_project_lake,FILE_FORMAT=parquet_snappy)
AS SELECT product_category_name,CAST(SUM(item_revenue) AS decimal(18,2)) gmv,COUNT_BIG(*) items_sold,
COUNT_BIG(DISTINCT order_id) order_count,COUNT_BIG(DISTINCT customer_unique_id) unique_customers,
CAST(AVG(item_revenue) AS decimal(18,2)) average_item_price
FROM silver.orders_enriched WHERE order_status<>'canceled' GROUP BY product_category_name;
GO
CREATE EXTERNAL TABLE gold.delivery_performance
WITH (LOCATION='gold/delivery_performance/v1/',DATA_SOURCE=west_europe_project_lake,FILE_FORMAT=parquet_snappy)
AS WITH delivered_orders AS (
 SELECT order_id,customer_state,DATEFROMPARTS(YEAR(MIN(order_purchase_timestamp)),MONTH(MIN(order_purchase_timestamp)),1) purchase_month,
 MIN(delivery_days) delivery_days,MIN(CAST(is_late_delivery AS tinyint)) is_late_delivery
 FROM silver.orders_enriched WHERE order_status='delivered' AND order_delivered_customer_date IS NOT NULL
 AND order_estimated_delivery_date IS NOT NULL GROUP BY order_id,customer_state)
SELECT purchase_month,customer_state,COUNT_BIG(*) delivered_orders,
CAST(AVG(CAST(delivery_days AS decimal(12,2))) AS decimal(12,2)) average_delivery_days,
SUM(CAST(is_late_delivery AS bigint)) late_orders,
CAST(100.0*SUM(CAST(is_late_delivery AS bigint))/NULLIF(COUNT_BIG(*),0) AS decimal(8,2)) late_delivery_rate_pct
FROM delivered_orders GROUP BY purchase_month,customer_state;
GO
SELECT TOP 10 * FROM gold.daily_gmv ORDER BY order_date DESC;
SELECT TOP 10 * FROM gold.category_performance ORDER BY gmv DESC;
SELECT TOP 10 * FROM gold.delivery_performance ORDER BY purchase_month DESC,customer_state;
