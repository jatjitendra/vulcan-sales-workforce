# Deploy to Pacific — Vulcan Deployment Guide

Official guide: [Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/)

Pacific: **pacific-051426** · Workspace: **ct-sandbox** · Product: **sales-workforce-jk**

Layout follows **practice-insights-v2** (`practice-insights-deploy.yaml` inside the `vulcan/` folder).

The guide uses `ds` — same CLI as **`dataos-ctl`**.

## Two required files (guide)

| File | Purpose |
|------|---------|
| `vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml` | Vulcan project config (Spark2 + `dataos://s3lhdepot`) |
| `vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml` | DataOS `type: vulcan` apply manifest |

Local dev uses `config.local.yaml` via Makefile (Postgres Docker).

---

## Step 1 — Prepare repository

```bash
cd ~/Downloads/Vulcan
export DATAOS_TENANT_ID=ct-sandbox
export VULCAN_TENANT_ID=ct-sandbox

make local-infra
make local-check

git add .
git commit -m "Pacific deploy: align with practice-insights-v2 layout"
git push origin main
```

---

## Step 2 — Git secret (private repo)

```bash
cp deploy/resources/git_sync_secret.yml.example deploy/resources/git_sync_secret.yml
# edit credentials
dataos-ctl resource apply -f deploy/resources/git_sync_secret.yml -w ct-sandbox
```

Referenced in `sales-workforce-deploy.yaml`:

```yaml
secret: ct-sandbox:github-token
```

---

## Step 3 — Verify prerequisites

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login

dataos-ctl resource get -t depot -n s3lhdepot -a -w ct-sandbox
dataos-ctl resource get -t compute -n ct-sandbox-compute -a -w ct-sandbox
dataos-ctl resource get -t stack -a -w ct-sandbox
```

(403? Ask admin for read access.)

---

## Step 4 — Deploy Vulcan resource

Same pattern as practice-insights:

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl tenant select -n ct-sandbox
dataos-ctl login
dataos-ctl resource apply -f vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml
```

Or:

```bash
make deploy-apply
```

### CLI requirement

If you see `unknown type 'vulcan'`, upgrade **dataos-ctl** or ask admin to apply the manifest.

---

## Step 5 — Monitor & verify

**CLI status:**

```bash
dataos-ctl resource get -t vulcan -n sales-workforce-jk -w ct-sandbox
```

**Logs:**

```bash
dataos-ctl resource log -t vulcan -n sales-workforce-jk -w ct-sandbox -c main
```

Runtime pods: `sales-workforce-jk-plan-execute`, `sales-workforce-jk-run-execute`, `sales-workforce-jk-api`.

**API:**

```bash
curl -s "https://pacific-051426.dataos.cloud/ct-sandbox/vulcan/sales-workforce-jk/livez" \
  -H "Authorization: Bearer <token>"
```

---

## Comparison with practice-insights-v2

| Item | practice-insights | sales-workforce-jk |
|------|-------------------|---------------------|
| Deploy YAML | `vulcan/practice-insights-deploy.yaml` | `vulcan/sales-workforce-deploy.yaml` |
| Engine | `spark` | `spark` |
| Dialect | `spark2` | `spark2` |
| Compute | `ct-sandbox-compute` | `ct-sandbox-compute` |
| Depot | `s3lhdepot` | `s3lhdepot` |
| Data source | Nilus → raw tables | CSV seeds → `raw.*` |

---

## Troubleshooting

| Error | Action |
|-------|--------|
| `unknown type 'vulcan'` | Upgrade dataos-ctl or admin applies |
| `403 Forbidden` | Admin: grant apply/get on vulcan in ct-sandbox |
| Duplicate model keys locally | `make reset-state` |
| Plan: config not found | Verify `baseDir` matches repo path; compare with practice-insights plan pod |
| Spark run failures | Check `*-run-execute` logs + Spark UI |
