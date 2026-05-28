# Cloud deploy — Sales & Workforce

**DataOS 2.0 Vulcan single-file deploy** (no bundle).

## Files

| File | Purpose |
|------|---------|
| [`sales-workforce-jk-deploy.yaml`](sales-workforce-jk-deploy.yaml) | **Main deploy** — `type: vulcan` (API + workflow + repo + depot) |
| [`resources/instance_secret_warehouse.yml.example`](resources/instance_secret_warehouse.yml.example) | Optional warehouse credentials template |
| [`scripts/deploy.sh`](scripts/deploy.sh) | One-command deploy script |
| [`DEPLOY.md`](DEPLOY.md) | Full step-by-step |

## Quick deploy

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl apply -f deploy/sales-workforce-jk-deploy.yaml -w ct-sandbox
```

Regenerate YAML after project changes:

```bash
make deploy-yaml
```

## Old approach (removed)

Bundle, data product spec, scanner, and separate service/workflow YAMLs are **not used** in the new Vulcan deploy path.
