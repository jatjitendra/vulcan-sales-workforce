MODEL (
  name marts.store_performance_daily,
  kind FULL,
  grain (movement_date, store_id),
  owner 'retail_ops_team',
  description 'Daily inbound vs sale movement counts and units by store',
  assertions (
    not_null(columns := (movement_date, store_id)),
    unique_combination_of_columns(columns := (movement_date, store_id))
  )
);

SELECT
  m.movement_date,
  m.store_id,
  s.store_name,
  s.region,
  s.store_type,
  SUM(CASE WHEN m.movement_type = 'inbound' THEN m.quantity ELSE 0 END) AS inbound_units,
  SUM(CASE WHEN m.movement_type = 'sale' THEN ABS(m.quantity) ELSE 0 END) AS sale_units,
  COUNT(CASE WHEN m.movement_type = 'inbound' THEN 1 END) AS inbound_events,
  COUNT(CASE WHEN m.movement_type = 'sale' THEN 1 END) AS sale_events
FROM staging.stock_movements AS m
INNER JOIN staging.stores AS s ON m.store_id = s.store_id
GROUP BY
  m.movement_date,
  m.store_id,
  s.store_name,
  s.region,
  s.store_type
