# Vulcan (DataOS 2.0) — Sales & Workforce Data Product

Pacific: **pacific-051426** · Workspace/tenant: **ct-sandbox**

Deploy guide: [Vulcan Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/) · local steps in **`deploy/DEPLOY.md`**

## Project layout

| Path | Purpose |
|------|---------|
| `config.yaml` | **Cloud** — depot gateway `dataos://s3lhdepot`, dialect `spark` |
| `config.local.yaml` | **Local** — Postgres Docker |
| `domain-resource.yaml` | **Pacific apply** — `type: vulcan` manifest |
| `models/`, `seeds/`, `semantics/`, `checks/` | Data product |

## Local check (Postgres)

```bash
cp env.example .env
export DATAOS_TENANT_ID=ct-sandbox
export VULCAN_TENANT_ID=ct-sandbox
make local-infra
make local-check
```

## Deploy to Pacific

```bash
git push origin main
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl resource apply -f domain-resource.yaml -w ct-sandbox
```

Or: `make deploy-apply`

## Models

| Model | Grain |
|-------|-------|
| `raw.employees` | `employee_id` |
| `raw.orders` | `order_id` |
| `analytics.orders_enriched` | `order_id` |
| `analytics.sales_by_rep_daily` | `(order_date, employee_id)` |
