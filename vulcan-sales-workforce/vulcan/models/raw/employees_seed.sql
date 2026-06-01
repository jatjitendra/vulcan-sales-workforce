MODEL (
  name raw.employees,
  kind SEED (
    path '../../seeds/employees.csv'
  ),
  columns (
    employee_id INT,
    full_name VARCHAR,
    department VARCHAR,
    hire_date DATE
  ),
  grain employee_id,
  owner 'data_product_team',
  description 'Mock employee master data (seed)'
);
