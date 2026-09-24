USE ecommerce_analytics;
GO
/* CETAS cannot overwrite files. Use v2 or clean v1 before a rerun. */
IF OBJECT_ID(N'silver.orders_enriched',N'U') IS NOT NULL
 THROW 50001,'silver.orders_enriched already exists; use a new version.',1;
GO
CREATE EXTERNAL TABLE silver.orders_enriched
WITH (LOCATION='silver/orders_enriched/v1/', DATA_SOURCE=west_europe_project_lake, FILE_FORMAT=parquet_snappy)
AS
SELECT o.order_id,i.order_item_id,o.customer_id,c.customer_unique_id,c.customer_state,
i.product_id,COALESCE(NULLIF(p.product_category_name,''),'unknown') product_category_name,
o.order_status,o.order_purchase_timestamp,o.order_delivered_customer_date,o.order_estimated_delivery_date,
i.price,i.freight_value,CAST(o.order_purchase_timestamp AS date) order_date,
CAST(i.price AS decimal(12,2)) item_revenue,
CASE WHEN o.order_delivered_customer_date IS NULL THEN NULL
     ELSE DATEDIFF(DAY,o.order_purchase_timestamp,o.order_delivered_customer_date) END delivery_days,
CAST(CASE WHEN o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL
 AND o.order_estimated_delivery_date IS NOT NULL
 THEN CASE WHEN o.order_delivered_customer_date>o.order_estimated_delivery_date THEN 1 ELSE 0 END
 ELSE NULL END AS bit) is_late_delivery
FROM bronze.orders o JOIN bronze.order_items i ON i.order_id=o.order_id
LEFT JOIN bronze.customers c ON c.customer_id=o.customer_id
LEFT JOIN bronze.products p ON p.product_id=i.product_id;
GO
SELECT COUNT_BIG(*) silver_rows,COUNT_BIG(DISTINCT order_id) distinct_orders,
SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) missing_customer_matches,
SUM(CASE WHEN product_category_name='unknown' THEN 1 ELSE 0 END) unknown_category_items
FROM silver.orders_enriched;
