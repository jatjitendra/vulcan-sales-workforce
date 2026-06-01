MODEL (
  name analytics.orders_enriched,
  kind FULL,
  grain order_id,
  owner 'data_product_team',
  description 'Orders enriched with rep attributes (for semantics + downstream marts)',
  assertions (
    not_null(columns := (order_id, order_date, employee_id, amount, status)),
    unique_values(columns := (order_id)),
    accepted_values(column := status, is_in := ('pending', 'completed', 'cancelled')),
    accepted_range(column := amount, min_v := 0, max_v := 10000000)
  )
);

SELECT
  order_id,
  order_date,
  rep_id AS employee_id,
  rep_name,
  rep_department,
  customer_id,
  amount,
  status
FROM raw.orders
