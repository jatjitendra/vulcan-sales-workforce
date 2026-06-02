# Vulcan (DataOS 2.0) — Sales & Workforce Data Product

Pacific: **pacific-051426** · Workspace/tenant: **ct-sandbox**

Layout aligned with **practice-insights-v2** reference. Deploy guide: [Vulcan Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/) · steps in **`deploy/DEPLOY.md`**

## Project layout

```
vulcan-sales-workforce/sales-workforce-jk/vulcan/
├── config.yaml                  # Cloud — Spark + dataos://s3lhdepot (dialect spark2)
├── config.local.yaml            # Local — Postgres Docker
├── sales-workforce-deploy.yaml  # Pacific apply manifest (like practice-insights-deploy.yaml)
├── external_models.yaml         # External table registry (empty — seeds via Vulcan)
├── models/
│   ├── raw/                     # SEED models (CSV)
│   ├── analytics/               # Transformed marts
│   ├── semantics/               # Semantic models
│   └── dq/                      # Data quality rules
└── seeds/                       # CSV mock data
```

| Path | Purpose |
|------|---------|
| `vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml` | **Cloud** — depot gateway `dataos://s3lhdepot`, dialect `spark2` |
| `vulcan-sales-workforce/sales-workforce-jk/vulcan/config.local.yaml` | **Local** — Postgres Docker |
| `vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml` | **Pacific apply** — `type: vulcan` manifest |
| `deploy/resources/git_sync_secret.yml` | GitHub credentials for git-sync |

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
export PATH="$HOME/.dataos/v2/bin:$PATH"
dataos-ctl context select --name pacific-051426
dataos-ctl tenant select -n ct-sandbox
dataos-ctl login
dataos-ctl resource apply -f vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml
```

Or: `make deploy-apply`

## Models (logic unchanged)

| Model | Grain |
|-------|-------|
| `raw.employees` | `employee_id` |
| `raw.orders` | `order_id` |
| `analytics.orders_enriched` | `order_id` |
| `analytics.sales_by_rep_daily` | `(order_date, employee_id)` |

## Reference

Same Pacific stack as **practice-insights-v2**: `ct-sandbox-compute`, engine `spark`, depot `s3lhdepot`, daily cron `0 6 * * *` UTC.
