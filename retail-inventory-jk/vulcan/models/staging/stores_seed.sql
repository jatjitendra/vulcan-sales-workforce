MODEL (
  name staging.stores,
  kind SEED (
    path '../../seeds/stores.csv'
  ),
  columns (
    store_id INT,
    store_name VARCHAR,
    region VARCHAR,
    store_type VARCHAR
  ),
  grain store_id,
  owner 'retail_ops_team',
  description 'Mock retail store master (seed)'
);
