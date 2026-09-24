USE ecommerce_analytics;
GO
WITH checks AS (
 SELECT 'duplicate_orders' check_name, COUNT_BIG(*) failed_rows FROM (SELECT order_id FROM bronze.orders GROUP BY order_id HAVING COUNT_BIG(*)>1) x
 UNION ALL SELECT 'duplicate_order_items', COUNT_BIG(*) FROM (SELECT order_id,order_item_id FROM bronze.order_items GROUP BY order_id,order_item_id HAVING COUNT_BIG(*)>1) x
 UNION ALL SELECT 'duplicate_customers', COUNT_BIG(*) FROM (SELECT customer_id FROM bronze.customers GROUP BY customer_id HAVING COUNT_BIG(*)>1) x
 UNION ALL SELECT 'duplicate_products', COUNT_BIG(*) FROM (SELECT product_id FROM bronze.products GROUP BY product_id HAVING COUNT_BIG(*)>1) x
 UNION ALL SELECT 'order_items_without_order', COUNT_BIG(*) FROM bronze.order_items i LEFT JOIN bronze.orders o ON o.order_id=i.order_id WHERE o.order_id IS NULL
 UNION ALL SELECT 'orders_without_customer', COUNT_BIG(*) FROM bronze.orders o LEFT JOIN bronze.customers c ON c.customer_id=o.customer_id WHERE c.customer_id IS NULL
 UNION ALL SELECT 'order_items_without_product', COUNT_BIG(*) FROM bronze.order_items i LEFT JOIN bronze.products p ON p.product_id=i.product_id WHERE p.product_id IS NULL
 UNION ALL SELECT 'products_missing_category', COUNT_BIG(*) FROM bronze.products WHERE NULLIF(LTRIM(RTRIM(product_category_name)),'') IS NULL
 UNION ALL SELECT 'non_positive_price', COUNT_BIG(*) FROM bronze.order_items WHERE price<=0
 UNION ALL SELECT 'negative_freight', COUNT_BIG(*) FROM bronze.order_items WHERE freight_value<0
 UNION ALL SELECT 'unexpected_status', COUNT_BIG(*) FROM bronze.orders WHERE order_status NOT IN ('approved','canceled','created','delivered','invoiced','processing','shipped','unavailable')
 UNION ALL SELECT 'delivered_missing_timestamp', COUNT_BIG(*) FROM bronze.orders WHERE order_status='delivered' AND order_delivered_customer_date IS NULL
 UNION ALL SELECT 'delivery_before_purchase', COUNT_BIG(*) FROM bronze.orders WHERE order_delivered_customer_date<order_purchase_timestamp
)
SELECT check_name, failed_rows,
CASE WHEN failed_rows=0 THEN 'PASS'
     WHEN check_name IN ('products_missing_category','delivered_missing_timestamp') THEN 'KNOWN_SOURCE_ISSUE'
     ELSE 'FAIL' END quality_status
FROM checks ORDER BY check_name;
