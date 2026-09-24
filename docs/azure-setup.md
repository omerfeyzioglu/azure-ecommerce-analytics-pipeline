# Azure Setup

Azure setup will be performed interactively after the four local Olist source files are downloaded and inspected.

Planned resources, all in one Azure region:

- Resource group: `rg-ecommerce-analytics-demo`
- One ADLS Gen2-compatible storage account with hierarchical namespace enabled
- One Azure Data Factory instance
- One Azure Synapse workspace using Serverless SQL only

Resource names that require global uniqueness will be chosen at creation time. No Azure resource is currently claimed to exist.

## Planned Data Lake Paths

```text
/landing/orders/olist_orders_dataset.csv
/landing/order_items/olist_order_items_dataset.csv
/landing/customers/olist_customers_dataset.csv
/landing/products/olist_products_dataset.csv

/bronze/orders/olist_orders_dataset.csv
/bronze/order_items/olist_order_items_dataset.csv
/bronze/customers/olist_customers_dataset.csv
/bronze/products/olist_products_dataset.csv

/silver/orders_enriched/v1/
/gold/daily_gmv/v1/
/gold/category_performance/v1/
/gold/delivery_performance/v1/
```

The versioned Silver and Gold paths are intentional because Synapse CETAS does not overwrite a populated destination folder.
