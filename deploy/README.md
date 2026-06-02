# Deploy — Sales & Workforce

Follow [Vulcan Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/).

Layout matches **practice-insights-v2** (deploy YAML inside the `vulcan/` folder).

## Files

| File | Purpose |
|------|---------|
| `../vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml` | DataOS apply manifest (`type: vulcan`) |
| `../vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml` | Cloud Vulcan config (Spark2 + `s3lhdepot`) |
| `DEPLOY.md` | Step-by-step Pacific deploy |
| `scripts/deploy.sh` | Apply helper |
| `resources/git_sync_secret.yml.example` | Git credentials (private repo) |

## Quick apply

```bash
cd ~/Downloads/Vulcan
export PATH="$HOME/.dataos/v2/bin:$PATH"
dataos-ctl context select --name pacific-051426
dataos-ctl tenant select -n ct-sandbox
dataos-ctl login
dataos-ctl resource apply -f vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml
```

Or: `make deploy-apply`

## Generate deploy stub

```bash
make deploy-yaml
# merges into sales-workforce-deploy.yaml manually if needed
```
