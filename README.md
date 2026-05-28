# Vulcan (DataOS 2.0) — Mock Employee + Sales Data Product

Pacific target: **instance** `pacific-051426` · **workspace/tenant** `ct-sandbox` · **role** `data-developer`

This project is a minimal end-to-end example of building a data product on **DataOS 2.0 (Vulcan)**:

- **Mock sources** as seed CSVs (`seeds/`)
- **Unified models** in SQL (`models/`)
- **Built-in validation loop** using blocking assertions + audits/tests (`vulcan audit`, `vulcan test`)
- **Non-blocking checks** for monitoring (`checks/`)
- **Vulcan Semantics** for metrics/dimensions and generated APIs (`semantics/`)

## Project layout

- `seeds/`: mock input datasets (employees, orders)
- `models/raw/`: seed-to-raw tables
- `models/analytics/`: curated marts for consumption and semantics
- `checks/`: non-blocking monitoring checks
- `semantics/`: semantic model (measures, dimensions, joins)

## Run (Docker-based CLI)

Copy env defaults (optional):

```bash
cp env.example .env
export VULCAN_TENANT_ID=ct-sandbox
```

From this directory:

```bash
make up
make vulcan-cli CMD="info"
make vulcan-cli CMD="plan --auto-apply --no-prompts"
make vulcan-cli CMD="audit"
```

If `raw.employees` virtual-layer update fails on first run, re-run:

```bash
make vulcan-cli CMD='plan --auto-apply --no-prompts --select-model raw.employees'
```

UIs (after `make up`):

| Service | URL |
|---------|-----|
| Vulcan API docs | http://localhost:18000/redoc |
| GraphQL | http://localhost:13000 |
| Transpiler | http://localhost:18100 |
| MinIO console | http://localhost:9011 |

> Host ports were moved off defaults (8000, 8100, etc.) because those ports are already in use on this machine. Inside Docker, services still talk on their normal ports.

## Data product: "Sales & workforce"

Mock sources:
- `raw.employees` (employee master)
- `raw.orders` (order facts; `rep_id` links to `employees.employee_id`)

Curated marts:
- `analytics.orders_enriched` (orders with rep attributes)
- `analytics.sales_by_rep_daily` (daily KPIs per rep)

## Deploy to DataOS Cloud (Pacific)

Single-file Vulcan deploy (no bundle). See **`deploy/DEPLOY.md`**.

1. Local validate: `make up` → plan → audit
2. Push to GitHub: `git push -u origin main`
3. Generate/update YAML: `make deploy-yaml`
4. Apply:

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl apply -f deploy/sales-workforce-jk-deploy.yaml -w ct-sandbox
```

Key file: **`deploy/sales-workforce-jk-deploy.yaml`** (`type: vulcan`)

