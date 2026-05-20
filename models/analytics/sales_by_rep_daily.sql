MODEL (
  name analytics.sales_by_rep_daily,
  kind FULL,
  grain (order_date, employee_id),
  owner 'data_product_team',
  description 'Daily completed-order KPIs per sales rep',
  assertions (
    not_null(columns := (order_date, employee_id)),
    unique_combination_of_columns(columns := (order_date, employee_id)),
    accepted_range(column := revenue, min_v := 0, max_v := 10000000)
  )
);

SELECT
  order_date,
  employee_id,
  rep_name,
  rep_department,
  COUNT(*) AS order_count,
  SUM(amount) AS revenue,
  AVG(amount) AS avg_order_value
FROM analytics.orders_enriched
WHERE status = 'completed'
GROUP BY
  order_date,
  employee_id,
  rep_name,
  rep_department
