MODEL (
  name marts.inventory_levels,
  kind FULL,
  grain (store_id, product_id),
  owner 'retail_ops_team',
  description 'Current on-hand quantity and inventory value by store and product',
  assertions (
    not_null(columns := (store_id, product_id, on_hand_qty)),
    unique_combination_of_columns(columns := (store_id, product_id))
  )
);

SELECT
  m.store_id,
  s.store_name,
  s.region,
  s.store_type,
  m.product_id,
  p.product_name,
  p.category,
  p.unit_cost,
  SUM(m.quantity) AS on_hand_qty,
  SUM(m.quantity) * p.unit_cost AS inventory_value
FROM staging.stock_movements AS m
INNER JOIN staging.stores AS s ON m.store_id = s.store_id
INNER JOIN staging.products AS p ON m.product_id = p.product_id
GROUP BY
  m.store_id,
  s.store_name,
  s.region,
  s.store_type,
  m.product_id,
  p.product_name,
  p.category,
  p.unit_cost
