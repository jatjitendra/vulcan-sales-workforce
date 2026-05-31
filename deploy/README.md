# Deploy — Sales & Workforce

Follow [Vulcan Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/).

## Files

| File | Purpose |
|------|---------|
| `../domain-resource.yaml` | DataOS apply manifest (`type: vulcan`) |
| `../config.yaml` | Cloud Vulcan config (in repo root) |
| `DEPLOY.md` | Step-by-step Pacific deploy |
| `scripts/deploy.sh` | Apply helper |
| `resources/git_sync_secret.yml.example` | Git credentials (private repo) |

## Quick apply

```bash
cd ~/Downloads/Vulcan
make deploy-apply
```

## Generate deploy stub

```bash
make deploy-yaml
# merges into domain-resource.yaml manually if needed
```
