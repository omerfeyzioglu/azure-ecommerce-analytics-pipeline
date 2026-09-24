# Olist Source Model

The MVP selects four entities from the public Olist marketplace dataset. It preserves each source file at its natural grain in Landing and Bronze, then joins them into an item-grain Silver model.

## Source Tables

### Orders

File: `olist_orders_dataset.csv`

Grain: approximately one row per `order_id`.

Required fields include `order_id`, `customer_id`, `order_status`, `order_purchase_timestamp`, `order_delivered_customer_date`, and `order_estimated_delivery_date`.

### Order Items

File: `olist_order_items_dataset.csv`

Grain: one row per `(order_id, order_item_id)`. Multiple item rows per order are expected and are not duplicates.

Required fields include `order_id`, `order_item_id`, `product_id`, `price`, and `freight_value`.

### Customers

File: `olist_customers_dataset.csv`

Grain: one row per order-scoped `customer_id`. `customer_unique_id` is the stable identifier used to recognize repeat customers.

Required fields include `customer_id`, `customer_unique_id`, and `customer_state`.

### Products

File: `olist_products_dataset.csv`

Grain: one row per `product_id`.

Required fields include `product_id` and `product_category_name`.

## Relationships

```text
orders (1) --------< order_items (many)
   |                      |
   | customer_id          | product_id
   v                      v
customers (1)          products (1)
```

Join keys:

```text
orders.order_id = order_items.order_id
orders.customer_id = customers.customer_id
order_items.product_id = products.product_id
```

## Silver Grain

`orders_enriched` has one row per order item. The Silver CETAS defines these fields:

```text
order_id
order_item_id
customer_id
customer_unique_id
customer_state
product_id
product_category_name
order_status
order_purchase_timestamp
order_delivered_customer_date
order_estimated_delivery_date
price
freight_value
order_date
item_revenue
delivery_days
is_late_delivery
```

`item_revenue` equals `price`; freight is not included in GMV. `is_late_delivery` is evaluated only when a delivered order has both actual and estimated delivery timestamps.

## Local Source Preflight

A read-only local inspection verified that the four downloaded files match the corresponding files in the Kaggle archive. No source rows were changed.

| Check | Result |
| --- | ---: |
| Orders rows | 99,441 |
| Order-item rows | 112,650 |
| Customer rows | 99,441 |
| Product rows | 32,951 |
| Duplicate `orders.order_id` rows | 0 |
| Duplicate `(order_id, order_item_id)` rows | 0 |
| Duplicate `customers.customer_id` rows | 0 |
| Duplicate `products.product_id` rows | 0 |
| Order items without an order | 0 |
| Orders without a customer | 0 |
| Order items without a product | 0 |
| Products with a missing category | 610 |
| Non-positive item prices | 0 |
| Negative freight values | 0 |
| Delivered orders missing delivered timestamp | 8 |
| Delivery timestamp earlier than purchase timestamp | 0 |
| Rows with an unexpected order status | 0 |

These deterministic results are the acceptance baseline for the equivalent Serverless SQL quality checks in `synapse/03_data_quality.sql`.

## Aggregation Rules

- GMV: `SUM(price)` after excluding cancelled orders.
- Orders: `COUNT(DISTINCT order_id)`, never a raw row count after the item join.
- Items sold: count of order-item rows.
- Unique customers: `COUNT(DISTINCT customer_unique_id)`.
- Average order value: GMV divided by distinct order count.
- Late delivery: `order_delivered_customer_date > order_estimated_delivery_date` for delivered orders with both dates present.

The complete expected output baseline is documented in `docs/results.md`.
