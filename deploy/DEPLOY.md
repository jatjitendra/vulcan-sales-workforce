# Deploy to DataOS Pacific (Vulcan single-file)

DataOS 2.0 deploys this product with **one Vulcan resource YAML** — no bundle, separate services, data product spec, or scanner.

## Environment

| Setting | Value |
|---------|--------|
| Instance | `pacific-051426` |
| URL | `https://pacific-051426.dataos.cloud` |
| Workspace | `ct-sandbox` |
| Deploy file | `deploy/sales-workforce-jk-deploy.yaml` |
| Resource | `type: vulcan`, name `sales-workforce-jk` |

## Phase 1 — Validate locally

```bash
cd ~/Downloads/Vulcan
export VULCAN_TENANT_ID=ct-sandbox
make up
make vulcan-cli CMD="plan --auto-apply --no-prompts"
make vulcan-cli CMD="audit"
```

## Phase 2 — Push code to GitHub

Cloud Vulcan pulls from Git. Repo must exist and be pushed before apply:

```bash
git push -u origin main
```

## Phase 3 — Generate deploy YAML (if models/config changed)

```bash
make deploy-yaml
```

Edits repo URL, depot, compute in `deploy/sales-workforce-jk-deploy.yaml` if needed.

## Phase 4 — Optional warehouse secret

If cloud depot needs credentials:

```bash
cp deploy/resources/instance_secret_warehouse.yml.example deploy/resources/instance_secret_warehouse.yml
# fill values, then:
dataos-ctl apply -f deploy/resources/instance_secret_warehouse.yml -w ct-sandbox
```

## Phase 5 — Deploy (single apply)

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
dataos-ctl apply -f deploy/sales-workforce-jk-deploy.yaml -w ct-sandbox
```

Or:

```bash
./deploy/scripts/deploy.sh
```

## Phase 6 — Verify

```bash
dataos-ctl get -t vulcan -w ct-sandbox
dataos-ctl get -t workflow -w ct-sandbox -r
dataos-ctl get -t service -w ct-sandbox
```

Use ingress/API URL from your admin or `dataos-ctl get` output for the Vulcan API.

## What this deploy file includes

| Component | In `spec` section |
|-----------|-------------------|
| Git repo sync | `repo` |
| Warehouse access | `depots` |
| Scheduled `vulcan plan` + `vulcan run` | `workflow` |
| Vulcan REST API | `api` |

Semantics and GraphQL are served through the Vulcan runtime (local: http://localhost:18000/redoc).

## Troubleshooting

| Error | Action |
|-------|--------|
| `unknown type 'vulcan'` | Ask admin to enable Vulcan resource type on Pacific |
| `403 Forbidden` | Ask admin for apply rights on `ct-sandbox` |
| Depot errors | Confirm depot name (`warehouse`) with admin |
