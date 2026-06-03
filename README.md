# Vulcan (DataOS 2.0) — Data Products

Pacific: **pacific-051426** · Workspace/tenant: **ct-sandbox**

Layout aligned with **practice-insights-v2** reference. Deploy guide: [Vulcan Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/) · steps in **`deploy/DEPLOY.md`**

## Data products

| Product | Domain | Default Makefile target |
|---------|--------|-------------------------|
| **retail-inventory-jk** | Retail stores, products, inventory movements | `make local-check` (default) |
| **sales-workforce-jk** | Sales reps, orders, revenue KPIs | `make local-check VULCAN_PRODUCT=sales-workforce-jk` |

Both use the same Pacific stack: `ct-sandbox-compute`, engine `spark`, depot `s3lhdepot`.

---

## retail-inventory-jk (new — default)

**Path:** `vulcan-sales-workforce/retail-inventory-jk/vulcan/`

```
models/staging/   → stores, products, stock_movements (CSV seeds)
models/marts/     → inventory_levels, store_performance_daily
models/semantics/ → inventory, store_daily
models/dq/        → completeness, validity, accuracy checks
```

| Model | Grain |
|-------|-------|
| `staging.stores` | `store_id` |
| `staging.products` | `product_id` |
| `staging.stock_movements` | `movement_id` |
| `marts.inventory_levels` | `(store_id, product_id)` |
| `marts.store_performance_daily` | `(movement_date, store_id)` |

### Local check

```bash
export DATAOS_TENANT_ID=ct-sandbox
export VULCAN_TENANT_ID=ct-sandbox
make local-infra
make local-check
```

### Deploy

```bash
git push origin main
make deploy-apply
# or: make deploy-apply VULCAN_PRODUCT=retail-inventory-jk
```

---

## sales-workforce-jk (original)

**Path:** `vulcan-sales-workforce/sales-workforce-jk/vulcan/`

```bash
make local-check VULCAN_PRODUCT=sales-workforce-jk
make deploy-apply VULCAN_PRODUCT=sales-workforce-jk
```

| Model | Grain |
|-------|-------|
| `raw.employees` | `employee_id` |
| `raw.orders` | `order_id` |
| `analytics.orders_enriched` | `order_id` |
| `analytics.sales_by_rep_daily` | `(order_date, employee_id)` |

---

## Makefile variables

```bash
VULCAN_PRODUCT=retail-inventory-jk   # or sales-workforce-jk
make vulcan-cli CMD="info"
make deploy-apply
```

See also: `vulcan-sales-workforce/retail-inventory-jk/README.md`
