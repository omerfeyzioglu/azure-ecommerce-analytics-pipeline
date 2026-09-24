USE ecommerce_analytics;
GO

/*
CETAS cannot overwrite a populated path. Dropping external-table metadata does
not delete Parquet files. For a rerun, either drop the metadata and use a new
versioned location, or remove the old destination files before reusing v1.
*/
IF EXISTS (
    SELECT 1
    FROM sys.external_tables
    WHERE name = N'orders_enriched'
      AND schema_id = SCHEMA_ID(N'silver')
)
BEGIN
    THROW 50001, 'silver.orders_enriched already exists; prepare metadata and storage before rerunning CETAS.', 1;
END;
GO

CREATE EXTERNAL TABLE silver.orders_enriched
WITH (
    LOCATION = 'silver/orders_enriched/v1/',
    DATA_SOURCE = west_europe_project_lake,
    FILE_FORMAT = parquet_snappy
)
AS
SELECT
    o.order_id,
    i.order_item_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    i.product_id,
    COALESCE(NULLIF(p.product_category_name, ''), 'unknown') AS product_category_name,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    i.price,
    i.freight_value,
    CAST(o.order_purchase_timestamp AS date) AS order_date,
    CAST(i.price AS decimal(12,2)) AS item_revenue,
    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        ELSE DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)
    END AS delivery_days,
    CAST(
        CASE
            WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
            THEN CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
                ELSE 0
            END
            ELSE NULL
        END AS bit
    ) AS is_late_delivery
FROM bronze.orders AS o
INNER JOIN bronze.order_items AS i ON i.order_id = o.order_id
LEFT JOIN bronze.customers AS c ON c.customer_id = o.customer_id
LEFT JOIN bronze.products AS p ON p.product_id = i.product_id;
GO

SELECT
    COUNT_BIG(*) AS silver_rows,
    COUNT_BIG(DISTINCT order_id) AS distinct_orders,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_matches,
    SUM(CASE WHEN product_category_name = 'unknown' THEN 1 ELSE 0 END) AS unknown_category_items
FROM silver.orders_enriched;
GO
