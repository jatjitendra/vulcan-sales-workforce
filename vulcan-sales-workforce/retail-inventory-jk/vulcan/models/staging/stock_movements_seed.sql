MODEL (
  name staging.stock_movements,
  kind SEED (
    path '../../seeds/stock_movements.csv'
  ),
  columns (
    movement_id INT,
    store_id INT,
    product_id INT,
    movement_date DATE,
    quantity INT,
    movement_type VARCHAR
  ),
  grain movement_id,
  owner 'retail_ops_team',
  description 'Mock inventory movements — inbound, sale, outbound (seed)'
);
