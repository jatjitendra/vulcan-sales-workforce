# Deploy: Sales & Workforce (DataOS 2.0 / Vulcan)

Single-file **`type: vulcan`** deploy — same Pacific settings as **practice-insights**.

## Files

| File | Purpose |
|------|---------|
| `sales-workforce-jk-deploy.yaml` | DataOS apply manifest (Spark + s3lhdepot) |
| `DEPLOY.md` | Step-by-step deploy guide |
| `scripts/deploy.sh` | Apply helper |
| `resources/git_sync_secret.yml.example` | Git credentials (private repo only) |
| `resources/instance_secret_warehouse.yml.example` | Notes — s3lhdepot is platform-managed |

## Quick apply

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl apply -f deploy/sales-workforce-jk-deploy.yaml -w ct-sandbox
```

## Regenerate deploy stub (optional)

```bash
make deploy-yaml
```

Writes `deploy/sales-workforce-jk-deploy.generated.yaml`. Merge spark/driver/executor fields into the main deploy file if needed.
