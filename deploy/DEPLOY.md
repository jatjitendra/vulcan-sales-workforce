# Deploy to Pacific — Vulcan Deployment Guide

Official guide: [Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/)

Pacific: **pacific-051426** · Workspace: **ct-sandbox**

Layout follows **practice-insights-v2** — Bitbucket repo, `bitbucket-cred-mr`, deploy YAML inside each `vulcan/` folder.

The guide uses `ds` — same CLI as **`dataos-ctl`**.

## Two required files (per product)

| File | Purpose |
|------|---------|
| `vulcan-sales-workforce/<product>/vulcan/config.yaml` | Vulcan project config (Spark2 + `dataos://s3lhdepot`) |
| `vulcan-sales-workforce/<product>/vulcan/<product>-deploy.yaml` | DataOS `type: vulcan` apply manifest |

Local dev uses `config.local.yaml` via Makefile (Postgres Docker).

---

## Step 1 — Push to Bitbucket

Create repo **`vulcan-sales-workforce`** on Bitbucket (same workspace as practice-insights, e.g. `tmdc`):

```bash
cd ~/Downloads/Vulcan

# Add Bitbucket remote (replace if your workspace differs)
git remote add bitbucket https://bitbucket.org/tmdc/vulcan-sales-workforce.git
# or: git remote set-url origin https://bitbucket.org/tmdc/vulcan-sales-workforce.git

export DATAOS_TENANT_ID=ct-sandbox
export VULCAN_TENANT_ID=ct-sandbox
make local-check
make local-check VULCAN_PRODUCT=sales-workforce-jk

git add .
git commit -m "Bitbucket deploy: monorepo layout aligned with practice-insights"
git push bitbucket main
```

Repo layout on Bitbucket (matches `practice-insights` path pattern):

```
vulcan-sales-workforce/
  retail-inventory-jk/vulcan/
  sales-workforce-jk/vulcan/
```

---

## Step 2 — Git secret (Bitbucket)

Use the **same secret as practice-insights** — no custom GitHub token needed:

```yaml
secret: ct-sandbox:bitbucket-cred-mr
```

If git-sync fails with auth errors, ask admin to confirm `bitbucket-cred-mr` includes access to `vulcan-sales-workforce`.

Optional reference: `deploy/resources/bitbucket_secret.yml.example`

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

# Retail (default)
make deploy-apply

# Sales workforce
VULCAN_PRODUCT=sales-workforce-jk make deploy-apply
```

Or apply manifests directly:

```bash
dataos-ctl resource apply -f vulcan-sales-workforce/retail-inventory-jk/vulcan/retail-inventory-jk-deploy.yaml
dataos-ctl resource apply -f vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-jk-deploy.yaml
```

After switching from GitHub, delete stale resources first if plan still fails:

```bash
dataos-ctl resource delete -t vulcan -n retail-inv-jk -v v1alpha
dataos-ctl resource delete -t vulcan -n sales-workforce-jk -v v1alpha
# wait until get returns nothing, then re-apply
```

---

## Step 5 — Monitor & verify

```bash
dataos-ctl resource get -t vulcan -n retail-inv-jk
dataos-ctl resource log -t vulcan -n retail-inv-jk -c main
```

Check Spark **driver** logs (not only workflow executor) if plan fails.

---

## Comparison with practice-insights

| Item | practice-insights | vulcan-sales-workforce |
|------|-------------------|------------------------|
| Git host | Bitbucket | Bitbucket |
| Repo URL | `bitbucket.org/tmdc/sgws-testing` | `bitbucket.org/tmdc/vulcan-sales-workforce` |
| Secret | `ct-sandbox:bitbucket-cred-mr` | `ct-sandbox:bitbucket-cred-mr` |
| baseDir | `sgws-testing/practice-insights-v2/vulcan` | `vulcan-sales-workforce/<product>/vulcan` |
| Engine | `spark` | `spark` |
| Depot | `s3lhdepot` | `s3lhdepot` |

---

## Troubleshooting

| Error | Action |
|-------|--------|
| Git sync auth failure | Confirm Bitbucket repo access + `bitbucket-cred-mr` |
| Plan: config not found | Verify `baseDir` matches path under repo root on plan pod |
| `unknown type 'vulcan'` | Upgrade dataos-ctl or admin applies |
| Duplicate model keys locally | `make reset-state` |
