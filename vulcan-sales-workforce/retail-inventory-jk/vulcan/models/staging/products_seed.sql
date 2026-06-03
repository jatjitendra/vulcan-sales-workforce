MODEL (
  name staging.products,
  kind SEED (
    path '../../seeds/products.csv'
  ),
  columns (
    product_id INT,
    product_name VARCHAR,
    category VARCHAR,
    unit_cost DECIMAL(10,2)
  ),
  grain product_id,
  owner 'retail_ops_team',
  description 'Mock product catalog (seed)'
);
