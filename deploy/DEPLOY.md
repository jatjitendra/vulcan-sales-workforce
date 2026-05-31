# Deploy to DataOS Pacific (Spark + s3lhdepot)

Same Pacific settings as **practice-insights**: `ct-sandbox-compute`, `engine: spark`, `dataos://s3lhdepot`.

## Environment

| Setting | Value |
|---------|--------|
| Instance | `pacific-051426` |
| URL | `https://pacific-051426.dataos.cloud` |
| Workspace | `ct-sandbox` |
| Tenant | `ct-sandbox` (`DATAOS_TENANT_ID`) |
| Deploy file | `deploy/sales-workforce-jk-deploy.yaml` |
| Project config | `config.yaml` (depot gateway → `s3lhdepot`) |
| Local dev config | `config.local.yaml` (Postgres Docker) |

## Phase 1 — Validate locally (Postgres Docker)

Local stack uses **`config.local.yaml`** automatically via Makefile:

```bash
cd ~/Downloads/Vulcan
export VULCAN_TENANT_ID=ct-sandbox
make up
make vulcan-cli CMD="plan --auto-apply --no-prompts"
make vulcan-cli CMD="audit"
```

## Phase 2 — Push code to GitHub

Cloud Vulcan pulls **`config.yaml`** (Spark + depot) from Git:

```bash
git add config.yaml deploy/sales-workforce-jk-deploy.yaml
git commit -m "Configure Spark/s3lhdepot cloud deploy"
git push -u origin main
```

## Phase 3 — Optional git secret (private repo only)

```bash
cp deploy/resources/git_sync_secret.yml.example deploy/resources/git_sync_secret.yml
# fill credentials, then:
dataos-ctl apply -f deploy/resources/git_sync_secret.yml -w ct-sandbox
```

Uncomment `secret:` in `deploy/sales-workforce-jk-deploy.yaml`.

## Phase 4 — Deploy to Pacific

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl apply -f deploy/sales-workforce-jk-deploy.yaml -w ct-sandbox
```

Or:

```bash
./deploy/scripts/deploy.sh
```

## Phase 5 — Verify

Ask admin to run (if you get 403):

```bash
dataos-ctl get -t vulcan -w ct-sandbox -n sales-workforce-jk
```

Check runtime logs in DataOS UI: **plan**, **run**, **api** entries.

API health (replace token):

```bash
curl -s "https://pacific-051426.dataos.cloud/ct-sandbox/vulcan/sales-workforce-jk/livez" \
  -H "Authorization: Bearer <token>"
```

## What gets deployed

| Component | Setting |
|-----------|---------|
| Git sync | `vulcan-sales-workforce` @ `main` |
| Depot | `dataos://s3lhdepot?purpose=rw` |
| Compute | `ct-sandbox-compute` |
| Engine | Spark (driver + 2 executors) |
| Workflow | daily 06:00 UTC: `migrate` → `plan` → `run` |
| API | REST + GraphQL + MySQL wire |

## Config files

| File | Used by |
|------|---------|
| `config.yaml` | **Cloud** — `gateways.s3lhdepot.connection.type: depot` |
| `config.local.yaml` | **Local Docker** — Postgres warehouse |
| `deploy/sales-workforce-jk-deploy.yaml` | **dataos-ctl apply** |

## Troubleshooting

| Error | Action |
|-------|--------|
| `403 Forbidden` on get/apply | Ask admin for `get`/`apply` on `vulcan` in `ct-sandbox` |
| Depot errors | Confirm `s3lhdepot` exists: `dataos-ctl get -t depot -w ct-sandbox` |
| Git sync failed | Add git secret; uncomment `secret:` in deploy YAML |
| Spark OOM / shuffle errors | Check Spark UI + increase executor memory in deploy YAML |
| Local vs cloud mismatch | Local uses `config.local.yaml`; cloud uses `config.yaml` |
