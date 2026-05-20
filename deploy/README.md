# Deploy: Sales & Workforce (DataOS 2.0 / Vulcan)

Deployment manifests for registering this Vulcan project as a **Data Product** on DataOS Pacific.

## Target environment

| Setting | Value |
|---------|-------|
| Instance | `pacific-051426` |
| URL | `https://pacific-051426.dataos.cloud` |
| Workspace | `ct-sandbox` |
| Owner | `jitendrakumartmdcio` |
| Product | `sales-workforce-jk` |
| Bundle | `sales-workforce-bundle-jk` |

> **DataOS 2.0:** Quality = Vulcan assertions + audits + checks.  
> **Scanner** = Hub/Metis discovery only (not Soda).

## Files

| File | Purpose |
|------|---------|
| `data_product_spec.yml` | Registers product on Data Product Hub |
| `bundle.yml` | Deploys workspace resources in one apply |
| `scanner/dp_scanner.yml` | Scans product metadata into Hub / Metis |
| `resources/vulcan_api_service.yml` | Vulcan API service (`stack: vulcan:2.0`) |
| `resources/vulcan_graphql_service.yml` | GraphQL semantic API |
| `resources/vulcan_plan_workflow.yml` | Scheduled `vulcan plan` + `vulcan audit` |
| `resources/instance_secret_warehouse.yml.example` | Warehouse credentials template |
| `DEPLOY.md` | Step-by-step CLI commands |
| `scripts/deploy.sh` | One-shot deploy script |

## Quick deploy

```bash
dataos-ctl context select --name pacific-051426
dataos-ctl login

dataos-ctl apply -f deploy/bundle.yml -w ct-sandbox
dataos-ctl product apply -f deploy/data_product_spec.yml
dataos-ctl apply -f deploy/scanner/dp_scanner.yml -w ct-sandbox

dataos-ctl product get
dataos-ctl get -t service -w ct-sandbox
```

Or:

```bash
./deploy/scripts/deploy.sh
```

See [DEPLOY.md](./DEPLOY.md) and [DataOS deploy guide](https://dataos.info/learn/dp_developer_learn_track/deploy_dp_cli/).
