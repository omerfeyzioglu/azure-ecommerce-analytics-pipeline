USE ecommerce_analytics;
GO
CREATE OR ALTER VIEW bronze.orders AS
SELECT * FROM OPENROWSET(BULK 'bronze/orders/olist_orders_dataset.csv', DATA_SOURCE='west_europe_project_lake', FORMAT='CSV', PARSER_VERSION='2.0', HEADER_ROW=TRUE)
WITH (order_id varchar(32) 1, customer_id varchar(32) 2, order_status varchar(20) 3,
order_purchase_timestamp datetime2(0) 4, order_approved_at datetime2(0) 5,
order_delivered_carrier_date datetime2(0) 6, order_delivered_customer_date datetime2(0) 7,
order_estimated_delivery_date datetime2(0) 8) AS src;
GO
CREATE OR ALTER VIEW bronze.order_items AS
SELECT * FROM OPENROWSET(BULK 'bronze/order_items/olist_order_items_dataset.csv', DATA_SOURCE='west_europe_project_lake', FORMAT='CSV', PARSER_VERSION='2.0', HEADER_ROW=TRUE)
WITH (order_id varchar(32) 1, order_item_id int 2, product_id varchar(32) 3, seller_id varchar(32) 4,
shipping_limit_date datetime2(0) 5, price decimal(12,2) 6, freight_value decimal(12,2) 7) AS src;
GO
CREATE OR ALTER VIEW bronze.customers AS
SELECT * FROM OPENROWSET(BULK 'bronze/customers/olist_customers_dataset.csv', DATA_SOURCE='west_europe_project_lake', FORMAT='CSV', PARSER_VERSION='2.0', HEADER_ROW=TRUE)
WITH (customer_id varchar(32) 1, customer_unique_id varchar(32) 2, customer_zip_code_prefix varchar(10) 3,
customer_city varchar(100) 4, customer_state char(2) 5) AS src;
GO
CREATE OR ALTER VIEW bronze.products AS
SELECT * FROM OPENROWSET(BULK 'bronze/products/olist_products_dataset.csv', DATA_SOURCE='west_europe_project_lake', FORMAT='CSV', PARSER_VERSION='2.0', HEADER_ROW=TRUE)
WITH (product_id varchar(32) 1, product_category_name varchar(100) 2, product_name_length int 3,
product_description_length int 4, product_photos_qty int 5, product_weight_g int 6,
product_length_cm int 7, product_height_cm int 8, product_width_cm int 9) AS src;
GO
SELECT 'orders' entity, COUNT_BIG(*) row_count FROM bronze.orders UNION ALL
SELECT 'order_items', COUNT_BIG(*) FROM bronze.order_items UNION ALL
SELECT 'customers', COUNT_BIG(*) FROM bronze.customers UNION ALL
SELECT 'products', COUNT_BIG(*) FROM bronze.products;
SELECT TOP 10 order_id, customer_id, order_status, order_purchase_timestamp
FROM bronze.orders ORDER BY order_purchase_timestamp;
