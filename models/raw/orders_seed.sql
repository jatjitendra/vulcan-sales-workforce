MODEL (
  name raw.orders,
  kind SEED (
    path '../../seeds/orders.csv'
  ),
  columns (
    order_id INT,
    order_date DATE,
    rep_id INT,
    rep_name VARCHAR,
    rep_department VARCHAR,
    customer_id INT,
    amount DECIMAL(12,2),
    status VARCHAR
  ),
  grain order_id,
  owner 'data_product_team',
  description 'Mock sales orders (seed). rep_id links to employees.employee_id'
);
