# Deploy to Pacific — Vulcan Deployment Guide

Official guide: [Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/)

Pacific: **pacific-051426** · Workspace: **ct-sandbox** · Product: **sales-workforce-jk**

## Two required files (guide)

| File | Purpose |
|------|---------|
| `config.yaml` | Vulcan project config (Spark + `dataos://s3lhdepot`) |
| `domain-resource.yaml` | DataOS `type: vulcan` apply manifest |

Local dev uses `config.local.yaml` via Makefile (Postgres Docker).

---

## Step 1 — Prepare repository

```bash
cd ~/Downloads/Vulcan
export DATAOS_TENANT_ID=ct-sandbox
export VULCAN_TENANT_ID=ct-sandbox

# Local validate (minimal — no full make up)
make local-infra
make local-check

git add .
git commit -m "Pacific deploy: config.yaml + domain-resource.yaml"
git push origin main
```

---

## Step 2 — Git secret (private repo only)

```bash
cp deploy/resources/git_sync_secret.yml.example deploy/resources/git_sync_secret.yml
# edit credentials
dataos-ctl apply -f deploy/resources/git_sync_secret.yml -w ct-sandbox
```

Uncomment in `domain-resource.yaml`:

```yaml
secret: ct-sandbox:github-token
```

---

## Step 3 — Verify prerequisites

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl get -t depot -w ct-sandbox
dataos-ctl get -t compute -w ct-sandbox -n ct-sandbox-compute
```

(403? Ask admin for read access.)

---

## Step 4 — Deploy Vulcan resource

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl apply -f domain-resource.yaml -w ct-sandbox
```

Or:

```bash
make deploy-apply
```

### CLI requirement

If you see:

```text
unknown type 'vulcan'
apply...nothing
```

Your **dataos-ctl** is too old (e.g. 2.27.8). Ask admin for a CLI that supports `type: vulcan`, or ask them to apply `domain-resource.yaml` for you (same as practice-insights).

---

## Step 5 — Monitor & verify

**UI:** Runtime tab → **plan**, **run**, **api** pods.

**CLI:**

```bash
dataos-ctl get -t vulcan -w ct-sandbox -n sales-workforce-jk
dataos-ctl resource -t Vulcan -n sales-workforce-jk logs \
  --container-group sales-workforce-jk-run-execute -c main
```

**API:**

```bash
curl -s "https://pacific-051426.dataos.cloud/ct-sandbox/vulcan/sales-workforce-jk/livez" \
  -H "Authorization: Bearer <token>"
```

---

## Troubleshooting

| Error | Action |
|-------|--------|
| `unknown type 'vulcan'` | Upgrade dataos-ctl or admin applies |
| `403 Forbidden` | Admin: grant apply/get on vulcan in ct-sandbox |
| Duplicate model keys locally | `make reset-state` |
| Docker permission on MinIO/transpiler | Use `make local-infra` not `make up` |
| Spark run failures | Check `*-run-execute` logs + Spark UI (guide) |
