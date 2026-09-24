# Azure Data Factory Artifacts

This directory is reserved for a sanitized export of the planned `pl_ingest_olist_files` pipeline.

The pipeline will reuse one Copy Activity with these parameters:

| Parameter | Example |
| --- | --- |
| `source_folder` | `orders` |
| `file_name` | `olist_orders_dataset.csv` |
| `target_folder` | `orders` |

The same pipeline will ingest orders, order items, customers, and products into their matching Bronze folders. This avoids four duplicate pipelines while keeping the MVP simple.

No Data Factory pipeline has been created or run yet. Azure-generated JSON will be committed only after successful runs and a review for credentials and environment-specific secrets.
