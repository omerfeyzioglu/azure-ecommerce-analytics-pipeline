# Azure Setup

## Verified Resources

Created and verified on 2026-09-24:

- Resource group: `rg-ecommerce-analytics-demo`
- Region: West Europe
- Storage account: `stecomolistomer260924`
- Account type: Standard GPv2
- Redundancy: LRS
- Hierarchical namespace: enabled
- HTTPS-only: enabled
- Minimum TLS version: 1.2
- Anonymous blob access: disabled
- Filesystem: `datalake`
- Data Factory: `adf-ecommerce-olist-260924`
- Data Factory identity: system-assigned managed identity

The ADF deployment is independent from Synapse. Serverless SQL may run from another permitted region while reading and writing this West Europe lake through its managed identity.

## Access

The signed-in development user has `Storage Blob Data Contributor` scoped to this storage account. Landing uploads used Microsoft Entra authentication through Azure CLI with `--auth-mode login`. No account key, SAS token, or connection string was used or stored in the repository.

## Data Lake Paths

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

The parent directories exist. Versioned `v1` output directories will be created by the transformation process and are not pre-populated.

## Landing Upload

The original source files were uploaded separately with Azure CLI:

```bash
az storage fs file upload \
  --source sample_data/olist_orders_dataset.csv \
  --path landing/orders/olist_orders_dataset.csv \
  --file-system datalake \
  --account-name stecomolistomer260924 \
  --auth-mode login \
  --overwrite false
```

The same command pattern was used for order items, customers, and products with their matching paths. This represents the upstream source drop. Azure Data Factory did not produce the Landing files.

## Verified Landing Files

| Azure path | Bytes |
| --- | ---: |
| `landing/orders/olist_orders_dataset.csv` | 17,654,914 |
| `landing/order_items/olist_order_items_dataset.csv` | 15,438,671 |
| `landing/customers/olist_customers_dataset.csv` | 9,033,957 |
| `landing/products/olist_products_dataset.csv` | 2,379,446 |

These sizes match `sample_data/source_manifest.json`. Bronze was checked after the upload and contained no files, as expected before the ADF phase.

## Data Factory Ingestion

`pl_ingest_olist_files` was deployed with one parameterized Binary Copy Activity. Four manual runs succeeded on 2026-09-24 and created these Bronze files:

| Azure path | Bytes |
| --- | ---: |
| `bronze/orders/olist_orders_dataset.csv` | 17,654,914 |
| `bronze/order_items/olist_order_items_dataset.csv` | 15,438,671 |
| `bronze/customers/olist_customers_dataset.csv` | 9,033,957 |
| `bronze/products/olist_products_dataset.csv` | 2,379,446 |

The Bronze sizes match Landing. The pipeline has no trigger or recurring schedule.

## Synapse Serverless

Use the built-in endpoint ending in `-ondemand.sql.azuresynapse.net`, grant the workspace managed identity `Storage Blob Data Contributor` on the `datalake` filesystem, and run the files in `synapse/` in numeric order. No Dedicated SQL Pool or Spark Pool is required.

The SQL layer is implemented in the repository, but a complete successful Synapse execution has not yet been verified.
