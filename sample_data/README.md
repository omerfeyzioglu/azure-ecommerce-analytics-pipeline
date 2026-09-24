# Olist Source Data

This project uses the public, anonymized [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published under the [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/).

The raw files are third-party data and are not covered by this repository's MIT License. They are kept unchanged and excluded from Git to avoid mixing the dataset with the code license and to keep the repository small.

## Required Files

Download the dataset archive from Kaggle and place these original files directly in this directory:

```text
sample_data/
├── olist_orders_dataset.csv
├── olist_order_items_dataset.csv
├── olist_customers_dataset.csv
└── olist_products_dataset.csv
```

Do not rename, edit, clean, or inject failures into the raw files.

## Selected Source Entities

| File | Grain | Purpose |
| --- | --- | --- |
| `olist_orders_dataset.csv` | Approximately one row per order | Status and order lifecycle timestamps |
| `olist_order_items_dataset.csv` | One row per order item | Product, price, and freight facts |
| `olist_customers_dataset.csv` | One row per order-scoped customer ID | Stable customer identifier and location |
| `olist_products_dataset.csv` | One row per product | Product category and physical attributes |

`order_items` is a one-to-many child of `orders`. Metrics must count distinct orders after joining to avoid double-counting multi-item orders.

Local source preparation measured these row counts without modifying the files:

| Source | Data rows |
| --- | ---: |
| Orders | 99,441 |
| Order items | 112,650 |
| Customers | 99,441 |
| Products | 32,951 |

These are local CSV preflight counts, not Azure or Synapse results.

`source_manifest.json` records the selected files' schemas, byte sizes, row counts, and SHA-256 hashes without redistributing their contents.

## Relationships

```text
orders.order_id       -> order_items.order_id
orders.customer_id    -> customers.customer_id
order_items.product_id -> products.product_id
```

The optional payments file and reviews, sellers, and geolocation sources are outside the MVP.
