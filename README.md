# Vulcan (DataOS 2.0) — Data Products

Pacific: **pacific-051426** · Workspace/tenant: **ct-sandbox**

Layout aligned with **practice-insights-v2** reference. Deploy guide: **`deploy/DEPLOY.md`**

## Data products

| Product | Pacific resource name | Repo path |
|---------|----------------------|-----------|
| **retail-inventory-jk** | `retail-inv-jk` | `retail-inventory-jk/vulcan/` |
| **sales-workforce-jk** | `sales-workforce-jk` | `sales-workforce-jk/vulcan/` |

```bash
export VULCAN_PRODUCT=retail-inventory-jk   # default
make local-check
make deploy-apply
```

## Deploy manifest paths

| Product | Apply file | baseDir |
|---------|------------|---------|
| retail | `retail-inventory-jk/vulcan/retail-inventory-jk-deploy.yaml` | `retail-inventory-jk/vulcan` |
| sales | `sales-workforce-jk/vulcan/sales-workforce-jk-deploy.yaml` | `sales-workforce-jk/vulcan` |

See `retail-inventory-jk/README.md` for model details.
