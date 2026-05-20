# Deployment steps (Sales & Workforce)
# DataOS 2.0 / Vulcan — Pacific instance pacific-051426, workspace ct-sandbox
# Docs: https://dataos.info/learn/dp_developer_learn_track/deploy_dp_cli/

## Environment

| Setting | Value |
|---------|-------|
| CLI context | `pacific-051426` |
| Universe URL | `https://pacific-051426.dataos.cloud` |
| Workspace | `ct-sandbox` |
| Role | `data-developer` |
| Vulcan tenant (`config.yaml`) | `ct-sandbox` |

## Phase 0 — CLI login (Pacific)

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login
```

During `dataos-ctl init`, FQDN must be **hostname only**: `pacific-051426.dataos.cloud` (no `https://`).

## Phase 1 — Build & validate locally (Vulcan)

```bash
cd ~/Downloads/Vulcan
export VULCAN_TENANT_ID=ct-sandbox
make reset-state
make up
make vulcan-cli CMD="info"
make vulcan-cli CMD="plan --auto-apply --no-prompts"
make vulcan-cli CMD="audit"
```

Verify tenant in metadata:

```bash
curl -s http://localhost:18000/api/v1/metadata | grep -i tenant
```

## Phase 2 — Prepare secrets (cloud, if needed)

1. Copy `deploy/resources/instance_secret_warehouse.yml.example` → `instance_secret_warehouse.yml`
2. Fill warehouse credentials for your cloud depot.
3. Apply secrets **before** the bundle:

```bash
dataos-ctl apply -f deploy/resources/instance_secret_warehouse.yml -w ct-sandbox
```

## Phase 3 — Deploy bundle

Per [DataOS bundle docs](https://dataos.info/resources/bundle/):

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl apply -f deploy/bundle.yml -w ct-sandbox
```

Check resources:

```bash
dataos-ctl get -t service -w ct-sandbox
dataos-ctl get -t workflow -w ct-sandbox -r
```

## Phase 4 — Register data product

Per [Data product spec docs](https://dataos.info/learn/dp_developer_learn_track/create_dp_spec/):

```bash
dataos-ctl product apply -f deploy/data_product_spec.yml
dataos-ctl product get
```

## Phase 5 — Scanner (Hub visibility)

Scanner registers metadata to Metis / Data Product Hub (not data quality):

```bash
dataos-ctl apply -f deploy/scanner/dp_scanner.yml -w ct-sandbox
dataos-ctl get -t workflow -n scan-sales-workforce-dp-jk -w ct-sandbox -r
```

## Phase 6 — View in DataOS UI

1. Open `https://pacific-051426.dataos.cloud`
2. Go to **Data Product Hub**
3. Open **Sales & Workforce** (`sales-workforce-jk`)
4. Use **ports** (Vulcan API / GraphQL) for consumption

## DataOS 2.0 stack mapping

| Legacy (1.0) | This project (2.0) |
|--------------|-------------------|
| Flare / Pyflare | Vulcan SQL models (`models/`) |
| Soda | Vulcan assertions + `vulcan audit` + `checks/` |
| Lens | Vulcan Semantics (`semantics/`) + GraphQL |
| Scanner | Hub/Metis registration only (`deploy/scanner/`) |

## Permissions note

If `dataos-ctl workspace get` returns 403, you may still deploy with a known workspace:

```bash
dataos-ctl apply -f deploy/bundle.yml -w ct-sandbox
```

If apply also returns 403, ask admin to grant `data-developer` apply rights on `ct-sandbox`.
