# Deploy to Pacific — Vulcan Deployment Guide

Official guide: [Deployment Steps](https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/)

Pacific: **pacific-051426** · Workspace: **ct-sandbox** · Product: **sales-workforce-jk**

The guide uses `ds` — same CLI as **`dataos-ctl`**. Use **`dataos-ctl resource`** subcommands (matches the guide's `ds resource ...`).

## Two required files (guide)

| File | Purpose |
|------|---------|
| `vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml` | Vulcan project config (Spark + `dataos://s3lhdepot`) |
| `domain-resource.yaml` | DataOS `type: vulcan` apply manifest (`repo.baseDir: vulcan-sales-workforce/sales-workforce-jk/vulcan`) |

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
dataos-ctl resource apply -f deploy/resources/git_sync_secret.yml -w ct-sandbox
```

Uncomment in `domain-resource.yaml`:

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

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl resource apply -f domain-resource.yaml -w ct-sandbox
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

**CLI status:**

```bash
dataos-ctl resource get -t vulcan -n sales-workforce-jk -w ct-sandbox
```

**Logs (per deployment guide):**

```bash
# Plan / migration
dataos-ctl resource log -t Vulcan -n sales-workforce-jk \
  -w ct-sandbox -c main

# Model run (Spark driver)
dataos-ctl resource log -t Vulcan -n sales-workforce-jk \
  -w ct-sandbox -c main -r
```

Runtime container groups in UI: `sales-workforce-jk-plan-execute`, `sales-workforce-jk-run-execute`, `sales-workforce-jk-api`.

**API:**

```bash
curl -s "https://pacific-051426.dataos.cloud/ct-sandbox/vulcan/sales-workforce-jk/livez" \
  -H "Authorization: Bearer <token>"
```

---

## Command reference (guide → your CLI)

| Guide | Your command |
|-------|--------------|
| `ds resource apply -f domain-resource.yaml` | `dataos-ctl resource apply -f domain-resource.yaml -w ct-sandbox` |
| `ds resource -t depot get -n s3lhdepot -a` | `dataos-ctl resource get -t depot -n s3lhdepot -a -w ct-sandbox` |
| `ds resource -t vulcan -n sales-workforce-jk get` | `dataos-ctl resource get -t vulcan -n sales-workforce-jk -w ct-sandbox` |

Note: `dataos-ctl apply` and `dataos-ctl resource apply` are equivalent; prefer **`resource`** to match the guide.

---

## Troubleshooting

| Error | Action |
|-------|--------|
| `unknown type 'vulcan'` | Upgrade dataos-ctl or admin applies |
| `403 Forbidden` | Admin: grant apply/get on vulcan in ct-sandbox |
| Duplicate model keys locally | `make reset-state` |
| Docker permission on MinIO/transpiler | Use `make local-infra` not `make up` |
| Spark run failures | Check `*-run-execute` logs + Spark UI (guide) |
