# Vulcan (DataOS 2.0) — Data Products

Pacific: **pacific-051426** · Workspace/tenant: **ct-sandbox**

Layout aligned with **practice-insights-v2** (Bitbucket + monorepo path pattern). Deploy guide: **`deploy/DEPLOY.md`**

## Data products

| Product | Pacific resource name | Repo path |
|---------|----------------------|-----------|
| **retail-inventory-jk** | `retail-inv-jk` | `vulcan-sales-workforce/retail-inventory-jk/vulcan/` |
| **sales-workforce-jk** | `sales-workforce-jk` | `vulcan-sales-workforce/sales-workforce-jk/vulcan/` |

```bash
export VULCAN_PRODUCT=retail-inventory-jk   # default
make local-check
make deploy-apply
```

## Git remote (Bitbucket)

Same pattern as `practice-insights` on `sgws-testing`:

| Setting | Value |
|---------|--------|
| Repo URL | `https://bitbucket.org/tmdc/vulcan-sales-workforce` |
| Git secret | `ct-sandbox:bitbucket-cred-mr` (shared with practice-insights) |
| baseDir | `vulcan-sales-workforce/<product>/vulcan` |

Create the Bitbucket repo, push `main`, then deploy. Admin must grant your Bitbucket user access to `bitbucket-cred-mr` if sync fails.

## Deploy manifest paths

| Product | Apply file | baseDir |
|---------|------------|---------|
| retail | `vulcan-sales-workforce/retail-inventory-jk/vulcan/retail-inventory-jk-deploy.yaml` | `vulcan-sales-workforce/retail-inventory-jk/vulcan` |
| sales | `vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-jk-deploy.yaml` | `vulcan-sales-workforce/sales-workforce-jk/vulcan` |

See `vulcan-sales-workforce/retail-inventory-jk/README.md` for model details.
