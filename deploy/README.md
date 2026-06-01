# Deploy — Sales & Workforce

Follow [Vulcan Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/).

## Files

| File | Purpose |
|------|---------|
| `../domain-resource.yaml` | DataOS apply manifest (`type: vulcan`) |
| `../vulcan-sales-workforce/vulcan/config.yaml` | Cloud Vulcan config (`repo.baseDir: vulcan-sales-workforce/vulcan`) |
| `DEPLOY.md` | Step-by-step Pacific deploy |
| `scripts/deploy.sh` | Apply helper |
| `resources/git_sync_secret.yml.example` | Git credentials (private repo) |

## Quick apply

```bash
cd ~/Downloads/Vulcan
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl resource apply -f domain-resource.yaml -w ct-sandbox
```

Or: `make deploy-apply`

## Generate deploy stub

```bash
make deploy-yaml
# merges into domain-resource.yaml manually if needed
```
