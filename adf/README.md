# Azure Data Factory Artifacts

Factory: `adf-ecommerce-olist-260924`

Pipeline: `pl_ingest_olist_files`

The pipeline was deployed and manually verified on 2026-09-24. It reuses one Binary Copy Activity to move each original source file from Landing to its matching Bronze folder without parsing or changing the CSV representation.

## Components

- `linkedService/ls_adls_gen2_mi.json`: ADLS Gen2 endpoint with no embedded credentials
- `dataset/ds_adls_binary.json`: parameterized Binary dataset for source and sink
- `pipeline/pl_ingest_olist_files.json`: reusable Landing-to-Bronze pipeline

The factory uses its system-assigned managed identity. That identity has `Storage Blob Data Contributor` on the project storage account.

## Parameters

The pipeline will reuse one Copy Activity with these parameters:

| Parameter | Example |
| --- | --- |
| `source_folder` | `orders` |
| `file_name` | `olist_orders_dataset.csv` |
| `target_folder` | `orders` |

The same pipeline ingests orders, order items, customers, and products into their matching Bronze folders. This avoids four duplicate pipelines while keeping the MVP simple.

## Copy Activity

- Activity name: `copy_landing_to_bronze`
- Source and sink format: Binary
- Retry count: 2
- Retry interval: 30 seconds
- Staging: disabled

Binary format is intentional because ADF treats the source file as-is instead of parsing and reserializing CSV content.

## Verified Runs

| File | Target | Status | Bytes written |
| --- | --- | --- | ---: |
| `olist_orders_dataset.csv` | `bronze/orders/` | Succeeded | 17,654,914 |
| `olist_order_items_dataset.csv` | `bronze/order_items/` | Succeeded | 15,438,671 |
| `olist_customers_dataset.csv` | `bronze/customers/` | Succeeded | 9,033,957 |
| `olist_products_dataset.csv` | `bronze/products/` | Succeeded | 2,379,446 |

All four Bronze sizes match their Landing source sizes. The deployed linked service was inspected after creation and contains no account key, SAS token, service-principal secret, or connection string.
