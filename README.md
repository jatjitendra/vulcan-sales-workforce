# Vulcan (DataOS 2.0) — Mock Employee + Sales Data Product

Pacific target: **instance** `pacific-051426` · **workspace/tenant** `ct-sandbox` · **role** `data-developer`

Cloud engine: **Spark + Iceberg** on **`s3lhdepot`** (same as practice-insights).

## Project layout

| Path | Purpose |
|------|---------|
| `config.yaml` | **Cloud** — depot gateway `dataos://s3lhdepot`, dialect `spark` |
| `config.local.yaml` | **Local Docker** — Postgres warehouse + statestore |
| `seeds/` | Mock CSV inputs (employees, orders) |
| `models/raw/` | Seed → raw tables |
| `models/analytics/` | Curated marts |
| `checks/` | Non-blocking monitoring |
| `semantics/` | Metrics API (order_count, total_revenue, avg_order_value) |
| `deploy/sales-workforce-jk-deploy.yaml` | Pacific apply manifest |

## Local run (Postgres Docker)

Uses `config.local.yaml` automatically:

```bash
cp env.example .env
export VULCAN_TENANT_ID=ct-sandbox
make up
make vulcan-cli CMD="plan --auto-apply --no-prompts"
make vulcan-cli CMD="audit"
```

| Service | URL |
|---------|-----|
| Vulcan API | http://localhost:18000/redoc |
| GraphQL | http://localhost:13000 |

## Deploy to Pacific (Spark + s3lhdepot)

See **`deploy/DEPLOY.md`**.

```bash
git push -u origin main
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl apply -f deploy/sales-workforce-jk-deploy.yaml -w ct-sandbox
```

## Data product models

| Model | Grain |
|-------|-------|
| `raw.employees` | `employee_id` |
| `raw.orders` | `order_id` |
| `analytics.orders_enriched` | `order_id` |
| `analytics.sales_by_rep_daily` | `(order_date, employee_id)` |

## Config summary

| Environment | Config file | Gateway | Dialect |
|-------------|-------------|---------|---------|
| Local Docker | `config.local.yaml` | Postgres `warehouse` | `postgres` |
| Pacific cloud | `config.yaml` | Depot `s3lhdepot` | `spark` |

Tenant is **`ct-sandbox`** in `config.yaml` / `config.local.yaml` and via **`DATAOS_TENANT_ID=ct-sandbox`** in the environment.
